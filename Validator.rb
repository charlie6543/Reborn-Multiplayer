# The functions here can be used to validate our data against https://pokeapi.co/

require 'poke-api-v2'

def validateGen(gen = nil)
  validator = Validator.new
  validator.validateMovesets(gen)
end

# Rules:
# Level up and egg moves from USUM
# TMs + Tutor compatibilities from ORAS + USUM
# Headbutt and Rock Climb are compatible if they were ever compatible in any game
# Secret Power is not added to Gen 7+ mons (despite being universal in older games)
# Keeping event moves from Gen 3-7 (note: not validated because pokeapi doesn't have event moves info)
class Validator
  attr_reader :moveCache

  GENS = {
    1 => 1..151,
    2 => 152..251,
    3 => 252..386,
    4 => 387..493,
    5 => 494..649,
    6 => 650..721,
    7 => 722..807, # technically 809 but we consider Meltan line as Gen 8
    8 => 808..898, # technically 905 but we consider Legends Arceus as Gen 9
    9 => 899..1025, # Pecharunt is last at the time of writing
  }

  def initialize()
    @moveCache = {}
    @moveHash = {}
    $cache.moves.each do |symbol, move|
      @moveHash[move.name] = symbol
    end
    @tmtutormoves = []
    (TUTORMOVES + self.getTMList).each do |move|
      @tmtutormoves.push $cache.moves[move].name
    end
    @universaltms = []
    PBStuff::UNIVERSALTMS.each do |move|
      @universaltms.push $cache.moves[move].name
    end
  end

  def validateMovesets(gen = nil)
    # File.open("Scripts/#{GAMEFOLDER}/montext.rb") { |f|
    #   eval(f.read)
    # }
    # @mons = MONHASH

    for _, pkmn in $cache.pkmn
      next if gen != nil && !GENS[gen].include?(pkmn[0].dexnum)
      #puts "Validating " + pkmn[0].name
      i = 0
      while pkmn.hasForm?(i)
        if shouldValidate?(pkmn, i)
          validateForm(pkmn, i)
        end

        i += 1
      end
    end

    # mons = MonDataHash.new()
    # @mons.each { |key, value|
    #   mons[key] = MonWrapper.new(key, value)
    # }
    # monDump(mons, game: GAMEFOLDER)
  end

  def shouldValidate?(pkmn, i)
    return false if pkmn[i].checkFlag?(:ExcludeDex)
    return false if pkmn.forms[i].include?("Aevian")
    return true
  end

  def validateForm(pkmn, i)
    species = PokeApi.get(pokemon_species: pkmn[0].dexnum)
    assertName(pkmn[i].name, species.names)
    assertLevelUpMoves(pkmn, i, species)
    assertEggMoves(pkmn, i, species)
    assertCompatibleMoves(pkmn, i, species)
  end

  def assertLevelUpMoves(pkmn, i, species)
    form = pkmn[i]

    i = adjustVarietyIndex(form.name, i)

    return if species.varieties[i].nil? || shouldSkip?(species.varieties[i].pokemon.name)

    actual = []
    form.Moveset.each do |learn|
      actual.push [learn[0], $cache.moves[learn[1]].name]
    end
    actual.sort! { |a, b| 2 * (a[0] <=> b[0]) + (a[1] <=> b[1]) }

    # For possible game values see https://pokeapi.co/api/v2/version-group/?limit=100
    expected = findLevelUpMoves(species.varieties[i].pokemon.name, "ultra-sun-ultra-moon")

    extraActual = []
    (actual - expected).uniq.each do |learn|
      extraActual.push "#{learn[1]} (#{learn[0]})"
    end
    extraExpected = []
    (expected - actual).uniq.each do |learn|
      extraExpected.push "#{learn[1]} (#{learn[0]})"
    end

    if extraActual.length > 0
      log(sprintf(
        "%s form %s - remove level up moves: %s",
        form.name,
        i,
        extraActual.join(", "),
      ))
    end

    if extraExpected.length > 0
      log(sprintf(
        "%s form %s - add level up moves: %s",
        form.name,
        i,
        extraExpected.join(", "),
      ))
    end
  end

  def assertEggMoves(pkmn, i, species)
    form = pkmn[i]

    i = adjustVarietyIndex(form.name, i)

    return if species.varieties[i].nil? || shouldSkip?(species.varieties[i].pokemon.name)

    actual = []
    form.EggMoves.each do |move|
      actual.push $cache.moves[move].name
    end
    actual.sort! { |a, b| a <=> b }

    # For possible game values see https://pokeapi.co/api/v2/version-group/?limit=100
    expected = findEggMoves(species.varieties[i].pokemon.name, "ultra-sun-ultra-moon")

    extraActual = (actual - expected).uniq
    extraExpected = (expected - actual).uniq

    if extraActual.length > 0
      log(sprintf(
        "%s form %s - remove egg moves: %s",
        form.name,
        i,
        extraActual.join(", "),
      ))
    end

    if extraExpected.length > 0
      log(sprintf(
        "%s form %s - add egg moves: %s",
        form.name,
        i,
        extraExpected.join(", "),
      ))
    end
  end

  def shouldSkip?(name)
    return true if name.include?("-gmax")
    return true if name.include?("-mega")
    return true if name.include?("-primal")
    return true if name.include?("-origin")
    return true if name == "floette-eternal"
    return true if name == "greninja-battle-bond"
    return true if name.include?("zygarde-") && name != "zygarde-50"
    return false
  end

  def assertCompatibleMoves(pkmn, i, species)
    form = pkmn[i]

    i = adjustVarietyIndex(form.name, i)

    return if species.varieties[i].nil? || shouldSkip?(species.varieties[i].pokemon.name)

    actual = []
    form.compatiblemoves.each do |move|
      next if Gen < 8 && Gen8Moves.include?(move)
      next if form.moveexceptions.include?(move)
      actual.push $cache.moves[move].name
    end
    PBStuff::UNIVERSALTMS.each do |move|
      next if Gen < 8 && Gen8Moves.include?(move)
      next if form.moveexceptions.include?(move)
      actual.push $cache.moves[move].name
    end
    actual.sort! { |a, b| a <=> b }

    # pokeapi doesn't seem to have Celebrate compatibilities
    ignoredmoves = []
    # Ignore egg moves repeated among compatible
    form.EggMoves.each do |move|
      ignoredmoves.push $cache.moves[move].name
    end
    # Ignore relearner moves repeated among compatible
    form.RelearnerMoves.each do |move|
      ignoredmoves.push $cache.moves[move].name
    end
    # Ignore level up moves repeated among compatible
    form.Moveset.each do |learn|
      ignoredmoves.push $cache.moves[learn[1]].name
    end
    knownmoves = ignoredmoves.intersection(@tmtutormoves) - @universaltms
    ignoredmoves.push "Celebrate"
    ignoredmoves.push "Happy Hour"

    # For possible game values see https://pokeapi.co/api/v2/version-group/?limit=100
    expected = findCompatibleMoves(species.varieties[i].pokemon.name, "ultra-sun-ultra-moon", "omega-ruby-alpha-sapphire")

    # Check pre-evolutions if they're from different generation
    preevo = pbGetPreviousForm(pkmn.mon, i)
    if preevo
      unless isSameGen(preevo, [form.species, i])
        expected += findCompatibleMoves(species.evolves_from_species.name, "ultra-sun-ultra-moon", "omega-ruby-alpha-sapphire")
        preevo = pbGetPreviousForm(preevo[0], preevo[1])
        if preevo
          unless isSameGen(preevo, [form.species, i])
            pspecies = PokeApi.get(pokemon_species: $cache.pkmn[preevo[0], preevo[1]].dexnum)
            expected += findCompatibleMoves(pspecies.name, "ultra-sun-ultra-moon", "omega-ruby-alpha-sapphire")
          end
        end
      end
    end

    extraActual = (actual - expected - ignoredmoves - knownmoves).intersection(@tmtutormoves).uniq
    extraExpected = (expected + knownmoves - actual).uniq
    extraExpected = [] if species.varieties[i].pokemon.name == "mew"

    formname = $cache.pkmn[form.species].forms[i]

    if extraActual.length > 0
      # if @mons[form.species][formname] && @mons[form.species][formname][:compatiblemoves] != nil
      #   @mons[form.species][formname][:compatiblemoves] -= findMoveSymbols(extraActual)
      #   @mons[form.species][formname][:moveexceptions] = [] if @mons[form.species][formname][:moveexceptions].nil?
      #   @mons[form.species][formname][:moveexceptions] += findMoveSymbols(extraActual.intersection(@universaltms))
      # end
      log(sprintf(
        "%s form %s - remove compatible moves: %s",
        form.name,
        i,
        extraActual.join(", "),
      ))
    end

    if extraExpected.length > 0
      # if @mons[form.species][formname] && @mons[form.species][formname][:compatiblemoves] != nil
      #   @mons[form.species][formname][:compatiblemoves] += findMoveSymbols(extraExpected)
      #   unless @mons[form.species][formname][:moveexceptions].nil?
      #     @mons[form.species][formname][:moveexceptions] -= findMoveSymbols(extraExpected.intersection(@universaltms))
      #   end
      # end
      log(sprintf(
        "%s form %s - add compatible moves: %s",
        form.name,
        i,
        extraExpected.join(", "),
      ))
    end
  end

  def findMoveSymbols(moves)
    symbols = []
    moves.each do |move|
      symbols.push @moveHash[move]
    end
    return symbols
  end

  def getGen(dexnum)
    GENS.each do |gen, range|
      return gen if range.include?(dexnum)
    end
  end

  def isSameGen(preevo, evo)
    return false if getGen($cache.pkmn[preevo[0], preevo[1]].dexnum) != getGen($cache.pkmn[evo[0], evo[1]].dexnum)
    return false if isRegional($cache.pkmn[preevo[0]].forms[preevo[1]]) != isRegional($cache.pkmn[evo[0]].forms[evo[1]])
    return true
  end

  def isRegional(formname)
    ["Alolan", "Galarian", "Hisuian", "Paldean"].each do |region|
      return true if formname.include?(region)
    end
    return false
  end

  def findLevelUpMoves(identifier, game)
    moves = []
    pokemon = PokeApi.get(pokemon: identifier)
    evolutionMoves = []
    pokemon.moves.each do |learn|
      move = fetchMove(learn.move.name)
      learn.version_group_details.each do |group|
        next if group.version_group.name != game
        next if group.move_learn_method.name != "level-up"
        name = eng(move.names)
        moves.push [group.level_learned_at, adjustMoveName(name)]
        evolutionMoves.push name if group.level_learned_at == 0
      end
    end
    moves.sort! { |a, b| 2 * (a[0] <=> b[0]) + (a[1] <=> b[1]) }
    # Remove evolution moved duplicated as level 1 moves
    moves.filter! { |move| move[0] != 1 || !evolutionMoves.include?(move[1]) }
    return adjustLevelUpMoves(identifier, game, moves)
  end

  def findEggMoves(identifier, game)
    moves = []
    pokemon = PokeApi.get(pokemon: identifier)
    pokemon.moves.each do |learn|
      move = fetchMove(learn.move.name)
      learn.version_group_details.each do |group|
        next if group.version_group.name != game
        next if group.move_learn_method.name != "egg"
        moves.push adjustMoveName(eng(move.names))
      end
    end
    moves.sort! { |a, b| a <=> b }
    moves = adjustEggMoves(identifier, game, moves)
    moves.sort! { |a, b| a <=> b }
    return moves
  end

  def findCompatibleMoves(identifier, *games)
    moves = []
    pokemon = PokeApi.get(pokemon: identifier)
    pokemon.moves.each do |learn|
      move = fetchMove(learn.move.name)
      learn.version_group_details.each do |group|
        # Headbutt and Rock Climb compatibility is valid from any source.
        next if !games.include?(group.version_group.name) && !["headbutt", "rock-climb"].include?(learn.move.name)
        next if group.move_learn_method.name != "tutor" && group.move_learn_method.name != "machine"
        moves.push adjustMoveName(eng(move.names))
      end
    end
    moves.sort! { |a, b| a <=> b }
    moves = adjustCompatibleMoves(identifier, moves)
    moves.sort! { |a, b| a <=> b }
    return moves
  end

  def fetchMove(identifier)
    if @moveCache[identifier].nil?
      @moveCache[identifier] = PokeApi.get(move: identifier)
    end

    return @moveCache[identifier]
  end

  def assertName(actualName, names)
    name = eng(names).gsub("’", "'").gsub("♀", "").gsub("♂", "")
    if name != actualName
      # log(sprintf("Unexpected name %s, expected %s", actualName, name))
    end
  end

  def eng(names)
    names.each do |name|
      return name.name if name.language.name == "en"
    end
  end

  def getTMList()
    tms = []
    $cache.items.each do |key, item|
      tm = item.checkFlag?(:tm)
      tms.push tm if tm
    end
    return tms
  end

  def adjustLevelUpMoves(identifier, game, moves)
    # Camerupt's Ember for USUM is incorrectly set to level 5 instead of 8 in pokeapi
    moves[7][0] = 8 if identifier == "camerupt" && game == "ultra-sun-ultra-moon"
    return moves
  end

  def adjustEggMoves(identifier, game, moves)
    # Pichu has Volt Tackle as extra egg move
    moves.push "Volt Tackle" if identifier == "pichu"
    # For some reason in USUM Snorlax has Fissure as egg move but Munchlax doesn't
    moves.push "Fissure" if identifier == "munchlax" && game == "ultra-sun-ultra-moon"
    # Munchlax got Power-Up Punch as egg move in USUM, this is missing in pokeapi
    moves.push "Power-Up Punch" if identifier == "munchlax" && game == "ultra-sun-ultra-moon"
    return moves
  end

  def adjustCompatibleMoves(identifier, moves)
    # Event moves
    if ["pikachu", "raichu", "raichu-alola"].include?(identifier)
      moves.push "Surf"
      moves.push "Fly"
    end
    if ["pichu", "pikachu", "raichu", "raichu-alola"].include?(identifier)
      moves.push "Endeavor"
    end
    if ["charmander", "charmeleon", "charizard"].include?(identifier)
      moves.push "Acrobatics"
      moves.push "Block"
      moves.push "False Swipe"
    end
    if ["bulbasaur", "ivysaur", "venusaur", "squirtle", "wartortle", "blastoise"].include?(identifier)
      moves.push "Block"
      moves.push "False Swipe"
    end
    if ["lickitung", "lickylicky"].include?(identifier)
      moves.push "Heal Bell"
    end
    if ["gengar"].include?(identifier)
      moves.push "Sludge Wave"
    end
    if ["zoroark"].include?(identifier)
      moves.push "Sludge Bomb"
    end
    if ["arceus"].include?(identifier)
      moves.push "Blast Burn"
      moves.push "Hydro Cannon"
    end
    # Thundurus Therian can't learn Smart Strike by TM but apparently it's a bug.
    if ["thundurus-therian"].include?(identifier)
      moves.push "Smart Strike"
    end

    return moves
  end

  def adjustVarietyIndex(species, index)
    # Kyurem forms are swapped in pokeapi
    return 2 if species == "Kyurem" && index == 1
    return 1 if species == "Kyurem" && index == 2
    return index
  end

  MOVE_RENAMES = {
    "Stomping Tantrum" => "Stomp Tantrum",
    "Nature's Madness" => "Nature Madness",
  }

  def adjustMoveName(move)
    move = move.gsub("’", "'")
    return MOVE_RENAMES[move].nil? ? move : MOVE_RENAMES[move]
  end

  def log(message)
    puts message + "\n"
    File.write('movesets.txt', message + "\n", mode: 'a+')
  end
end

# This class stores data on each Pokemon.  Refer to $Trainer.party for an array
# of each Pokemon in the Trainer's current party.
class PokeBattle_Pokemon
  # stat information
  attr_reader :totalhp       # Current Total HP
  attr_reader :attack        # Current Attack stat
  attr_reader :defense       # Current Defense stat
  attr_accessor :speed       # Current Speed stat
  attr_reader :spatk         # Current Special Attack stat
  attr_reader :spdef         # Current Special Defense stat
  attr_accessor :iv          # Individual Values
  attr_accessor :ev          # Effort Values
  attr_accessor :species     # Species (National Pokedex number)
  attr_accessor :moves       # Moves (PBMove)
  attr_accessor :zmoves      # Z-Moves (PBMove)
  attr_accessor :hp          # Current HP
  attr_accessor :item        # Held item
  attr_accessor :name        # Nickname
  attr_accessor :exp         # Current experience points
  attr_accessor :level
  attr_accessor :happiness   # Current happiness
  attr_accessor :status      # Status problem (PBStatuses)
  attr_accessor :form
  attr_accessor :ability
  # other data
  attr_accessor :personalID  # Personal ID
  attr_accessor :trainerID   # 32-bit Trainer ID
  attr_accessor :mail        # Mail
  attr_accessor :fused       # The Pokémon fused into this one
  attr_accessor :eggsteps    # Steps to hatch egg, 0 if Pokémon is not an egg
  attr_accessor :firstmoves  # The moves known when this Pokémon was obtained
  attr_accessor :ballused    # Ball used
  attr_accessor :markings    # Markings
  attr_accessor :obtainMode
  attr_accessor :obtainMap   # Map where obtained
  attr_accessor :obtainText  # Replaces the obtain map's name if not nil
  attr_accessor :obtainLevel # Level obtained
  attr_accessor :hatchedMap  # Map where an egg was hatched
  attr_accessor :language    # Language
  attr_accessor :ot          # Original Trainer's name
  # attr_accessor(:ribbons)     # Array of ribbons
  attr_accessor :cool, :beauty, :cute, :smart, :tough, :sheen # Contest stats
  attr_accessor :obedient
  attr_accessor :pokerus # Pokérus strain and infection time
  # modification flags
  attr_accessor :genderflag  # Forces male (0) or female (1)
  attr_accessor :natureflag  # Forces a particular nature
  attr_accessor :shinyflag   # Forces the shininess (true/false)
  attr_accessor :hptype

  # battle info
  attr_accessor :itemRecycle # Consumed held item (used in battle only)
  attr_accessor :itemInitial # Resulting held item (used in battle only)
  attr_accessor :itemReallyInitialHonestlyIMeanItThisTime # Original held item (used in battle only)
  attr_accessor :belch       # If pokemon has used belch this battle (used in battle only)
  attr_accessor :statusCount # Sleep count/Toxic flag
  attr_accessor :piece       # Piece roll given for Chess field
  attr_accessor :landCritical # Galarian Farfetch'd evo method (used in battle only)
  attr_accessor :corrosiveGas # Corrosive Gas Effect (used in battle only)
  attr_accessor :originalAbility # stores original ability for semi permanent ability changes (mega evolution etc.)
  attr_accessor :originalForm # stores startform in battle for semi permanent form changes (Power construct, ultraburst, some mega's)
  attr_accessor :fakeOT
  attr_accessor :relearner
  attr_accessor :megaEvo

  def initialize(species, level, player = $Trainer, withMoves = true, form = 0)
    @form = form
    if $game_switches[:Just_Budew]
      species = :BUDEW
      @form = 0
    elsif $game_switches[:Just_Vulpix]
      species = :VULPIX
      @form = rand(2)
    end
    @species = species
    @moves = []
    @trainerID = player.id
    self.rollPersonalID
    if cancelledgenders.include?(species)
      @form = 1 if self.isFemale?
    end
    initAbility
    if withMoves
      # Generating move list
      movelist = []
      moveset = self.getMoveList
      for k in 0...moveset.length
        alevel = moveset[k][0]
        movelist.push(moveset[k][1]) if alevel <= level
      end
      movelist.reverse!
      movelist.uniq!
      # Use the first 4 items in the move list
      movelist = movelist[0, 4]
      movelist.reverse!
      for i in 0...4
        next if i >= movelist.length

        @moves[i] = PBMove.new(movelist[i])
      end
    end
    @nature = $cache.natures.keys[@personalID % 25]
    @hp = 1
    @totalhp = 1
    @ev = [0, 0, 0, 0, 0, 0]
    @iv = [rand(32), rand(32), rand(32), rand(32), rand(32), rand(32)]
    if ($cache.pkmn[species, @form].EggGroups.include?(:Undiscovered) || @species == :MANAPHY) || $game_switches[:Forced3IVs] # undiscovered group or manaphy
      stat1, stat2, stat3 = [0, 1, 2, 3, 4, 5].sample(3)
      for i in 0..5
        @iv[i] = 31 if [stat1, stat2, stat3].include?(i)
      end
    end
    # IV overrides
    @iv = [31, 31, 31, 31, 31, 31] if $game_switches[:Full_IVs]
    @iv = [0, 0, 0, 0, 0, 0] if $game_switches[:Empty_IVs_Password]
    @level = level
    @exp = PBExp.startExperience(level, self.growthrate)
    self.calcStats
    @hp = @totalhp

    # Flavor data
    @ot = player.name
    @language = player.language
    @happiness = $cache.pkmn[species, @form].Happiness
    @name = getMonName(@species, @form)
    timediverge = $Settings.unrealTimeDiverge
    $Settings.unrealTimeDiverge = 0
    time = pbGetTimeNow
    time = Time.new(time.year - 40, time.month, time.day, time.hour, time.min, time.sec) if Rejuv && inPast?
    @timeReceived = time.getgm.to_i # Use GMT
    $Settings.unrealTimeDiverge = timediverge
    @eggsteps = 0
    @status = nil
    @statusCount = 0
    @item = nil
    @mail = nil
    @fused = nil
    @ballused = :POKEBALL
    @obtainMap = $game_map.map_id
    @obtainText = nil
    @obtainLevel = level
    @landcritical = 0
    @obtainMode = 0 # Met
    @obtainMode = 4 if $game_switches[:Fateful_Encounter]
    @hatchedMap = 0
    @relearner = [false, 0]
    updateMegaData
  end

  def rollPersonalID
    @personalID = (rand(65536) | (rand(65536) << 16))
    shinyretries = 0
    shinyretries += 2 if $PokemonBag.pbQuantity(:SHINYCHARM) > 0 # 3 tries with shiny charm aka 3 times as likely
    shinyretries += 4 if $game_variables[:LuckShinies] > 0 # 5 tries with Luck contract aka 5 times as likely
    if shinyretries > 0
      shinyretries.times do
        break if self.isShiny?

        @personalID = (rand(65536) | (rand(65536) << 16))
      end
    end
  end

  # more flavor stuff
  def personalID(checkHiddenID = false)
    return @personalID.to_i if @personalID.is_a?(Numeric) || !checkHiddenID

    return @personalID
  end

  def updateMegaData
    @megaEvo = $cache.pkmn[@species, @form].MegaEvolutions
    @megaEvo = {} if !@megaEvo
  end

  ################################################################################
  # Stat calculations, Pokémon creation
  ################################################################################
  def baseStats
    val = $cache.pkmn[@species, @form].BaseStats
    val = [70, 70, 70, 90, 70, 100] if @species == :CASTFORM && @item == :CASTCREST && @form == 1
    val = [100, 70, 80, 70, 80, 70] if @species == :CASTFORM && @item == :CASTCREST && @form == 2
    val = [70, 70, 70, 100, 70, 90] if @species == :CASTFORM && @item == :CASTCREST && @form == 3
    return val
  end

  def calcHP(base, level, iv, ev)
    return 1 if base == 1

    return ((base * 2 + iv + (ev >> 2)) * level / 100).floor + level + 10
  end

  def calcStat(base, level, iv, ev, naturemod)
    naturemod = 1 if naturemod == nil
    return ((((base * 2 + iv + (ev >> 2)) * level / 100).floor + 5) * naturemod).floor
  end

  def calcStats
    @nature = $cache.natures.keys[self.personalID % 25] if @nature.nil?
    stats = []
    level = self.level
    bs = self.baseStats
    naturemod = {
      $cache.natures[self.nature].incStat => 1.1,
      $cache.natures[self.nature].decStat => 0.9,
    }
    for i in 0..5
      base = bs[i]
      if i == 0
        stats[i] = calcHP(base, level, @iv[i], @ev[i])
      else
        stats[i] = calcStat(base, level, @iv[i], @ev[i], naturemod.dig(i))
      end
    end
    diff = @totalhp - @hp
    @totalhp = stats[0]
    if @hp > 0
      @hp = @totalhp - diff
      @hp = 1 if @hp <= 0
      @hp = @totalhp if @hp > @totalhp
    end
    @attack = stats[1]
    @defense = stats[2]
    @spatk = stats[3]
    @spdef = stats[4]
    @speed = stats[5]
  end

  ################################################################################
  # Level
  ################################################################################
  def level=(value)
    @level = value.to_i
  end

  def isEgg?
    return @eggsteps > 0
  end

  def growthrate
    return $cache.pkmn[@species, @form].GrowthRate
  end

  def baseExp
    return $cache.pkmn[@species, @form].BaseEXP
  end

  ################################################################################
  # Ability
  ################################################################################
  def abilityIndex
    abillist = getAbilityList
    abil = abillist[self.personalID % (abillist.length)]
    abil = 0 if abil.nil?
    return abil
  end

  def initAbility
    abillist = getAbilityList
    @ability = abillist[self.personalID % (abillist.length)]
  end

  def setAbility(value)
    @ability = value
    @ability = getAbilityList[value] if value.is_a?(Integer)
  end

  def getAbilityList
    v = []
    $cache.pkmn[@species, self.form].Abilities.each { |abil| v.push(abil) }
    v.push($cache.pkmn[@species, self.form].HiddenAbility) if $cache.pkmn[@species, self.form].HiddenAbility
    return v
  end

  ################################################################################
  # Types
  ################################################################################
  def hasType?(type)
    return self.type1 == type || self.type2 == type
  end

  def type1
    if @species == :ARCEUS && @ability == :MULTITYPE
      type = $cache.pkmn[@species].forms[self.form % 19].upcase.intern
      type = :QMARKS if type == "???".intern
      return type
    elsif @species == :SILVALLY && @ability == :RKSSYSTEM
      type = $cache.pkmn[@species].forms[self.form].upcase.intern
      type = :QMARKS if type == "???".intern
      return type
    else
      return $cache.pkmn[@species, @form].Type1
    end
  end

  def type2
    # return nil if @species == :SILVALLY || @species == :ARCEUS
    return $cache.pkmn[@species, @form].Type2
  end

  ################################################################################
  # Moves
  ################################################################################
  def numMoves
    ret = 0
    for i in 0...4
      ret += 1 if !@moves[i].nil?
    end
    return ret
  end

  def knowsMove?(move)
    for i in 0...4
      next if @moves[i].nil?
      return true if @moves[i].move == move
    end
    return false
  end

  def getMoveList
    return $cache.pkmn[@species, @form].Moveset
  end

  def getRelearnList
    v = $cache.pkmn[@species, @form].RelearnerMoves if !v || v.nil?
    v = [] if !v || v.nil?
    return v
  end

  def getEggMoveList(relearner = false)
    babyspecies = pbGetBabySpecies(@species, @form)
    if babyspecies[0] == self.species
      movelist = $cache.pkmn[self.species, @form].EggMoves
    else
      if $cache.pkmn[babyspecies[0], babyspecies[1]].EggMoves
        movelist = $cache.pkmn[babyspecies[0], babyspecies[1]].EggMoves
        if relearner == true
          preevo = pbGetPreviousForm(@species, @form)
          if $cache.pkmn[preevo[0], preevo[1]].EggMoves
            preevomovelist = $cache.pkmn[preevo[0], preevo[1]].EggMoves
            movelist += preevomovelist
          end
          movelist.uniq!
        end
      end
    end
    movelist = [] if movelist.nil?
    return movelist
  end

  def resetMoves
    @moves = []
    moves = self.getMoveList
    movelist = []
    for i in moves
      if i[0] <= self.level
        movelist.push(i[1])
      end
    end
    movelist |= [] # Remove duplicates
    listend = movelist.length - 4
    listend = 0 if listend < 0
    for i in listend...listend + 4
      next if i >= movelist.length

      @moves.push(PBMove.new(movelist[i]))
    end
  end

  def pbLearnMove(move)
    return if knowsMove?(move)

    @moves = @moves.push(PBMove.new(move))
    if @moves.length > 4
      @moves = @moves.drop(1)
    end
    initZmoves(@item, true) if $cache.items[@item] && $cache.items[@item].checkFlag?(:zcrystal)
  end

  # Deletes all moves from the Pokémon.
  def pbDeleteAllMoves
    for i in 0...4
      @moves[i] = nil
    end
  end

  # Copies currently known moves into a separate array, for Move Relearner.
  def pbRecordFirstMoves
    @firstmoves = []
    for i in 0...4
      @firstmoves.push(@moves[i].move) if @moves[i]
    end
  end

  def SpeciesCompatible?(move)
    return false if @species.nil?

    exceptionlist = $cache.pkmn[@species, @form].moveexceptions
    return false if exceptionlist.include?(move)
    return true if @species == :MEW
    return true if PBStuff::UNIVERSALTMS.include?(move)

    tmmovelist = $cache.pkmn[@species, @form].compatiblemoves
    return true if tmmovelist.include?(move) && isTutorOrTM?(move)

    relearnermovelist = $cache.pkmn[@species, @form].RelearnerMoves
    return true if relearnermovelist.include?(move)

    movelist = getMoveList
    leveluplist = []
    for pair in movelist
      leveluplist.push pair[1]
    end
    if leveluplist.include?(move)
      # puts "#{@species} with form #{@form} is compatible with #{move} via levelup learnset, please add it to it's 'compatiblemoves' for efficiency!"
      return true
    end

    egglist = getEggMoveList
    if egglist.include?(move)
      # puts "#{@species} with form #{@form} is compatible with #{move} via it's Egg Moves, please add it to it's 'compatiblemoves' for efficiency!"
      return true
    end

    return false
  end

  def isTutorOrTM?(move)
    $cache.items.keys.each do |item|
      return true if move == $cache.items[item].checkFlag?(:tm)
    end
    return TUTORMOVES.include?(move)
  end

  def initZmoves(crystal, player = false)
    zcrystal_to_type = PBStuff::TYPETOZCRYSTAL.invert
    @zmoves = [nil, nil, nil, nil]
    if crystal == :INTERCEPTZ
      @zmoves[0] = PBMove.new(:UNLEASHEDPOWER)
      @zmoves[1] = PBMove.new(:BLINDINGSPEED)
      @zmoves[2] = $game_switches[:RenegadeRoute] && player ? PBMove.new(:CHTHONICMALADY) : PBMove.new(:ELYSIANSHIELD)
      @zmoves[3] = PBMove.new(:DOMAINSHIFT)
    elsif zcrystal_to_type[crystal]
      for i in 0...@moves.length
        move = @moves[i]
        next if move.type != zcrystal_to_type[crystal]

        @zmoves[i] = move.category == :status ? PBMove.new(move.move) : PBMove.new(PBStuff::CRYSTALTOZMOVE[crystal])
      end
    elsif (PBStuff::MOVETOZCRYSTAL.invert)[crystal]
      case crystal
        when :ALORAICHIUMZ then return if !(@species == :RAICHU && (@form == 1))
        when :DECIDIUMZ then return if !(@species == :DECIDUEYE && (@form == 0))
        when :INCINIUMZ then return if @species != :INCINEROAR
        when :PRIMARIUMZ then return if @species != :PRIMARINA
        when :EEVIUMZ then return if @species != :EEVEE
        when :PIKANIUMZ then return if @species != :PIKACHU
        when :SNORLIUMZ then return if @species != :SNORLAX
        when :MEWNIUMZ then return if @species != :MEW
        when :TAPUNIUMZ then return if !(@species == :TAPUKOKO || @species == :TAPULELE || @species == :TAPUFINI || @species == :TAPUBULU)
        when :MARSHADIUMZ then return if @species != :MARSHADOW
        when :KOMMONIUMZ then return if @species != :KOMMOO
        when :LYCANIUMZ then return if @species != :LYCANROC
        when :MIMIKIUMZ then return if @species != :MIMIKYU
        when :SOLGANIUMZ then return if !((@species == :NECROZMA && @form == 1) || @species == :SOLGALEO)
        when :LUNALIUMZ then return if !((@species == :NECROZMA && @form == 2) || @species == :LUNALA)
        when :ULTRANECROZIUMZ then return if !(@species == :NECROZMA && @form != 0)
      end
      for i in 0...@moves.length
        move = @moves[i]
        next if crystal != PBStuff::MOVETOZCRYSTAL[move.move]

        @zmoves[i] = PBMove.new(PBStuff::CRYSTALTOZMOVE[crystal])
      end
    end
  end

  def updateZMoveIndex(index)
    zcrystal_to_type = PBStuff::TYPETOZCRYSTAL.invert
    if zcrystal_to_type[@item]
      if @moves[index].type != zcrystal_to_type[@item]
        @zmoves[index] = nil
      else
        @zmoves[index] =
          @moves[index].category == :status ? PBMove.new(@moves[index].move) : PBMove.new(PBStuff::CRYSTALTOZMOVE[@item])
      end
    elsif (PBStuff::MOVETOZCRYSTAL.invert)[@item]
      speciesblock = false
      case @item
        when :ALORAICHIUMZ then speciesblock = true if !(@species == :RAICHU && (@form == 1))
        when :DECIDIUMZ then speciesblock = true if !(@species == :DECIDUEYE && (@form == 0))
        when :INCINIUMZ then speciesblock = true if @species != :INCINEROAR
        when :PRIMARIUMZ then speciesblock = true if @species != :PRIMARINA
        when :EEVIUMZ then speciesblock = true if @species != :EEVEE
        when :PIKANIUMZ then speciesblock = true if @species != :PIKACHU
        when :SNORLIUMZ then speciesblock = true if @species != :SNORLAX
        when :MEWNIUMZ then speciesblock = true if @species != :MEW
        when :TAPUNIUMZ then speciesblock = true if !(@species == :TAPUKOKO || @species == :TAPULELE || @species == :TAPUFINI || @species == :TAPUBULU)
        when :MARSHADIUMZ then speciesblock = true if @species != :MARSHADOW
        when :KOMMONIUMZ then speciesblock = true if @species != :KOMMOO
        when :LYCANIUMZ then speciesblock = true if @species != :LYCANROC
        when :MIMIKIUMZ then speciesblock = true if @species != :MIMIKYU
        when :SOLGANIUMZ then speciesblock = true if !((@species == :NECROZMA && @form == 1) || @species == :SOLGALEO)
        when :LUNALIUMZ then speciesblock = true if !((@species == :NECROZMA && @form == 2) || @species == :LUNALA)
        when :ULTRANECROZIUMZ then speciesblock = true if !(@species == :NECROZMA && @form != 0)
      end
      if (@item != PBStuff::MOVETOZCRYSTAL[@moves[index].move]) || speciesblock
        @zmoves[index] = nil
      else
        @zmoves[index] = PBMove.new(PBStuff::CRYSTALTOZMOVE[@item])
      end
    end
  end

  ################################################################################
  # Nature
  ################################################################################
  def nature
    return @natureflag if @natureflag != nil

    return @nature
  end

  def setNature(value)
    @natureflag = value
    self.calcStats
  end

  def nature=(value)
    @nature = value
    self.calcStats
  end

  ################################################################################
  # Shininess
  ################################################################################
  def isShiny?
    return @shinyflag if @shinyflag != nil

    a = self.personalID ^ @trainerID
    b = a & 0xFFFF
    c = (a >> 16) & 0xFFFF
    d = b ^ c
    return (d < SHINYPOKEMONCHANCE)
  end

  def makeShiny
    @shinyflag = true
  end

  def makeNotShiny
    @shinyflag = false
  end

  ################################################################################
  # Gender
  ################################################################################
  def gender
    return @genderflag if @genderflag != nil

    ratio = $cache.pkmn[@species, @form].GenderRatio
    case ratio
      when :Genderless then return 2 # genderless
      when :MaleZero then return 1 # always female
      when :FemZero then return 0 # always male
      when :FemEighth then genderbyte = 31
      when :FemQuarter then genderbyte = 63
      when :FemHalf then genderbyte = 127
      when :MaleQuarter then genderbyte = 191
      when :MaleEighth then genderbyte = 223
    end
    return ((self.personalID & 0xFF) <= genderbyte) ? 1 : 0
  end

  def isMale?
    return self.gender == 0
  end

  def isFemale?
    return self.gender == 1
  end

  def setGender(value)
    value = 0 if value == "Male"
    value = 1 if value == "Female"
    return if !value.is_a?(Integer)

    ratio = $cache.pkmn[@species, @form].GenderRatio
    if ratio != :Genderless && ratio != :MaleZero && ratio != :FemZero
      @genderflag = value
    end
    if cancelledgenders.include?(@species)
      self.form = 1 if self.isFemale?
      self.form = 0 if self.isMale?
    end
  end

  def makeMale; setGender(0); end
  def makeFemale; setGender(1); end
  def makeGenderless; setGender(2); end

  ################################################################################
  # Pokérus
  ################################################################################
  def givePokerus(strain = 0)
    return if self.pokerusStage == 2 # Can't re-infect a cured Pokémon

    if strain <= 0 || strain >= 16
      strain = 1 + rand(15)
    end
    time = 1 + (strain % 4)
    @pokerus = time
    @pokerus |= strain << 4
  end

  def resetPokerusTime
    return if @pokerus == 0

    strain = @pokerus % 16
    time = 1 + (strain % 4)
    @pokerus = time
    @pokerus |= strain << 4
  end

  def lowerPokerusCount
    return if self.pokerusStage != 1

    @pokerus -= 1
  end

  def pokerusStage
    return 0 if !@pokerus || @pokerus == 0 # Not infected
    return 2 if @pokerus > 0 && (@pokerus % 16) == 0 # Cured

    return 1 # Infected
  end

  ################################################################################
  # Forms
  ################################################################################
  def form=(value)
    @form = value
    self.calcStats
    $Trainer.pokedex.setFormSeen(self)
    $Trainer.pokedex.setFormOwned(self) if $Trainer.party.include?(self) || $PokemonStorage.contains?(self)
    updateMegaData if @form && !self.isMega? && !self.isPrimal? && !self.isRift? && !self.isPulse? && !self.isPerfection?
    initZmoves(@item, true) if $cache.items[@item] && $cache.items[@item].checkFlag?(:zcrystal) && @species == :NECROZMA
  end

  def getForm(pkmn)
    if pkmn.species == :GIRATINA
      return pkmn.item == :GRISEOUSORB || DistortionWorld.include?($game_map.map_id) ? 1 : 0
    end

    if pkmn.species == :ARCEUS && pkmn.ability == :MULTITYPE
      case pkmn.item
        when :FISTPLATE, :FIGHTINIUMZ then arcform = 1
        when :SKYPLATE, :FLYINIUMZ then arcform = 2
        when :TOXICPLATE, :POISONIUMZ then arcform = 3
        when :EARTHPLATE, :GROUNDIUMZ then arcform = 4
        when :STONEPLATE, :ROCKIUMZ then arcform = 5
        when :INSECTPLATE, :BUGINIUMZ then arcform = 6
        when :SPOOKYPLATE, :GHOSTIUMZ then arcform = 7
        when :IRONPLATE, :STEELIUMZ then arcform = 8
        when :FLAMEPLATE, :FIRIUMZ then arcform = 10
        when :SPLASHPLATE, :WATERIUMZ then arcform = 11
        when :MEADOWPLATE, :GRASSIUMZ then arcform = 12
        when :ZAPPLATE, :ELECTRIUMZ then arcform = 13
        when :MINDPLATE, :PSYCHIUMZ then arcform = 14
        when :ICICLEPLATE, :ICIUMZ then arcform = 15
        when :DRACOPLATE, :DRAGONIUMZ then arcform = 16
        when :DREADPLATE, :DARKINIUMZ then arcform = 17
        when :PIXIEPLATE, :FAIRIUMZ then arcform = 18
        else arcform = 0
      end
      return 19 + arcform if pkmn.form > 18

      return arcform
    end
    if pkmn.species == :GENESECT
      case pkmn.item
        when :SHOCKDRIVE then return 1
        when :BURNDRIVE then return 2
        when :CHILLDRIVE then return 3
        when :DOUSEDRIVE then return 4
        else return 0
      end
    end
    if pkmn.species == :SILVALLY && pkmn.ability == :RKSSYSTEM
      case pkmn.item
        when :FIGHTINGMEMORY then return 1
        when :FLYINGMEMORY then return 2
        when :POISONMEMORY then return 3
        when :GROUNDMEMORY then return 4
        when :ROCKMEMORY then return 5
        when :BUGMEMORY then return 6
        when :GHOSTMEMORY then return 7
        when :STEELMEMORY then return 8
        when :GLITCHMEMORY then return 9
        when :FIREMEMORY then return 10
        when :WATERMEMORY then return 11
        when :GRASSMEMORY then return 12
        when :ELECTRICMEMORY then return 13
        when :PSYCHICMEMORY then return 14
        when :ICEMEMORY then return 15
        when :DRAGONMEMORY then return 16
        when :DARKMEMORY then return 17
        when :FAIRYMEMORY then return 18
        else return 0
      end
    end
    if pkmn.species == :ZACIAN
      return pkmn.item == :RUSTEDSWORD ? 1 : 0
    end
    if pkmn.species == :ZAMAZENTA
      return pkmn.item == :RUSTEDSHIELD ? 1 : 0
    end

    return pkmn.form
  end

  def baseForm
    return $cache.pkmn[@species, @form].baseForm
  end

  def getFormName
    formnames = $cache.pkmn[@species].forms
    return if formnames.empty?
    return "Female" if cancelledgenders.include?(@species) && self.isFemale?

    return formnames[@form].clone
  end

  def hasMegaForm?
    return false if self.isMega? # don't do this if you're mega.
    return false if @megaEvo.empty?
    return false if @species == :RAYQUAZA && pbIsZCrystal?(@item)
    return true if @species == :RAYQUAZA && self.moves.any? { |move| @megaEvo.has_key?(move.move) }

    return @megaEvo.has_key?(@item)
  end

  def hasUltraForm?
    return @species == :NECROZMA && @item == :ULTRANECROZIUMZ && self.form != 0
  end

  def isMega?
    updateMegaData if !@megaEvo # ensure @megaEvo is defined
    return false if @megaEvo.empty?

    return @megaEvo.values.include?(getFormName())
  end

  def makeMega
    form = $cache.pkmn[@species].forms.invert[@megaEvo[@item]]
    if !form # rayquaza, aka non item based
      moves = self.moves.map { |m| m.move }
      move = nil
      moves.each { |m|
        move = m if @megaEvo.has_key?(m)
      }
      return if move == nil

      form = $cache.pkmn[@species].forms.invert[@megaEvo[move]]
    end
    self.originalForm = self.form
    self.form = form
    self.originalAbility = self.ability
    self.ability = self.abilityIndex
  end

  def makeUnmega
    if !self.originalForm && $Trainer.party.include?(self)
      print "this mon's original form was not set, somehow. please report this: species:#{@species} form:#{$cache.pkmn[@species].forms[self.form]} thx <3"
    end
    self.form = self.originalForm ? self.originalForm : 0
    self.ability = self.originalAbility if self.originalAbility
    self.originalAbility = nil
    self.originalForm = nil
  end

  def isPrimal?
    return false if @species != :GROUDON && @species != :KYOGRE

    v = $cache.pkmn[@species].checkFlag?(:PrimalForm)
    return v != nil && v == self.form
  end

  def makePrimal
    v = $cache.pkmn[@species].checkFlag?(:PrimalForm)
    self.form = v if v.is_a?(Integer)
    self.originalAbility = self.ability
    self.ability = self.abilityIndex
  end

  def makeUnprimal
    self.form = 0
    self.ability = self.originalAbility if self.originalAbility
    self.originalAbility = nil
  end

  def isUltra?
    return false if @species != :NECROZMA

    v = $cache.pkmn[@species].checkFlag?(:UltraForm)
    return v != nil && v == self.form
  end

  def makeUltra
    v = $cache.pkmn[@species].checkFlag?(:UltraForm)
    self.originalForm = self.form
    self.form = v if v.is_a?(Integer)
    self.originalAbility = self.ability
    self.ability = self.abilityIndex
  end

  def makeUnultra
    if !self.originalForm && $Trainer.party.include?(self)
      print "this mon's original form was not set, somehow. please report this: species:#{@species} form:#{$cache.pkmn[@species].forms[self.form]} thx <3"
    end
    revertForm = self.originalForm
    if !revertForm
      if self.fused
        case self.fused.species
          when :SOLGALEO then revertForm = 1
          when :LUNALA then revertForm = 2
          else
            revertForm = 0
        end
      else
        revertForm = 0
      end
    end
    self.form = revertForm
    self.ability = self.originalAbility if self.originalAbility
    self.originalAbility = nil
    self.originalForm = nil
  end

  def isPulse?
    v = $cache.pkmn[@species].checkFlag?(:PulseForm)
    return false if !v
    if v.is_a?(Hash)
      return v.values.include?(self.form)
    else
      return (self.form >= v)
    end
  end

  def isRift?
    v = $cache.pkmn[@species].checkFlag?(:RiftForm)
    return false if !v
    if v.is_a?(Hash)
      return v.values.include?(self.form)
    else
      return (self.form >= v)
    end
  end

  def isPerfection?
    v = $cache.pkmn[@species].checkFlag?(:PerfectionForm)
    return false if !v
    if v.is_a?(Hash)
      return v.values.include?(self.form)
    else
      return (self.form >= v)
    end
  end

  ################################################################################
  # Other
  ################################################################################
  def hasAnItem?
    return !@item.nil?
  end

  def isAirborne?
    return false if @item == :IRONBALL
    return true if self.hasType?(:FLYING)
    return true if [:LEVITATE, :SOLARIDOL, :LUNARIDOL].include?(@ability)
    return true if @item == :AIRBALLOON

    return false
  end

  def setItem(value)
    @item = value
    @zmoves = nil if !$cache.items[value] || !$cache.items[value].checkFlag?(:zcrystal)
  end

  def wildHoldItems
    common = $cache.pkmn[@species, @form].checkFlag?(:WildItemCommon, nil)
    uncommon = $cache.pkmn[@species, @form].checkFlag?(:WildItemUncommon, nil)
    rare = $cache.pkmn[@species, @form].checkFlag?(:WildItemRare, nil)
    return [common, uncommon, rare]
  end

  def mail
    return nil if !@mail

    if @mail.item == 0 || !self.hasAnItem? || @mail.item != self.item
      @mail = nil
      return nil
    end
    return @mail
  end

  def language; @language ? @language : 0; end

  def markings
    @markings = 0 if !@markings
    return @markings
  end

  def unownShape
    return "ABCDEFGHIJKLMNOPQRSTUVWXYZ?!"[@form, 1]
  end

  def weight
    return $cache.pkmn[@species, @form].Weight
  end

  def height
    return $cache.pkmn[@species, @form].Height
  end

  def evYield
    return $cache.pkmn[@species, @form].EVs
  end

  def catchRate
    return $cache.pkmn[@species, @form].CatchRate
  end

  def eggGroups
    return $cache.pkmn[@species, @form].EggGroups
  end

  def dexnum
    return $cache.pkmn[@species, @form].dexnum
  end

  def fakeOT
    @fakeOT = false if !@fakeOT
    @fakeOT
  end

  def egg?
    return @eggsteps > 0
  end

  def hp=(value)
    value = 0 if value < 0
    @hp = value
    if @hp == 0
      @status = nil
      @statusCount = 0
    end
  end

  def healHP
    @hp = @totalhp
  end

  def healStatus
    @status = nil
    @statusCount = 0
  end

  def healPP(index = -1)
    for i in 0...4
      next if !@moves[i]

      @moves[i].pp = @moves[i].totalpp
    end
  end

  def heal
    return if egg?

    healHP
    healStatus
    healPP
  end

  def changeHappiness(method)
    gain = 0; luxury = false
    case method
      when "walking"
        gain = 1
        gain += 1 if @happiness < 200
        gain += 1 if @obtainMap == $game_map.map_id
      when "level up"
        gain = 3
        gain = 4 if @happiness < 200
        gain = 5 if @happiness < 100
      when "groom"
        gain = 5
        gain = 16 if @happiness < 200
        luxury = true
      when "groom2"
        gain = 8
        gain = 13 if @happiness < 200
        luxury = true
      when "groom3"
        gain = 255
        luxury = true
      when "faint"
        gain = -1
      when "vitamin"
        gain = 2
        gain = 3 if @happiness < 200
        gain = 5 if @happiness < 100
        luxury = true
      when "wing"
        gain = 1
        gain = 2 if @happiness < 200
        gain = 3 if @happiness < 100
      when "EV berry"
        gain = 2
        gain = 5 if @happiness < 200
        gain = 10 if @happiness < 100
        luxury = true
      when "powder"
        gain = -10
        gain = -5 if @happiness < 200
      when "Energy Root"
        gain = -15
        gain = -10 if @happiness < 200
      when "Revival Herb"
        gain = -20
        gain = -15 if @happiness < 200
      when "candy"
        gain = 3
        gain = 4 if @happiness < 200
        gain = 5 if @happiness < 100
        luxury = true
      when "bluecandy"
        gain = 220
        luxury = true
      when "badcandy"
        gain = -3
        gain = -4 if @happiness < 200
        gain = -5 if @happiness < 100
      when "Regular"
        gain = 5
        gain = 16 if @happiness < 200
        luxury = true
      when "Travellers"
        gain = 8
        gain = 13 if @happiness < 200
        luxury = true
      when "Luxurious"
        gain = 70
        gain = 30 if @happiness < 200
        luxury = true
      else
        Kernel.pbMessage(_INTL("Unknown happiness-changing method."))
    end
    gain += 1 if luxury && self.ballused == :LUXURYBALL
    gain *= 1.5 if (self.item == :SOOTHEBELL) && gain > 0
    gain.round
    @happiness += gain
    @happiness = [[255, @happiness].min, 0].max
  end

  ################################################################################
  # Ownership, obtained information
  ################################################################################
  # Returns whether the specified Trainer is NOT this Pokemon's original trainer.
  def isForeign?(trainer)
    return @trainerID != trainer.id || @ot != trainer.name
  end

  # Returns the public portion of the original trainer's ID.
  def publicID
    return @trainerID & 0xFFFF
  end

  # Returns this Pokémon's level when this Pokémon was obtained.
  def obtainLevel
    @obtainLevel = 0 if !@obtainLevel
    return @obtainLevel
  end

  # Returns the time when this Pokémon was obtained.
  def timeReceived
    return @timeReceived ? Time.at(@timeReceived) : Time.gm(2000)
  end

  # Sets the time when this Pokémon was obtained.
  def timeReceived=(value)
    # Seconds since Unix epoch
    if shouldDivergeTime?
      timediverge = $Settings.unrealTimeDiverge
      $Settings.unrealTimeDiverge = 0
      value = Time.new
    end
    if value.is_a?(Time)
      @timeReceived = value.to_i
    else
      @timeReceived = value
    end
    $Settings.unrealTimeDiverge = timediverge if timediverge
  end

  # Returns the time when this Pokémon hatched.
  def timeEggHatched
    if obtainMode == 1
      return @timeEggHatched ? Time.at(@timeEggHatched) : Time.gm(2000)
    else
      return Time.gm(2000)
    end
  end

  # Sets the time when this Pokémon hatched.
  def timeEggHatched=(value)
    # Seconds since Unix epoch
    if shouldDivergeTime?
      timediverge = $Settings.unrealTimeDiverge
      $Settings.unrealTimeDiverge = 0
      value = Time.new
    end
    if value.is_a?(Time)
      @timeEggHatched = value.to_i
    else
      @timeEggHatched = value
    end
    $Settings.unrealTimeDiverge = timediverge if timediverge
  end

  def canRelearnAll?
    @relearner = [false, 0] if !@relearner
    return @relearner[0]
  end

  def updateRelearnBar
    @relearner = [false, 0] if !@relearner
    @relearner[1] += 1 if relearner[1] < 3
    activateRelearner() if @relearner[1] >= 3
  end

  def activateRelearner()
    if !@relearner
      @relearner = [true, 3]
    else
      @relearner[0] = true
    end
  end
end

# gotta put this somewhere!!!!!!!!!!!!!!!
def drawSpot(bitmap, spotpattern, x, y, red, green, blue)
  height = spotpattern.length
  width = spotpattern[0].length
  for yy in 0...height
    spot = spotpattern[yy]
    for xx in 0...width
      if spot[xx] == 1
        xOrg = (x + xx) << 1
        yOrg = (y + yy) << 1
        color = bitmap.get_pixel(xOrg, yOrg)
        r = color.red + red
        g = color.green + green
        b = color.blue + blue
        color.red = [[r, 0].max, 255].min
        color.green = [[g, 0].max, 255].min
        color.blue = [[b, 0].max, 255].min
        bitmap.set_pixel(xOrg, yOrg, color)
        bitmap.set_pixel(xOrg + 1, yOrg, color)
        bitmap.set_pixel(xOrg, yOrg + 1, color)
        bitmap.set_pixel(xOrg + 1, yOrg + 1, color)
      end
    end
  end
end

def pbSpindaSpots(pokemon, bitmap)
  spot1 = [
    [0, 0, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 1, 0, 0],
  ]
  spot2 = [
    [0, 0, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 0, 0],
  ]
  spot3 = [
    [0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0],
  ]
  spot4 = [
    [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0],
  ]
  id = pokemon.personalID
  h = (id >> 28) & 15
  g = (id >> 24) & 15
  f = (id >> 20) & 15
  e = (id >> 16) & 15
  d = (id >> 12) & 15
  c = (id >> 8) & 15
  b = (id >> 4) & 15
  a = (id) & 15
  if pokemon.isShiny?
    drawSpot(bitmap, spot1, b + 43, a + 35, -120, -120, -20)
    drawSpot(bitmap, spot2, d + 31, c + 34, -120, -120, -20)
    drawSpot(bitmap, spot3, f + 49, e + 17, -120, -120, -20)
    drawSpot(bitmap, spot4, h + 25, g + 16, -120, -120, -20)
  else
    drawSpot(bitmap, spot1, b + 43, a + 35, 0, -115, -75)
    drawSpot(bitmap, spot2, d + 31, c + 34, 0, -115, -75)
    drawSpot(bitmap, spot3, f + 49, e + 17, 0, -115, -75)
    drawSpot(bitmap, spot4, h + 25, g + 16, 0, -115, -75)
  end
end

def getListOfSpecies
  arr = []
  $cache.pkmn.each { |symbol, dat|
    arr.push(dat.name)
  }
  return arr
end

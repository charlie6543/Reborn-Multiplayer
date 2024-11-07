################################################################################
# Form Check
# By Marcello & Kurotsune
################################################################################
def isLegalForm?(pkmn)
  return true unless Reborn # TODO: Handle Rejuv/Deso
  return false if $cache.pkmn[pkmn.species, pkmn.form].flags[:ExcludeDex]
  return false if pkmn.isMega? || pkmn.isPrimal? || pkmn.isUltra?
  return false if pkmn.species == :CASTFORM && pkmn.form != 0
  return false if pkmn.species == :CHERRIM && pkmn.form == 1
  return false if pkmn.species == :GIRATINA && pkmn.form == 1 && pkmn.item != :GRISEOUSORB

  if [:ARCEUS, :SILVALLY].include?(pkmn.species)
    return false if pkmn.species == :ARCEUS && pkmn.form == 9

    type_items = [
      [:FISTPLATE, :FIGHTINIUMZ, :FIGHTINGMEMORY], [:SKYPLATE, :FLYINIUMZ, :FLYINGMEMORY], [:TOXICPLATE, :POISONIUMZ, :POISONMEMORY],
      [:EARTHPLATE, :GROUNDIUMZ, :GROUNDMEMORY], [:STONEPLATE, :ROCKIUMZ, :ROCKMEMORY], [:INSECTPLATE, :BUGINIUMZ, :BUGMEMORY],
      [:SPOOKYPLATE, :GHOSTIUMZ, :GHOSTMEMORY], [:IRONPLATE, :STEELIUMZ, :STEELMEMORY], [nil, nil, :GLITCHMEMORY],
      [:FLAMEPLATE, :FIRIUMZ, :FIREMEMORY], [:SPLASHPLATE, :WATERIUMZ, :WATERMEMORY], [:MEADOWPLATE, :GRASSIUMZ, :GRASSMEMORY],
      [:ZAPPLATE, :ELECTRIUMZ, :ELECTRICMEMORY], [:MINDPLATE, :PSYCHIUMZ, :PSYCHICMEMORY], [:ICICLEPLATE, :ICIUMZ, :ICEMEMORY],
      [:DRACOPLATE, :DRAGONIUMZ, :DRAGONMEMORY], [:DREADPLATE, :DARKINIUMZ, :DARKMEMORY], [:PIXIEPLATE, :FAIRIUMZ, :FAIRYMEMORY]
    ]
    type_items.each_with_index { |type, i|
      return false if pkmn.species == :ARCEUS && pkmn.form == i + 1 && !type_items[i][0..1].include?(pkmn.item)
      return false if pkmn.species == :SILVALLY && pkmn.form == i + 1 && pkmn.item != type_items[i][2]
    }
  end
  return false if pkmn.species == :DARMANITAN && pkmn.form == 1

  if pkmn.species == :GENESECT
    drives = [:SHOCKDRIVE, :BURNDRIVE, :CHILLDRIVE, :DOUSEDRIVE]
    drives.each_with_index { |drive, i|
      return false if pkmn.form == i + 1 && pkmn.item != drives[i]
    }
  end
  return false if pkmn.species == :AEGISLASH && pkmn.form != 0
  return false if pkmn.species == :WISHIWASHI && pkmn.form == 1
  return false if pkmn.species == :MINIOR && pkmn.form == 7
  return false if pkmn.species == :MIMIKYU && pkmn.form == 1
  return false if pkmn.species == :CRAMORANT && pkmn.form != 0
  return false if pkmn.species == :EISCUE && pkmn.form != 0
  return false if pkmn.species == :MORPEKO && pkmn.form != 0
  return false if pkmn.species == :ZACIAN && pkmn.form == 1 && pkmn.item != :RUSTEDSWORD
  return false if pkmn.species == :ZAMAZENTA && pkmn.form == 1 && pkmn.item != :RUSTEDSHIELD
  return false if pkmn.species == :ETERNATUS && pkmn.form == 1

  return true
end

################################################################################
# Move Check
# This is by Marcello & Kurotsune too
################################################################################
def preEvoLearnsetCheck(move, pkmn)
  previous = pbGetPreviousForm(pkmn.species, pkmn.form)
  return false if previous == [pkmn.species, pkmn.form]

  pre_evo = PokeBattle_Pokemon.new(previous[0], 1, $Trainer, false, previous[1])
  return pre_evo.SpeciesCompatible?(move) || preEvoLearnsetCheck(move, pre_evo)
end

def isSmeargleMove?(move, pkmn)
  return false if pkmn.species != :SMEARGLE
  return false if move == :CHATTER
  return false if $cache.moves[move].type == :SHADOW

  return true
end

def isDifferentFormMove?(move, pkmn)
  # Deoxys, Shaymin and Hoopa have form exclusive moves but don't lose them when they change form.
  return false unless [:DEOXYS, :SHAYMIN, :HOOPA].include?(pkmn.species)
  if Gen >= 9 && pkmn.species == :HOOPA
    return false if pkmn.form == 0 && move == :HYPERSPACEFURY
    return false if pkmn.form == 1 && move == :HYPERSPACEHOLE
  end
  for i in 0...$cache.pkmn[pkmn.species].forms.length
    deoxys = PokeBattle_Pokemon.new(pkmn.species, 100, $Trainer, false, i)
    return true if deoxys.SpeciesCompatible?(move)
  end

  return false
end

def isLegalMoves?(pkmn, moves = nil)
  incenseSpecies = pbGetBabySpecies(pkmn.species, pkmn.form)
  babySpecies = pbGetNonIncenseLowestSpecies(*incenseSpecies)

  if moves.nil?
    moves = pkmn.moves.map { |move| move.move }
  end

  return false if moves.uniq.length != moves.length

  for move in moves
    return false if Gen < 8 && Gen8Moves.include?(move)

    if !pkmn.SpeciesCompatible?(move)
      next if isSmeargleMove?(move, pkmn)
      next if isDifferentFormMove?(move, pkmn)
      next if preEvoLearnsetCheck(move, pkmn)
      next if incenseSpecies != babySpecies && $cache.pkmn[*babySpecies].EggMoves.include?(move)

      return false
    end
  end
  return true
end

################################################################################
# Level, IV, EV, and Item Check
################################################################################
def isLegalLevel?(pkmn)
  return pkmn.level.between?(1, 150)
end

def isLegalIVs?(pkmn)
  pkmn.iv.each { |iv| return false if iv < 0 || iv > 31 }
  return true
end

def isLegalEVs?(pkmn)
  pkmn.ev.each { |ev| return false if ev < 0 || ev > 255 }
  return pkmn.ev.sum <= 510
end

def isLegalItem?(pkmn)
  return true if !pkmn.item
  return false if $cache.items[pkmn.item].checkFlag?(:tm)
  return false if $cache.items[pkmn.item].checkFlag?(:keyitem)

  return true
end

def isLegalAbility?(pkmn)
  return true if $cache.pkmn[pkmn.species, pkmn.form].Abilities.include?(pkmn.ability)
  return true if $cache.pkmn[pkmn.species, pkmn.form].HiddenAbility == pkmn.ability
  return false
end

################################################################################
# All of them (Form, Move, Level, IV, EV)
################################################################################
def isLegal?(pkmn)
  return false if !isLegalForm?(pkmn)
  return false if !isLegalMoves?(pkmn)
  return false if !isLegalLevel?(pkmn)
  return false if !isLegalIVs?(pkmn)
  return false if !isLegalEVs?(pkmn)
  return false if !isLegalItem?(pkmn)
  return false if !isLegalAbility?(pkmn)

  return true
end

def isLegalParty?(party)
  party.each { |pkmn| return false if !isLegal?(pkmn) }
  return true
end

################################################################################
# Nickname & etc Check
################################################################################
def nicknameFilterCheck(trainer)
  for pokemon in trainer.party
    if !isLegalName?(pokemon.name.downcase)
      print("An inappropriate nickname has been detected in your party. Please remove or rename #{pokemon.name} if you want to access online.")
      return false
    end
  end
  return true
end

def usernameFilterCheck(username)
  if !isLegalName?(username.downcase)
    print("This username has been deemed inappropriate, please use another one.")
    return false
  end
  return true
end

def trainerNameFilterCheck(tname)
  if !isLegalName?(tname.downcase)
    print("This trainer name has been deemed inappropriate, please use another one.")
    return false
  end
  return true
end

def isLegalName?(name)
  illegalname = [
    "bitch", "cock", "cumshot", "cunt", "fuck", "masturbation", "nigga", "nigger", "penis", "pussy", "slut",
    "twat", "vulva", "wank", "dick", "creampie", "morningwood", "piss", "pussies", "vagina", "cunny", "whore",
    "chink", "hitler", "nazi", "cum", "ballsack", "peniis", "thot", "dildo"
  ]
  return false if illegalname.any? { |word| name.include?(word) }
  return false if (name.include? "fag") && !(name == "cofagrigus") || name.include?('kum') && name != "pyukumuku" || name == "spic" || name == "kike"

  return true
end

def onlineNameChange
  oldname = $Trainer.name
  trname = pbEnterPlayerName("Your new name?", 0, 12, $Trainer.name)
  loop do
    if trname == ""
      Kernel.pbMessage(_INTL("Your name cannot be blank."))
      trname = pbEnterPlayerName("Your new name?", 0, 12, $Trainer.name)
    else
      break
    end
  end
  $Trainer.name = trname
  Kernel.pbMessage(_INTL("The player's name was changed to {1}.", $Trainer.name))
  for pokemon in $Trainer.party
    if pokemon.ot == oldname
      pokemon.ot = $Trainer.name
    end
  end
  for i in 0..34
    for pokemon in $PokemonStorage[i]
      next if !pokemon

      if pokemon.ot == oldname
        pokemon.ot = $Trainer.name
      end
    end
  end
  for i in 0..1
    pokemon = $PokemonGlobal.daycare[i][0]
    next if !pokemon

    if pokemon.ot == oldname
      pokemon.ot = $Trainer.name
    end
  end
end

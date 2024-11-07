class RandomizerSettings
  attr_accessor :misc
  attr_accessor :pkmn
  attr_accessor :types
  attr_accessor :statics
  attr_accessor :moves
  attr_accessor :trainers
  attr_accessor :encounters
  attr_accessor :tms
  attr_accessor :tutors
  attr_accessor :items
  attr_reader :random
  attr_reader :randomItemCount

  def initRandom(seed)
    @random = Random.new(seed)
    $game_variables[:Randomizer_Seed] = seed
    $game_variables[:Randomizer_Settings] = self.to_s
    $game_variables[:Randomizer_Items] = @randomItemCount
  end

  "
        misc:
            limit to gen x
            allow megas?
            allow custom forms?
            allow evos from outside selected gens?

        pokemon traits:
            stats:
                shuffle self stats
                random of allocation of bst
                follow evo?
                    stores shuffled
                    stores ratios
            abilities:
                allow wonder guard? #shedinja retains wonder guard
                follow evo?
                ban trapping abils? #shadow tag, arena trap, magnet pull
            types:
                follow evo?
                dual type percentage. default 50
            evolutions:
                change impossible evos? #move reliant, only move randomizer
                #highest prio to lowest prio
                force new evo?
                limit 3 stage?
                force same type?
                similar str? #match target bst
        types:
            typechart:
                shuffle # efficacies are shuffled i.e. fire has fighting resistances and weaknesses, is physical in glitch
                random # num of res, weak, immu are maintained i.e. normal always has no res, 1 weak, 1 immu
                chaos # any num of res, weak, immu. immu and res may overlap in case of scrappy/ring target
                    % chance of res
                    % chance of weak
                    % chance of immu
        static mons:
            starter:
                select mon, add npc/modify rng machine
                randomize starters?
                similar bst? #start with within 10% and add 5% either direction till we find
                enforce two evos?
            statics:
                force legend to legend, normal to normal
            trades:
                give item?
                randomize given only
                randomize request only
                randomize both
        move data:
            power?
            accuracy?
            pp?
            move types?
            categories?
            movesets:
                prefer type?    # 40 type 60 random
                                # 10 normal 30 type2
                                # 20 type1 20 type2
                completely random?
                only metronome?
                scale damage? s.t. lower power moves are earlier
                ban drage/sonic
                force move on evolution?
                force % good damage move
        trainers:
            fill parties?
            rival carries starter?
            randomize trainer class names?
            randomize trainer names?
            force full evo at level? #30-95
            ensure megas?
            ensure zmoves?
            handling for pulse/rifts
            force gym type
        encounters:
            full random?
            1-to-1 area map?    # localized enc1 >> randomenc
            1-to-1 global map?  # global enc1 >> randomenc
            adds:
                similar str? #start with within 10% and add 5% either direction till we find
                type theme? #inaccessible in global mapping
            options:
                disable legends?
                set min catch rate: inc 51
                Held items?
        tms/hms:
            #work around hms
            force % good damage move
            compat:
                random (type) #90% if type share, 50% if move normal pokemon not, 25% regular
                random (full)
                always
        tutors:
            #no tutor rand, sorry!
            compat:
                random (type) #90% if type share, 50% if move normal pokemon not, 25% regular
                random (full)
                always
        items:
            field:
                STORY PROGRESSION ITEMS FOOL
                full random
                same item type # based on bag pocket, exceptions evo stones >> evo stones, crests >> crests, z stones >> z stones, megastones >> megastones
            marts:
                full random
                same item type # based on bag pocket, exceptions evo stones >> evo stones, crests >> crests, z stones >> z stones, megastones >> megastones
            pickup

    "
  # HEX BIT CONSTANTS
  # takes up x bytes in settings string
  MISC        = 1
  PKMN        = 12
  TYPES       = 8
  STATICS     = 6
  MOVES       = 1
  TRAINERS    = 5
  ENCOUNTERS  = 4
  TMS         = 3
  TUTORS      = 3
  ITEMS       = 2
  # HEX BIT CONSTANTS

  def initialize()
    Dir.mkdir("Randomizer Data") if !Dir.exist?("Randomizer Data")
    @randomItemCount = 0
    @misc = {                       # 4 bits
      :allowMegas => false,
      :allowLegendaries => true,
      :allowForms => false,
    }
    @pkmn = {                       # 48 bits
      :stats => { # 4 bits
        :flipped => false, # incompatible with below settings
        :shuffle => false,
        :random => false,
        :followEvolutions => false,
      },
      :abilities => {                 # 8 bits
        :random => false,
        :abilityCount => 3,

        :allowWonderGuard => false,
        :followEvolutions => false,
        :banTrappingAbilities => false,

      },
      :evolutions => {                # 8 bits
        :random => false,
        :changeImpossibleEvos => false,

        :forceNewEvos => false,
        :limitEvos => false,
        :forceTyping => false,
        :similarTarget => false
      },
      :types => {                     # 12 bits
        :random => false,
        :followEvolutions => false,

        :dualType => 50 # 7
      },
      :movesets => { # 16 bits
        :random => false,
        :preferType => false,

        :metronome => false,
        :scaleMoves => false,
        :banSetDamage => false,
        :newEvoMove => false,

        :forceGoodMoves => 0 # 7
      }
    }
    @types = { # 32 bits
      :shuffle => false,
      :random => false,
      :chaos => false,

      :allowQmarks? => false,
      :allowShadow? => false,

      :chaosResist => 0,              # 7

      :chaosWeak => 0,                # 7

      :chaosImmune => 0,              # 7
    }
    @statics = { # 24 bits
      :starters => { # 16
        :random => false,
        :similarBST => false,
        :forceThreeStage => false,

        :starter => 0, # 10
      },
      :statics => {                   # 4
        :random => false,
        :forceGrouping => false
      },
      :trades => {                    # 4
        :given => false,
        :requested => false,
        :addItem => false,
      }
    }
    @moves = {                      # 4 bits
      :power => false,
      :accuracy => false,
      :type => false,
      :category => false,
    }
    @trainers = {                   # 20 bits
      :random => false,
      :class => false,
      :name => false,
      :fillParties => false,

      :keepStarters => false,
      :ensureMega => false,
      :ensureZMove => false,
      :forceTypeTheme => false,

      :smartGeneration => false,
      :similarBST => false,
      :forceFullEvo => false,

      :forceFullEvoLevel => 30, # 7
    }
    @encounters = { # 16 bits
      :random => false,
      :areamap => false,
      :globalmap => false,

      :similarBST => false,
      :typeThemed => false,
      :disableLegends => false,
      :items => false,

      :minCatchRate => 0, # 8
    }
    @tms = { # 12 bits
      :random => false,
      :typeCompatibility => false,
      :randomCompatibility => false,
      :fullCompatibility => false,

      :forceGoodMoves => 0, # 7
    }
    @tutors = { # 12 bits
      :random => false,
      :typeCompatibility => false,
      :randomCompatibility => false,
      :fullCompatibility => false,

      :forceGoodMoves => 0, # 7
    }
    @items = { # 8 bits
      :field => {
        :random => false,
        :typeMatch => false
      },
      :mart => {
        :random => false,
        :typeMatch => false
      },

      :pickup => false
    }
  end

  def shouldRandomizeMoveNames?
    false
  end

  def to_s
    settings = miscToString + pkmnToString + typesToString + staticsToString + movesToString + trainersToString + encountersToString + tmsToString + tutorsToString + itemsToString
    return settings
  end

  def inspect
    self.to_s
  end

  def save
    exporttext = "#{self.to_s}\n#{@random.seed}\n#{@randomItemCount}"
    File.open("Randomizer Data/settings.txt", "w") { |f| f.write(exporttext) }
  end

  def load(string)
    spl = string.split("\n")
    string = spl[0]

    lower = 0; upper = MISC
    miscFromString(string[lower...upper])
    lower = upper; upper += PKMN
    pkmnFromString(string[lower...upper])
    lower = upper; upper += TYPES
    typesFromString(string[lower...upper])
    lower = upper; upper += STATICS
    staticsFromString(string[lower...upper])
    lower = upper; upper += MOVES
    movesFromString(string[lower...upper])
    lower = upper; upper += TRAINERS
    trainersFromString(string[lower...upper])
    lower = upper; upper += ENCOUNTERS
    encountersFromString(string[lower...upper])
    lower = upper; upper += TMS
    tmsFromString(string[lower...upper])
    lower = upper; upper += TUTORS
    tutorsFromString(string[lower...upper])
    lower = upper; upper += ITEMS
    itemsFromString(string[lower...upper])
    @randomItemCount = spl[2].to_i
    initRandom(spl[1].to_i)

    save()
  end

  def miscToString()
    ret = ""
    str = "0#{@misc[:allowMegas].to_i}#{@misc[:allowForms].to_i}#{@misc[:allowLegendaries].to_i}"
    ret += str.to_i(2).to_s(16)
    # puts ret.length
    return ret
  end

  def pkmnToString()
    ret = ""
    str = "#{@pkmn[:stats][:flipped].to_i}#{@pkmn[:stats][:shuffle].to_i}#{@pkmn[:stats][:random].to_i}#{@pkmn[:stats][:followEvolutions].to_i}"
    ret += str.to_i(2).to_s(16)
    str = "0#{@pkmn[:abilities][:random].to_i}"
    str += sprintf("%02b", @pkmn[:abilities][:abilityCount])
    ret += str.to_i(2).to_s(16)
    str = "0#{@pkmn[:abilities][:allowWonderGuard].to_i}#{@pkmn[:abilities][:followEvolutions].to_i}#{@pkmn[:abilities][:banTrappingAbilities].to_i}"
    ret += str.to_i(2).to_s(16)
    str = "00#{@pkmn[:evolutions][:random].to_i}#{@pkmn[:evolutions][:changeImpossibleEvos].to_i}"
    ret += str.to_i(2).to_s(16)
    str = "#{@pkmn[:evolutions][:forceNewEvos].to_i}#{@pkmn[:evolutions][:limitEvos].to_i}#{@pkmn[:evolutions][:forceTyping].to_i}#{@pkmn[:evolutions][:similarTarget].to_i}"
    ret += str.to_i(2).to_s(16)
    str = "00#{@pkmn[:types][:random].to_i}#{@pkmn[:types][:followEvolutions].to_i}"
    ret += str.to_i(2).to_s(16)
    ret += sprintf("%02x", @pkmn[:types][:dualType])
    str = "00#{@pkmn[:movesets][:random].to_i}#{@pkmn[:movesets][:preferType].to_i}"
    ret += str.to_i(2).to_s(16)
    str = "#{@pkmn[:movesets][:metronome].to_i}#{@pkmn[:movesets][:scaleMoves].to_i}#{@pkmn[:movesets][:banSetDamage].to_i}#{@pkmn[:movesets][:newEvoMove].to_i}"
    ret += str.to_i(2).to_s(16)
    ret += sprintf("%02x", @pkmn[:movesets][:forceGoodMoves])
    # puts ret.length
    return ret
  end

  def typesToString()
    ret = ""
    str = "0#{@types[:shuffle]}#{@types[:random]}#{@types[:chaos]}"
    ret += str.to_i(2).to_s(16)
    str = "00#{@types[:allowQmarks?]}#{@types[:allowShadow?]}"
    ret += str.to_i(2).to_s(16)
    ret += sprintf("%02x", @types[:chaosResist])
    ret += sprintf("%02x", @types[:chaosWeak])
    ret += sprintf("%02x", @types[:chaosImmune])
    # puts ret.length
    return ret
  end

  def staticsToString()
    ret = ""
    str = "0#{@statics[:starters][:random].to_i}#{@statics[:starters][:similarBST].to_i}#{@statics[:starters][:forceThreeStage].to_i}"
    ret += str.to_i(2).to_s(16)
    ret += sprintf("%03x", @statics[:starters][:starter])
    str = "00#{@statics[:statics][:random].to_i}#{@statics[:statics][:forceGrouping].to_i}"
    ret += str.to_i(2).to_s(16)
    str = "0#{@statics[:trades][:given].to_i}#{@statics[:trades][:requested].to_i}#{@statics[:trades][:addItem].to_i}"
    ret += str.to_i(2).to_s(16)
    # puts ret.length
    return ret
  end

  def movesToString()
    ret = ""
    str = "#{@moves[:power].to_i}#{@moves[:accuracy].to_i}#{@moves[:type].to_i}#{@moves[:category].to_i}"
    ret += str.to_i(2).to_s(16)
    # puts ret.length
    return ret
  end

  def trainersToString()
    ret = ""
    str = "#{@trainers[:random].to_i}#{@trainers[:class].to_i}#{@trainers[:name].to_i}#{@trainers[:fillParties].to_i}"
    ret += str.to_i(2).to_s(16)
    str = "#{@trainers[:keepStarters].to_i}#{@trainers[:ensureMega].to_i}#{@trainers[:ensureZMove].to_i}#{@trainers[:forceTypeTheme].to_i}"
    ret += str.to_i(2).to_s(16)
    str = "0#{@trainers[:smartGeneration].to_i}#{@trainers[:similarBST].to_i}#{@trainers[:forceFullEvo].to_i}"
    ret += str.to_i(2).to_s(16)
    ret += sprintf("%02x", @trainers[:forceFullEvoLevel])
    # puts ret.length
    return ret
  end

  def encountersToString()
    ret = ""
    str = "0#{@encounters[:random].to_i}#{@encounters[:areamap].to_i}#{@encounters[:globalmap].to_i}"
    ret += str.to_i(2).to_s(16)
    str = "#{@encounters[:similarBST].to_i}#{@encounters[:typeThemed].to_i}#{@encounters[:disableLegends].to_i}#{@encounters[:items].to_i}"
    ret += str.to_i(2).to_s(16)
    ret += sprintf("%02x", @encounters[:minCatchRate])
    # puts ret.length
    return ret
  end

  def tmsToString()
    ret = ""
    str = "#{@tms[:random].to_i}#{@tms[:typeCompatibility].to_i}#{@tms[:randomCompatibility].to_i}#{@tms[:fullCompatibility].to_i}"
    ret += str.to_i(2).to_s(16)
    ret += sprintf("%02x", @tms[:forceGoodMoves])
    # puts ret.length
    return ret
  end

  def tutorsToString()
    ret = ""
    str = "#{@tutors[:random].to_i}#{@tutors[:typeCompatibility].to_i}#{@tutors[:randomCompatibility].to_i}#{@tutors[:fullCompatibility].to_i}"
    ret += str.to_i(2).to_s(16)
    ret += sprintf("%02x", @tutors[:forceGoodMoves])
    # puts ret.length
    return ret
  end

  def itemsToString()
    ret = ""
    str = "#{@items[:field][:random].to_i}#{@items[:field][:typeMatch].to_i}#{@items[:mart][:random].to_i}#{@items[:mart][:typeMatch].to_i}"
    ret += str.to_i(2).to_s(16)
    str = "000#{@items[:pickup]}"
    ret += str.to_i(2).to_s(16)
    # puts ret.length
    return ret
  end

  def miscFromString(string)
    bin = "%0#{4 * MISC}d" % string.to_i(16).to_s(2)
    @misc[:allowMegas]                  = bin[1] == "1"
    @misc[:allowForms]                  = bin[2] == "1"
    @misc[:allowLegendaries]            = bin[3] == "1"
  end

  def pkmnFromString(string)
    bin                                         = "%0#{4 * PKMN}d" % string.to_i(16).to_s(2)
    @pkmn[:stats][:flipped]                     = bin[0] == "1"
    @pkmn[:stats][:shuffle]                     = bin[1] == "1"
    @pkmn[:stats][:random]                      = bin[2] == "1"
    @pkmn[:stats][:followEvolutions]            = bin[3] == "1"
    #                                           = bin[4]
    @pkmn[:abilities][:random]                  = bin[5] == "1"
    @pkmn[:abilities][:abilityCount]            = bin[6..7].to_i(2)
    #                                           = bin[8]
    @pkmn[:abilities][:allowWonderGuard]        = bin[9] == "1"
    @pkmn[:abilities][:followEvolutions]        = bin[10] == "1"
    @pkmn[:abilities][:banTrappingAbilities]    = bin[11] == "1"
    #                                           = bin[12]
    #                                           = bin[13]
    @pkmn[:evolutions][:random]                 = bin[14] == "1"
    @pkmn[:evolutions][:changeImpossibleEvos]   = bin[15] == "1"
    @pkmn[:evolutions][:forceNewEvos]           = bin[16] == "1"
    @pkmn[:evolutions][:limitEvos]              = bin[17] == "1"
    @pkmn[:evolutions][:forceTyping]            = bin[18] == "1"
    @pkmn[:evolutions][:similarTarget]          = bin[19] == "1"
    #                                           = bin[20]
    #                                           = bin[21]
    @pkmn[:types][:random]                      = bin[22] == "1"
    @pkmn[:types][:followEvolutions]            = bin[23] == "1"
    @pkmn[:types][:dualType]                    = bin[24...32].to_i(2)
    #                                           = bin[32]
    #                                           = bin[33]
    @pkmn[:movesets][:random]                   = bin[34] == "1"
    @pkmn[:movesets][:preferType]               = bin[35] == "1"
    @pkmn[:movesets][:metronome]                = bin[36] == "1"
    @pkmn[:movesets][:scaleMoves]               = bin[37] == "1"
    @pkmn[:movesets][:banSetDamage]             = bin[38] == "1"
    @pkmn[:movesets][:newEvoMove]               = bin[39] == "1"
    @pkmn[:movesets][:forceGoodMoves]           = bin[40..].to_i(2)
  end

  def typesFromString(string)
    bin = "%0#{4 * TYPES}d" % string.to_i(16).to_s(2)
    @types[:shuffle]        = bin[1] == "1"
    @types[:random]         = bin[2] == "1"
    @types[:chaos]          = bin[3] == "1"
    @types[:allowQmarks?]   = bin[6] == "1"
    @types[:allowShadow?]   = bin[7] == "1"
    @types[:chaosResist]    = bin[8...16].to_i(2)
    @types[:chaosWeak]      = bin[16...24].to_i(2)
    @types[:chaosImmune]    = bin[24...32].to_i(2)
  end

  def staticsFromString(string)
    bin = "%0#{4 * STATICS}d" % string.to_i(16).to_s(2)
    @statics[:starters][:random]            = bin[1] == "1"
    @statics[:starters][:similarBST]        = bin[2] == "1"
    @statics[:starters][:forceThreeStage] = bin[3] == "1"
    #                                       = bin[4]
    @statics[:starters][:starter]           = bin[5...15]
    #                                       = bin[16]
    #                                       = bin[17]
    @statics[:statics][:random]             = bin[18] == "1"
    @statics[:statics][:forceGrouping]      = bin[19] == "1"
    #                                       = bin[20]
    @statics[:trades][:given]               = bin[21] == "1"
    @statics[:trades][:requested]           = bin[22] == "1"
    @statics[:trades][:addItem]             = bin[23] == "1"
  end

  def movesFromString(string)
    bin = "%0#{4 * MOVES}d" % string.to_i(16).to_s(2)
    @moves[:power]                      = bin[0] == "1"
    @moves[:accuracy]                   = bin[1] == "1"
    @moves[:type]                       = bin[2] == "1"
    @moves[:category]                   = bin[3] == "1"
  end

  def trainersFromString(string)
    bin                             = "%0#{4 * TRAINERS}d" % string.to_i(16).to_s(2)
    @trainers[:random]              = bin[0] == "1"
    @trainers[:class]               = bin[1] == "1"
    @trainers[:name]                = bin[2] == "1"
    @trainers[:fillParties]         = bin[3] == "1"
    @trainers[:keepStarters]        = bin[4] == "1"
    @trainers[:ensureMega]          = bin[5] == "1"
    @trainers[:ensureZMove]         = bin[6] == "1"
    @trainers[:forceTypeTheme]      = bin[7] == "1"
    @trainers[:smartGeneration]     = bin[9] == "1"
    @trainers[:similarBST]          = bin[10] == "1"
    @trainers[:forceFullEvo]        = bin[11] == "1"
    @trainers[:forceFullEvoLevel]   = bin[12..].to_i(2)
  end

  def encountersFromString(string)
    bin                             = "%0#{4 * ENCOUNTERS}d" % string.to_i(16).to_s(2)
    @encounters[:random]            = bin[1] == "1"
    @encounters[:areamap]           = bin[2] == "1"
    @encounters[:globalmap]         = bin[3] == "1"
    @encounters[:similarBST]        = bin[4] == "1"
    @encounters[:typeThemed]        = bin[5] == "1"
    @encounters[:disableLegends]    = bin[6] == "1"
    @encounters[:items]             = bin[7] == "1"
    @encounters[:minCatchRate]      = bin[8..].to_i(2)
  end

  def tmsFromString(string)
    bin = "%0#{4 * TMS}d" % string.to_i(16).to_s(2)
    @tms[:random]               = bin[0] == "1"
    @tms[:typeCompatibility]    = bin[1] == "1"
    @tms[:randomCompatibility]  = bin[2] == "1"
    @tms[:fullCompatibility]    = bin[3] == "1"
    @tms[:forceGoodMoves]       = bin[4..].to_i(2)
  end

  def tutorsFromString(string)
    bin = "%0#{4 * TUTORS}d" % string.to_i(16).to_s(2)
    @tutors[:random] = bin[0] == "1"
    @tutors[:typeCompatibility]     = bin[1] == "1"
    @tutors[:randomCompatibility]   = bin[2] == "1"
    @tutors[:fullCompatibility]     = bin[3] == "1"
    @tutors[:forceGoodMoves] = bin[4..].to_i(2)
  end

  def itemsFromString(string)
    bin = "%0#{4 * ITEMS}d" % string.to_i(16).to_s(2)
    @items[:field][:random]     = bin[0] == "1"
    @items[:field][:typeMatch]  = bin[1] == "1"
    @items[:mart][:random]      = bin[2] == "1"
    @items[:mart][:typeMatch]   = bin[3] == "1"
    @items[:pickup]             = bin[7] == "1"
  end

  def restrictedMons
    return [:ARCEUS]
  end

  def restrictedItems
    return []
  end

  def trappingAbilities
    [:ARENATRAP, :MAGNETPULL, :SHADOWTAG]
  end

  def badAbilities
    [:DEFEATIST, :TRUANT, :SLOWSTART, :KLUTZ, :STALL]
  end
end


# $Randomizer = Randomizer.new(RandomizerSettings.new)
# $Randomizer.randomize

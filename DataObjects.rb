class DataObject
  attr_reader :flags

  def checkFlag?(flag, default = false)
    return @flags.fetch(flag, default)
  end
end

class MonWrapper
  attr_reader :flags
  attr_reader :mon
  attr_reader :pokemonData
  attr_reader :forms
  attr_reader :formInit

  def initialize(monsym, data)
    @flags = {}
    @mon = monsym

    @pokemonData = {}
    @forms = {}
    data.each { |key, value|
      next if key.is_a?(Symbol)

      @pokemonData[key] = MonData.new(monsym, value)
      @forms[@forms.length] = key
    }
    data.delete_if { |key, value| @forms.values.include?(key) }

    @formInit = {}
    if data[:OnCreation] && !data[:OnCreation].is_a?(Hash)
      @formInit = extractFormProc(data[:OnCreation], mon)
    end
    data.delete(:OnCreation)

    data.each { |key, value| @flags.store(key, value) }
  end

  def checkFlag?(flag, default = false)
    return @flags.fetch(flag, default)
  end

  def hasForm?(form)
    return true if form.nil?

    form = @forms[form] if form.is_a?(Numeric) && @forms.has_key?(form)
    return @pokemonData.has_key?(form)
  end

  def [](form)
    formnum = -1
    if form.is_a?(Numeric)
      formnum = form
      form = @forms[form]
    end
    ret = @pokemonData[form]
    if !ret
      ret = @pokemonData.values[0]
      puts "Form #{@mon} #{formnum > -1 ? "#{formnum}:" : ""}#{form} does not exist!"
    end
    return ret
  end

  def export
    exporttext = "  #{@mon.inspect} => {\n"
    for form in 0...@forms.length
      formname = @forms[form]
      exporttext += "    \"#{@forms[form]}\" => {\n"
      exporttext += @pokemonData[formname].export
      exporttext += "    },\n\n"
    end
    exporttext += "    :OnCreation => #{@formInit},\n" if @formInit
    @flags.each { |k, v| exporttext += "    #{k.inspect} => #{v.inspect},\n" }
    exporttext += "  },\n\n"
    return exporttext
  end
end

class MonDataHash < Hash
  def [](*args)
    species = args[0]
    wrapper = self.fetch(species)
    if args.length == 1
      return wrapper
    else
      form = args[1]
      return wrapper[form]
    end
  end
end

class MonData < DataObject
  attr_reader :species
  attr_reader :name
  attr_reader :dexnum
  attr_reader :Type1
  attr_reader :Type2
  attr_reader :BaseStats
  attr_reader :EVs
  attr_reader :Abilities
  attr_reader :HiddenAbility
  attr_reader :GrowthRate
  attr_reader :GenderRatio
  attr_reader :BaseEXP
  attr_reader :CatchRate
  attr_reader :Happiness
  attr_reader :EggSteps
  attr_reader :EggMoves
  attr_reader :Moveset
  attr_reader :compatiblemoves
  attr_reader :moveexceptions
  attr_reader :shadowmoves
  attr_reader :Color
  attr_reader :Habitat
  attr_reader :EggGroups
  attr_reader :Height
  attr_reader :Weight
  attr_reader :kind
  attr_reader :dexentry
  attr_reader :BattlerPlayerY
  attr_reader :BattlerEnemyY
  attr_reader :BattlerAltitude
  attr_reader :BattlerShadow
  attr_reader :preevo
  attr_reader :evolutions
  attr_reader :MegaEvolutions
  attr_reader :RelearnerMoves
  attr_reader :baseForm

  def initialize(species, data)
    @species = species
    @flags = {}
    @baseForm = 0
    data.each do |key, value|
      case key
        when :name             then @name             = value
        when :dexnum           then @dexnum           = value
        when :Type1            then @Type1            = value
        when :Type2            then @Type2            = value
        when :BaseStats        then @BaseStats        = value
        when :EVs              then @EVs              = value
        when :Abilities        then @Abilities        = value
        when :HiddenAbility    then @HiddenAbility    = value
        when :GrowthRate       then @GrowthRate       = value
        when :GenderRatio      then @GenderRatio      = value
        when :BaseEXP          then @BaseEXP          = value
        when :CatchRate        then @CatchRate        = value
        when :Happiness        then @Happiness        = value
        when :EggSteps         then @EggSteps         = value
        when :EggMoves         then @EggMoves         = value
        when :Moveset          then @Moveset          = value
        when :compatiblemoves  then @compatiblemoves  = value
        when :moveexceptions   then @moveexceptions   = value
        when :shadowmoves      then @shadowmoves      = value
        when :Color            then @Color            = value
        when :Habitat          then @Habitat          = value
        when :EggGroups        then @EggGroups        = value
        when :Height           then @Height           = value
        when :Weight           then @Weight           = value
        when :kind             then @kind             = value
        when :dexentry         then @dexentry         = value
        when :BattlerPlayerY   then @BattlerPlayerY   = value
        when :BattlerEnemyY    then @BattlerEnemyY    = value
        when :BattlerAltitude  then @BattlerAltitude  = value
        when :BattlerShadow    then @BattlerShadow    = value
        when :preevo           then @preevo           = value
        when :evolutions       then @evolutions       = value
        when :MegaEvolutions   then @MegaEvolutions   = value
        when :RelearnerMoves   then @RelearnerMoves   = value
        when :baseForm         then @baseForm         = value
        else @flags[key] = value
      end
    end
  end

  def name
    return @name || $cache.pkmn[@species, @baseForm].instance_variable_get(:@name) || @species
  end

  def dexnum
    return @dexnum || $cache.pkmn[@species, @baseForm].instance_variable_get(:@dexnum) || -1
  end

  def Type1
    return @Type1 || $cache.pkmn[@species, @baseForm].instance_variable_get(:@Type1) || :QMARKS
  end

  def Type2
    # Fixes secondary type being removed for Galarian Farfetch'd and Mega Aggron
    type = @Type2 || $cache.pkmn[@species, @baseForm].instance_variable_get(:@Type2) || nil
    return nil if type == self.Type1

    return type
  end

  def BaseStats
    return @BaseStats || $cache.pkmn[@species, @baseForm].instance_variable_get(:@BaseStats) || [48, 72, 48, 72, 48, 48]
  end

  def EVs
    return @EVs || $cache.pkmn[@species, @baseForm].instance_variable_get(:@EVs) || Array.new(6, 0)
  end

  def Abilities
    return @Abilities || $cache.pkmn[@species, @baseForm].instance_variable_get(:@Abilities) || [:ILLUMINATE]
  end

  def HiddenAbility
    # Fixes Galarian Articuno, Zapdos, Moltres and Dusk Lycanroc to not inherit hidden ability from the base form
    ability = @HiddenAbility || $cache.pkmn[@species, @baseForm].instance_variable_get(:@HiddenAbility) || nil
    return nil if self.Abilities.include?(ability)

    return ability
  end

  def GrowthRate
    return @GrowthRate || $cache.pkmn[@species, @baseForm].instance_variable_get(:@GrowthRate) || :MediumFast
  end

  def GenderRatio
    return @GenderRatio || $cache.pkmn[@species, @baseForm].instance_variable_get(:@GenderRatio) || :FemHalf
  end

  def BaseEXP
    return @BaseEXP || $cache.pkmn[@species, @baseForm].instance_variable_get(:@BaseEXP) || 118
  end

  def CatchRate
    return @CatchRate || $cache.pkmn[@species, @baseForm].instance_variable_get(:@CatchRate) || 225
  end

  def Happiness
    return @Happiness || $cache.pkmn[@species, @baseForm].instance_variable_get(:@Happiness) || 70
  end

  def EggSteps
    return @EggSteps || $cache.pkmn[@species, @baseForm].instance_variable_get(:@EggSteps) || 10455
  end

  def EggMoves
    return @EggMoves || $cache.pkmn[@species, @baseForm].instance_variable_get(:@EggMoves) || []
  end

  def Moveset
    return @Moveset || $cache.pkmn[@species, @baseForm].instance_variable_get(:@Moveset) || [1, :HIDDENPOWER]
  end

  def compatiblemoves
    return @compatiblemoves || $cache.pkmn[@species, @baseForm].instance_variable_get(:@compatiblemoves) || []
  end

  def moveexceptions
    return @moveexceptions || $cache.pkmn[@species, @baseForm].instance_variable_get(:@moveexceptions) || PBStuff::UNIVERSALTMS
  end

  def shadowmoves
    return @shadowmoves || $cache.pkmn[@species, @baseForm].instance_variable_get(:@shadowmoves) || nil
  end

  def Color
    return @Color || $cache.pkmn[@species, @baseForm].instance_variable_get(:@Color) || "Black"
  end

  def Habitat
    return @Habitat || $cache.pkmn[@species, @baseForm].instance_variable_get(:@Habitat) || nil
  end

  def EggGroups
    return @EggGroups || $cache.pkmn[@species, @baseForm].instance_variable_get(:@EggGroups) || :Undiscovered
  end

  def Height
    return @Height || $cache.pkmn[@species, @baseForm].instance_variable_get(:@Height) || 5
  end

  def Weight
    return @Weight || $cache.pkmn[@species, @baseForm].instance_variable_get(:@Weight) || 50
  end

  def kind
    return @kind || $cache.pkmn[@species, @baseForm].instance_variable_get(:@kind) || "Unknown"
  end

  def dexentry
    return @dexentry || $cache.pkmn[@species, @baseForm].instance_variable_get(:@dexentry) || "Dex entry not defined."
  end

  def BattlerPlayerY
    return @BattlerPlayerY || $cache.pkmn[@species, @baseForm].instance_variable_get(:@BattlerPlayerY) || 0
  end

  def BattlerEnemyY
    return @BattlerEnemyY || $cache.pkmn[@species, @baseForm].instance_variable_get(:@BattlerEnemyY) || 0
  end

  def BattlerAltitude
    return @BattlerAltitude || $cache.pkmn[@species, @baseForm].instance_variable_get(:@BattlerAltitude) || 0
  end

  def BattlerShadow
    return @BattlerShadow unless @BattlerShadow.nil?
    return $cache.pkmn[@species, @baseForm].instance_variable_get(:@BattlerShadow)
  end

  def preevo
    return @preevo || $cache.pkmn[@species, @baseForm].instance_variable_get(:@preevo) || nil
  end

  def evolutions
    return @evolutions || $cache.pkmn[@species, @baseForm].instance_variable_get(:@evolutions) || nil
  end

  def MegaEvolutions
    return @MegaEvolutions || $cache.pkmn[@species, @baseForm].instance_variable_get(:@MegaEvolutions) || nil
  end

  def RelearnerMoves
    return @RelearnerMoves || $cache.pkmn[@species, @baseForm].instance_variable_get(:@RelearnerMoves) || []
  end

  def checkFlag?(flag, default = false, baseCheck = false)
    v = @flags.fetch(flag, default)
    v = $cache.pkmn[@species, @baseForm].checkFlag?(flag, default, true) if v.nil? && !baseCheck
    v = default if v.nil?
    return v
  end

  def export
    exporttext = ""
    exporttext += "      :name => \"#{@name}\",\n" if @name
    exporttext += "      :dexnum => #{@dexnum},\n" if @dexnum
    exporttext += "      :Type1 => :#{@Type1},\n" if @Type1
    exporttext += "      :Type2 => :#{@Type2},\n" if @Type2 # && (@Type1 != @Type2) # Same type is necessary for M-Aggron
    exporttext += "      :BaseStats => #{@BaseStats.inspect},\n" if @BaseStats
    exporttext += "      :EVs => #{@EVs.inspect},\n" if @EVs
    exporttext += "      :Abilities => #{@Abilities},\n" if @Abilities
    exporttext += "      :HiddenAbility => :#{@HiddenAbility},\n" if @HiddenAbility
    exporttext += "      :GrowthRate => :#{@GrowthRate},\n" if @GrowthRate
    exporttext += "      :GenderRatio => :#{@GenderRatio},\n" if @GenderRatio
    exporttext += "      :BaseEXP => #{@BaseEXP},\n" if @BaseEXP
    exporttext += "      :CatchRate => #{@CatchRate},\n" if @CatchRate
    exporttext += "      :Happiness => #{@Happiness},\n" if @Happiness
    exporttext += "      :EggSteps => #{@EggSteps},\n" if @EggSteps
    if @EggMoves
      if @EggMoves.empty?
        exporttext += "      :EggMoves => [],\n"
      else
        exporttext += "      :EggMoves => [\n"
        exporttext += "        "
        i = 0
        for eggmove in @EggMoves
          exporttext += ":#{eggmove}, "
          i += eggmove.length + 3
          if i > 120 && eggmove != @EggMoves.last # 120 is about 10 moves, and should be the majority of the screen on a regular sized, 100% zoom monitor.
            exporttext.rstrip!
            exporttext += "\n        "
            i = 0
          end
        end
        exporttext.rstrip!
        exporttext += "\n      ],\n"
      end
    end
    if @preevo
      exporttext += "      :preevo => {\n"
      exporttext += "        :species => :#{@preevo[:species]},\n"
      exporttext += "        :form => #{@preevo[:form]},\n"
      exporttext += "      },\n"
    end
    if @RelearnerMoves
      if @RelearnerMoves.empty?
        exporttext += "      :RelearnerMoves => [],\n"
      else
        exporttext += "      :RelearnerMoves => [\n"
        exporttext += "        "
        i = 0
        for j in @RelearnerMoves
          exporttext += ":#{j}, "
          i += j.length + 3
          if i > 120 && j != @RelearnerMoves.last
            exporttext.rstrip!
            exporttext += "\n        "
            i = 0
          end
        end
        exporttext.rstrip!
        exporttext += "\n      ],\n"
      end
    end
    if @Moveset
      check = 1
      exporttext += "      :Moveset => [\n"
      for move in @Moveset
        exporttext += "        [#{move[0]}, :#{move[1]}],\n"
        check += 1
      end
      exporttext += "      ],\n"
    end
    if @compatiblemoves
      if @compatiblemoves.empty?
        exporttext += "      :compatiblemoves => [],\n"
      else
        exporttext += "      :compatiblemoves => [\n"
        exporttext += "        "
        i = 0
        dupes = []
        for j in @compatiblemoves
          next if PBStuff::UNIVERSALTMS.include?(j)
          next if dupes.include?(j)

          dupes.push(j)
          exporttext += ":#{j}, "
          i += j.length + 3
          if i > 120 && j != @compatiblemoves.last
            exporttext.rstrip!
            exporttext += "\n        "
            i = 0
          end
        end
        exporttext.rstrip!
        exporttext += "\n      ],\n"
      end
    end
    if @moveexceptions
      if @moveexceptions.empty?
        exporttext += "      :moveexceptions => [],\n"
      else
        exporttext += "      :moveexceptions => [\n"
        exporttext += "        "
        i = 0
        for j in @moveexceptions
          exporttext += ":#{j}, "
          i += j.length + 3
          if i > 120 && j != @moveexceptions.last
            exporttext.rstrip!
            exporttext += "\n        "
            i = 0
          end
        end
        exporttext.rstrip!
        exporttext += "\n      ],\n"
      end
    end
    if @shadowmoves
      if @shadowmoves.empty?
        exporttext += "      :shadowmoves => [],\n"
      else
        exporttext += "      :shadowmoves => [\n"
        exporttext += "        "
        i = 0
        for shadowmove in @shadowmoves
          exporttext += ":#{shadowmove}, "
          i += shadowmove.length + 3
          if i > 120 && shadowmove != @shadowmoves.last
            exporttext.rstrip!
            exporttext += "\n        "
            i = 0
          end
        end
        exporttext.rstrip!
        exporttext += "\n      ],\n"
      end
    end
    exporttext += "      :Color => \"#{@Color.to_s}\",\n" if @Color
    exporttext += "      :Habitat => \"#{@Habitat.to_s}\",\n" if @Habitat
    exporttext += "      :EggGroups => #{@EggGroups.inspect},\n" if @EggGroups
    exporttext += "      :Height => #{@Height},\n" if @Height
    exporttext += "      :Weight => #{@Weight},\n" if @Weight
    exporttext += "      :kind => \"#{@kind}\",\n" if @kind
    exporttext += "      :dexentry => \"#{@dexentry}\",\n" if @dexentry
    exporttext += "      :BattlerPlayerY => #{@BattlerPlayerY},\n" if @BattlerPlayerY
    exporttext += "      :BattlerEnemyY => #{@BattlerEnemyY},\n" if @BattlerEnemyY
    # exporttext += "      :BattlerAltitude => #{@BattlerAltitude},\n" if @BattlerAltitude
    exporttext += "      :BattlerShadow => #{@BattlerShadow},\n" unless @BattlerShadow.nil?
    if @evolutions
      evos = @evolutions
      exporttext += "      :evolutions => [\n"
      for evo in evos
        if evo.is_a?(Array)
          exporttext += "        {species: #{evo[0].inspect}, method: #{evo[1].inspect}, parameter: #{evo[2].inspect}},"
          exporttext += "\n"
        else
          exporttext += "        {species: #{evo[:species].inspect}, method: #{evo[:method].inspect}, parameter: #{evo[:parameter].inspect}"
          exporttext += ", form: #{evo[:form].inspect}" if evo[:form]
          exporttext += "},"
          exporttext += "\n"
        end
      end
      exporttext += "      ],\n"
    end
    if @MegaEvolutions
      exporttext += "      :MegaEvolutions => {\n"
      @MegaEvolutions.each { |method, form|
        exporttext += "        #{method.inspect} => #{form.inspect},\n"
      }
      exporttext += "      },\n"
    end
    @flags.each { |k, v| exporttext += "      #{k.inspect} => #{v.inspect},\n" }
    return exporttext
  end
end

class MoveData < DataObject
  attr_reader :move
  attr_reader :name
  attr_reader :function
  attr_reader :type
  attr_reader :category
  attr_reader :basedamage
  attr_reader :accuracy
  attr_reader :maxpp
  attr_reader :target
  attr_reader :desc
  attr_reader :priority

  def initialize(movesym, data)
    @flags = {}
    @move = movesym
    data.each do |key, value|
      case key
        when :name then           @name            = value
        when :function then       @function        = value
        when :type then           @type            = value
        when :category then       @category        = value
        when :basedamage then     @basedamage      = value
        when :accuracy then       @accuracy        = value
        when :maxpp then          @maxpp           = value
        when :target then         @target          = value
        when :desc then           @desc            = value
        when :priority then       @priority        = value ? value : 0
        else @flags[key] = value
      end
    end
  end

  def export
    output = "#{@move.inspect} => {\n"
    output += "    :name => #{name.inspect},\n"
    output += sprintf("    :function => 0x%03X,\n", @function)
    output += "    :type => #{@type.inspect},\n"
    output += "    :category => #{@category.inspect},\n"
    output += "    :basedamage => #{@basedamage},\n"
    output += "    :accuracy => #{@accuracy},\n"
    output += "    :maxpp => #{@maxpp},\n"
    output += "    :target => #{@target.inspect},\n"
    output += "    :priority => #{@priority},\n" if @priority && @priority != 0
    @flags.each { |key, value| output += "    #{key.inspect} => #{value.inspect},\n" }
    output += "},\n"
    return output
  end
end

class ItemData < DataObject
  attr_reader :item
  attr_reader :name
  attr_reader :desc
  attr_reader :price

  def initialize(itemsym, data)
    @flags = {}
    @item = itemsym
    data.each do |key, value|
      case key
        when :name then         @name         = value
        when :desc then         @desc         = value
        when :price then        @price        = value
        else @flags[key] = value
      end
    end
  end
end

class AbilityData < DataObject
  attr_reader :ability
  attr_reader :name
  attr_reader :desc
  attr_reader :fullName
  attr_reader :fullDesc

  def initialize(abilsym, data)
    @ability  = abilsym
    @name     = data[:name]
    @desc     = data[:desc]
    @fullName = data[:fullName]
    @fullName = @name if @fullName.nil?
    @fullDesc = data[:fullDesc]
    @fullDesc = @desc if @fullDesc.nil?
  end
end

class MapMetadata < DataObject
  # metadata
  attr_reader :mapid
  attr_reader :HealingSpot
  attr_reader :MapPosition
  attr_reader :Outdoor
  attr_reader :ShowArea
  attr_reader :Bicycle
  attr_reader :Weather
  attr_reader :DiveMap
  attr_reader :SurfaceMap
  attr_reader :DarkMap
  attr_reader :SafariMap
  attr_reader :SnapEdges
  attr_reader :BattleBack
  attr_reader :WildBattleBGM
  attr_reader :TrainerBattleBGM
  attr_reader :WildVictoryME
  attr_reader :TrainerVictoryME
  attr_reader :MapSize
  attr_reader :Switches
  # encounters
  attr_reader :Land
  attr_reader :Cave
  attr_reader :Water
  attr_reader :RockSmash
  attr_reader :OldRod
  attr_reader :GoodRod
  attr_reader :SuperRod
  attr_reader :Headbutt
  attr_reader :LandMorning
  attr_reader :LandDay
  attr_reader :LandNight
  attr_reader :landrate
  attr_reader :caverate
  attr_reader :waterrate
  attr_reader :BugContest

  def initialize(key, encounters, metadata)
    @mapid = key
    metadata.each do |key, value|
      case key
        when :Outdoor then            @Outdoor            = value ? true : false
        when :ShowArea then           @ShowArea           = value ? true : false
        when :Bicycle then            @Bicycle            = value ? true : false
        when :Weather then            @Weather            = value
        when :DiveMap then            @DiveMap            = value
        when :SurfaceMap then         @SurfaceMap         = value
        when :DarkMap then            @DarkMap            = value ? true : false
        when :SafariMap then          @SafariMap          = value ? true : false
        when :SnapEdges then          @SnapEdges          = value ? true : false
        when :BattleBack then         @BattleBack         = value
        when :HealingSpot then        @HealingSpot        = value
        when :MapPosition then        @MapPosition        = value
        when :WildBattleBGM then      @WildBattleBGM      = value
        when :TrainerBattleBGM then   @TrainerBattleBGM   = value
        when :WildVictoryME then      @WildVictoryME      = value
        when :TrainerVictoryME then   @TrainerVictoryME   = value
        when :MapSize then            @MapSize            = value ? true : false
        when :Switches then           @Switches           = value
      end
    end
    encounters = {} if !encounters
    # encounters
    @Land               = encounters[:Land] ? encounters[:Land] : nil
    @Cave               = encounters[:Cave] ? encounters[:Cave] : nil
    @Water              = encounters[:Water] ? encounters[:Water] : nil
    @RockSmash          = encounters[:RockSmash] ? encounters[:RockSmash] : nil
    @OldRod             = encounters[:OldRod] ? encounters[:OldRod] : nil
    @GoodRod            = encounters[:GoodRod] ? encounters[:GoodRod] : nil
    @SuperRod           = encounters[:SuperRod] ? encounters[:SuperRod] : nil
    @Headbutt           = encounters[:Headbutt] ? encounters[:Headbutt] : nil
    @LandMorning        = encounters[:LandMorning] ? encounters[:LandMorning] : nil
    @LandDay            = encounters[:LandDay] ? encounters[:LandDay] : nil
    @LandNight          = encounters[:LandNight] ? encounters[:LandNight] : nil
    @BugContest         = encounters[:BugContest] ? encounters[:BugContest] : nil
    # rates
    @landrate           = encounters[:landrate]
    @caverate           = encounters[:caverate]
    @waterrate          = encounters[:waterrate]
  end

  def syncMapData(region, point, flyData)
    @MapPosition = [region, point[0], point[1]]
    @HealingSpot = flyData
  end
end

class PlayerData < DataObject
  attr_reader :id
  attr_reader :tclass
  attr_reader :walk
  attr_reader :run
  attr_reader :bike
  attr_reader :surf
  attr_reader :dive
  attr_reader :fishing
  attr_reader :surffish
  attr_reader :ride

  def initialize(key, data)
    @id = key
    @tclass     = data[:tclass]
    @walk       = data[:walk]
    @run        = data[:run]
    @bike       = data[:bike]
    @surf       = data[:surf]
    @dive       = data[:dive]
    @fishing    = data[:fishing]
    @surffish   = data[:surffish]
    @ride       = data[:ride]
  end
end

class TypeData
  attr_reader :type
  attr_reader :name
  attr_reader :weak
  attr_reader :resist
  attr_reader :immune
  attr_reader :specialtype

  def initialize(typesym, data)
    @type = typesym
    @name = data.fetch(:name, "")
    @weak = data.fetch(:weaknesses, [])
    @resist = data.fetch(:resistances, [])
    @immune = data.fetch(:immunities, [])
    @specialtype = data.fetch(:specialtype, false)
  end

  def checkFlag?(flag, default = false)
    return @flags.fetch(flag, default)
  end

  def weak?(type)
    return @weak.include?(type)
  end

  def specialtype?(type)
    return @specialtype
  end

  def resists?(type)
    return @resist.include?(type)
  end

  def immune?(type)
    return @immune.include?(type)
  end
end

class TrainerData < DataObject
  attr_reader :ttype
  attr_reader :title
  attr_reader :skill
  attr_reader :moneymult
  attr_reader :battleBGM
  attr_reader :winBGM
  attr_reader :teams
  attr_reader :trainerID
  attr_reader :sprite
  attr_reader :flags

  def initialize(ttypesym, data)
    @ttype = ttypesym
    @flags = {}
    data.each do |key, value|
      case key
        when :title     then @title = value
        when :trainerID then @trainerID = value
        when :skill     then @skill      = value
        when :moneymult then @moneymult  = value
        when :battleBGM then @battleBGM  = value
        when :winBGM    then @winBGM     = value
        when :sprite    then @sprite = value
        else @flags[key] = value
      end
    end
  end

  def checkFlag?(flag, default = false)
    return @flags.fetch(flag, default)
  end
end

class FEData
  attr_accessor :name
  attr_accessor :fieldAppSwitch
  attr_accessor :message
  attr_accessor :graphic
  attr_accessor :secretPower
  attr_accessor :naturePower
  attr_accessor :mimicry
  attr_accessor :seeddata
  attr_accessor :fieldtypedata
  attr_accessor :fieldmovedata
  attr_accessor :movemessagelist
  attr_accessor :typemessagelist
  attr_accessor :changemessagelist
  attr_accessor :statusMods
  attr_accessor :fieldchangeconditions
  # Overlay stuff
  attr_accessor :overlaymovedata
  attr_accessor :overlaytypedata
  attr_accessor :overlayStatusMods
  attr_accessor :overlaymovemessagelist
  attr_accessor :overlaytypemessagelist

  def initialize
    @name = nil
    @message = nil
    @graphic = "IndoorA"
    @secretPower = "TRIATTACK"
    @naturePower = :TRIATTACK
    @mimicry = :NORMAL
    @fieldmovedata = {}
    @fieldtypedata = {}
    @seeddata = {}
    @movemessagelist = {}
    @typemessagelist = {}
    @changemessagelist = {}
    @statusMods = []
    # Overlay stuff
    @overlaymovedata = {}
    @overlaytypedata = {}
    @overlayStatusMods = []
    @overlaymovemessagelist = {}
    @overlaytypemessagelist = {}
  end
end

class BossData < DataObject
  attr_accessor :mon
  attr_accessor :name
  attr_accessor :barGraphic
  attr_accessor :entryText
  attr_accessor :immunities
  attr_accessor :shieldCount
  attr_accessor :capturable
  attr_accessor :canrun
  attr_accessor :onBreakEffects
  attr_accessor :onEntryEffects
  attr_accessor :moninfo
  attr_accessor :sosDetails
  attr_accessor :chargeAttack
  attr_accessor :randomSetChanges

  def initialize(monsym, data)
    @flags = {}
    @mon = monsym
    data.each do |key, value|
      case key
        when :name            then @name            = value
        when :immunities      then @immunities      = value
        when :barGraphic      then @barGraphic      = value
        when :entryText       then @entryText       = value
        when :shieldCount     then @shieldCount     = value
        when :capturable      then @capturable      = value
        when :canrun          then @canrun          = value
        when :moninfo         then @moninfo         = value
        when :onBreakEffects  then @onBreakEffects  = value
        when :onEntryEffects  then @onEntryEffects  = value
        when :sosDetails      then @sosDetails      = value
        when :chargeAttack      then @chargeAttack = value
        when :randomSetChanges  then @randomSetChanges = value
        else @flags[key] = value
      end
    end
  end
end

class NatureData
  attr_accessor :name
  attr_accessor :nature
  attr_accessor :incStat
  attr_accessor :decStat
  attr_accessor :like
  attr_accessor :dislike

  def initialize(naturesym, data)
    @flags = {}
    @nature = naturesym
    data.each { |key, value|
      case key
        when :name      then  @name     = value
        when :incStat   then  @incStat  = value
        when :decStat   then  @decStat  = value
        when :like      then  @like     = value
        when :dislike   then  @dislike  = value
      end
    }
  end
end

class TownMapData < DataObject
  attr_reader :name
  attr_reader :pos
  attr_reader :poi
  attr_reader :flyData
  attr_reader :region

  def initialize(pos, data, region)
    @flags = {}
    @pos = pos
    @region = region
    data.each { |key, value|
      case key
        when :name    then  @name     = value
        when :poi     then  @poi      = value
        when :flyData then  @flyData  = value
        else @flags[key] = value
      end
    }
  end
end

class BTPokemon < DataObject
  attr_accessor :species
  attr_accessor :item
  attr_accessor :nature
  attr_accessor :moves
  attr_accessor :ev
  attr_accessor :form
  attr_accessor :ability
  attr_accessor :hptype

  def initialize(data)
    @species  = data[:species]  ? data[:species] : :BULBASAUR
    @item     = data[:item]     ? data[:item] : nil
    @nature   = data[:nature]   ? data[:nature] : :HARDY
    @moves    = data[:moves]    ? data[:moves] : nil
    @ev       = data[:ev]       ? data[:ev] : nil
    @form     = data[:form]     ? data[:form] : 0
    @ability  = data[:ability]  ? data[:ability] : nil
    @hptype   = data[:hptype]   ? data[:hptype] : nil
    @flags    = {}
    data.each { |key, value|
      var = "@" + key.to_s
      if !self.instance_variables.include?(var.to_sym)
        @flags.store(key, value)
      end
    }
  end

  def checkFlag?(flag, default = false)
    return @flags.fetch(flag, default)
  end
end

class BTTrainerData < DataObject
  attr_accessor :name
  attr_accessor :tclass
  attr_accessor :introSpeech
  attr_accessor :winSpeech
  attr_accessor :loseSpeech
  attr_accessor :monIndexes

  def initialize(data)
    @name         = data[:name]
    @tclass       = data[:tclass]
    @introSpeech  = data[:introSpeech]
    @winSpeech    = data[:winSpeech]
    @loseSpeech   = data[:loseSpeech]
    @monIndexes   = data[:monIndexes]
    @flags        = {}
    data.each { |key, value|
      var = "@" + key.to_s
      if !self.instance_variables.include?(var.to_sym)
        @flags.store(key, value)
      end
    }
  end

  def checkFlag?(flag, default = false)
    return @flags.fetch(flag, default)
  end
end

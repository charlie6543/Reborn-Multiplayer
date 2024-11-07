class Randomizer
  TESTSEED = 279295474045690627731113896522056526725
  attr_accessor :randomItemCount
  attr_reader :settings
  attr_reader :randomItems
  attr_reader :randomPokemon
  attr_reader :randomEncounters
  attr_reader :randomAbilities
  attr_reader :randomStats
  attr_reader :randomTypes
  attr_reader :randomMovesets
  attr_reader :randomMoves
  attr_reader :randomEvolutions
  attr_reader :allowMegas
  attr_reader :allowForms
  attr_reader :fieldTypeMatch
  attr_reader :randomMarts
  attr_reader :martTypeMatch
  attr_reader :randomTMs
  attr_reader :randomMoveTutors
  attr_reader :randomMoveCompatibility
  attr_reader :randomStarters
  attr_reader :randomTrainers
  attr_reader :randomStatics
  attr_reader :randomTrainerNames
  attr_reader :randomTrainerClasses

  def initialize(settings)
    @settings = settings
    @randomItemCount = settings.randomItemCount || 0
    @randomItems = @settings.items[:field][:random] # change these later
    @fieldTypeMatch = @settings.items[:field][:typeMatch]
    @randomPokemon = @settings.encounters[:random]
    @randomEncounters = @settings.encounters[:areamap] || @settings.encounters[:globalmap]
    @randomStatics = @settings.statics[:statics][:random]
    @randomStarters = @settings.statics[:starters][:random]
    @randomAbilities = @settings.pkmn[:abilities][:random]
    @randomStats = @settings.pkmn[:stats][:random] || @settings.pkmn[:stats][:shuffle] || @settings.pkmn[:stats][:flipped]
    @randomTypes = @settings.pkmn[:types][:random]
    @randomMovesets = @settings.pkmn[:movesets][:random]
    @randomMoves = @settings.moves[:power] || @settings.moves[:type] || @settings.moves[:accuracy] || @settings.moves[:category]
    @randomEvolutions = @settings.pkmn[:evolutions][:random]
    @allowMegas = @settings.misc[:allowMegas]
    @allowForms = @settings.misc[:allowForms]
    @randomMarts = @settings.items[:mart][:random]
    @martTypeMatch = @settings.items[:mart][:typeMatch]
    @randomTMs = @settings.tms[:random]
    @randomMoveTutors = @settings.tutors[:random]
    @randomMoveCompatibility = @randomMovesets || @randomTMs || @randomMoveTutors
    @randomTrainers = @settings.trainers[:random]
    @randomTrainerNames = @settings.trainers[:name]
    @randomTrainerClasses = @settings.trainers[:class]
  end

  def randomItem(item, typeMatch = false, useItemCount = true)
    typeMatch = true
    # return the original item if it's a key item, quest item, or side quest item
    return item if $cache.items[item].checkFlag?(:keyitem) || $cache.items[item].checkFlag?(:questitem) || $cache.items[item].checkFlag?(:sidequest) || (Reborn && item == :GRASSMAIL)

    pool = $cache.items.keys
    # remove any items that are quest items or key items (but leave items like DNA Splicers)
    pool.delete_if { |i|
      $cache.items[i].checkFlag?(:questitem) || ($cache.items[i].checkFlag?(:keyitem) && !$cache.items[i].checkFlag?(:legendary))
    }
    # remove any unique items already gathered
    pool.delete_if { |i|
      ($cache.items[i].checkFlag?(:tm) && $PokemonBag.pbHasItem?(i)) ||
        ($cache.items[i].checkFlag?(:crystal) && $PokemonBag.pbHasItem?(i)) ||
        ($cache.items[i].checkFlag?(:crest) && $PokemonBag.pbHasItem?(i))
    }
    # saving in case we empty the pool
    backupPool = pool.dup

    if typeMatch
      # remove any items from differing pockets
      pool.delete_if { |i| pbGetPocket(i) != pbGetPocket(item) }

      # power matching for zcrystals / mega stones
      # type zcrystals always give type zcrystals
      # mega stones / unique z crystals are interchangeable
      if $cache.items[item].checkFlag?(:crystal)
        if $cache.items[item].checkFlag?(:zcrystal)
          pool.delete_if { |i|
            !$cache.items[i].checkFlag?(:zcrystal) || PBStuff::MOVETOZCRYSTAL.values.include?(i)
          }
        else
          pool.delete_if { |i|
            $cache.items[i].checkFlag?(:zcrystal) && !PBStuff::MOVETOZCRYSTAL.values.include?(i)
          }
        end
      end

      if $cache.items[item].checkFlag?(:crest)
        pool.delete_if { |i| !$cache.items[i].checkFlag?(:crest) }
      end

      pool = backupPool if pool.empty?
    end
    # sample
    seed = @settings.random.seed
    seed += @randomItemCount if useItemCount
    item = pool.sample(random: Random.new(seed))
    # increment the item calls so we can reliably pull the same items but still feel random
    @randomItemCount += 1 if useItemCount
    item
  end

  def randomize()
    begin
      viewport = Viewport.new(0, 0, 512, 800) #Graphics.width wasn't working, using RandomizerScene dimensions.
      viewport.z = 99999
      img = SpriteWrapper.new(viewport)
      img.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/onlinewaiting.png")
      Graphics.update
      @settings.initRandom(Random.new_seed) if !@settings.random
      puts "Random Seed: #{@settings.random.seed}"
      puts "Settings String: #{@settings.to_s}"
      @settings.save

      @movesChanged = false
      @movesetsChanged = false
      @pokemonTraitsChanged = false
      @statsChanged = false
      @evolutionsChanged = false
      @trainersChanged = false
      @trainerMovesetsChanged = false
      @encountersChanged = false
      @staticsChanged = false
      @startersChanged = false
      @tmMovesChanged = false
      @moveTutorMovesChanged = false
      @tradesChanged = false
      @tmsHmsCompatChanged = false
      @tutorCompatChanged = false
      @martsChanged = false

      RandomizerHandler.initHandler(@settings)

      moveSettings = @settings.moves
      (RandomizerHandler.randomizeMovePower;    @movesChanged = true) if moveSettings[:power]
      (RandomizerHandler.randomizeMoveAccuracy; @movesChanged = true) if moveSettings[:accuracy]
      (RandomizerHandler.randomizeMoveType;     @movesChanged = true) if moveSettings[:type]
      (RandomizerHandler.randomizeMoveCategory; @movesChanged = true) if moveSettings[:category]

      pokemonSettings = @settings.pkmn
      (RandomizerHandler.randomizeEvolutions; @evolutionsChanged = true) if pokemonSettings[:evolutions][:random]

      (RandomizerHandler.randomizePokemonTypes; @pokemonTraitsChanged = true) if pokemonSettings[:types][:random]

      if pokemonSettings[:stats][:flipped] && !@statsChanged
        @statsChanged = true
        @pokemonTraitsChanged = true
        RandomizerHandler.flipStats
      end
      if pokemonSettings[:stats][:random] && !@statsChanged
        @statsChanged = true
        @pokemonTraitsChanged = true
        RandomizerHandler.randomizeStats(pokemonSettings[:stats][:followEvolutions])
      end
      if pokemonSettings[:stats][:shuffle] && !@statsChanged
        @statsChanged = true
        @pokemonTraitsChanged = true
        RandomizerHandler.shuffleStats(pokemonSettings[:stats][:followEvolutions])
      end

      (RandomizerHandler.randomizeAbilities; @pokemonTraitsChanged = true) if pokemonSettings[:abilities][:random]

      (RandomizerHandler.randomizeMovesets; @movesetsChanged = true) if pokemonSettings[:movesets][:random]

      (RandomizerHandler.randomizeTMs; @tmMovesChanged = true) if @randomTMs

      (RandomizerHandler.randomizeMoveTutors; @moveTutorMovesChanged = true) if @randomMoveTutors

      (RandomizerHandler.randomizeEncounters; @encountersChanged = true) if @randomEncounters

      (RandomizerHandler.randomizeStarters; @startersChanged = true) if @randomStarters

      # (RandomizerHandler.randomizeStatics; @staticsChanged = true) if @randomStatics

      RandomizerHandler.maintainFormSanity if @pokemonTraitsChanged || @movesetsChanged || @tmMovesChanged || @moveTutorMovesChanged
      # puts RandomizerHandler.pokemonCache.values.sample.export

      (RandomizerHandler.randomizeTrainers; @trainersChanged = true) if @randomTrainers
      (RandomizerHandler.randomizeTrainerNames; @trainersChanged = true) if @randomTrainerNames
      (RandomizerHandler.randomizeTrainerClasses; @trainersChanged = true) if @randomTrainerClasses

      (RandomizerHandler.randomizeMarts; @martsChanged = true) if @randomMarts
      # checkR()
      # handle evolution following

      save_data(RandomizerHandler.pokemonCache,
                "Randomizer Data/mons.dat") if @pokemonTraitsChanged || @movesetsChanged || @evolutionsChanged || @moveTutorMovesChanged || @tmMovesChanged
      save_data(RandomizerHandler.movePool, "Randomizer Data/moves.dat") if @movesChanged
      save_data(RandomizerHandler.martData, "Randomizer Data/marts.dat") if @martsChanged
      save_data(RandomizerHandler.itemCache, "Randomizer Data/items.dat") if @tmMovesChanged
      save_data(RandomizerHandler.tutorMapping, "Randomizer Data/tutors.dat") if @moveTutorMovesChanged
      save_data(RandomizerHandler.encounters, "Randomizer Data/encounters.dat") if @encountersChanged
      save_data(RandomizerHandler.formHash, "Randomizer Data/encounterForms.dat") if @encountersChanged
      save_data(RandomizerHandler.starterData, "Randomizer Data/starters.dat") if @startersChanged
      save_data(RandomizerHandler.trainerCache, "Randomizer Data/trainers.dat") if @trainersChanged
      save_data(RandomizerHandler.trainerNames, "Randomizer Data/trainernames.dat") if @trainersChanged
      save_data(RandomizerHandler.trainerClasses, "Randomizer Data/trainertypes.dat") if @trainersChanged
      $rndcache = Cache_Randomizer.new()
      exportAll()
      img.dispose
      viewport.dispose
      Graphics.update
    rescue
      @settings.save
      e = $!
      btrace = ""
      if e.backtrace
        maxlength = $INTERNAL ? 25 : 10
        e.backtrace[0, maxlength].each do |i|
          btrace = btrace + "#{i}\n"
        end
      end
      message = "[#{GAMETITLE} #{GAMEVERSION}]\nAn error occurred during randomization.\n"
      message += "Please report this on the forums accompanied by the file \nRandomizer Data/settings.txt\n"
      message += "\nException: #{e.class}\nMessage: #{e.message}\n#{btrace}"
      errorlog = "errorlog.txt"
      if (Object.const_defined?(:RTP) rescue false)
        errorlog = RTP.getSaveFileName("errorlog.txt")
      end
      errorlogline = errorlog.sub(Dir.pwd + "\\", "").sub(Dir.pwd + "/", "")
      if errorlogline.length > 20
        errorlogline = "\n" + errorlogline
      end
      File.open(errorlog, "ab") { |f| f.write(message) }
      print("#{message}\nThis exception was logged in #{errorlogline}.\nPress Ctrl+C to copy this message to the clipboard.")
    end
  end

  def exportAll
    if @pokemonTraitsChanged || @movesetsChanged
      logPokemonChanges()
    end
    if @evolutionsChanged
      logEvolutionChanges()
    end
    if @movesChanged
      logMoveChanges()
    end
    if @martsChanged
      logMartChanges()
    end
    if @tmMovesChanged
      logTMChanges()
    end
    if @moveTutorMovesChanged
      logTutorChanges()
    end
    if @encountersChanged
      logEncounterChanges()
    end
    if @startersChanged
      logStarterChanges()
    end
    if @staticsChanged
      # logStaticChanges()
    end
    if @trainersChanged
      logTrainerChanges() if @randomTrainers
      logNameClassChanges() if @randomTrainerClasses || @randomTrainerNames
    end
  end

  def logNameClassChanges()
    nameLength = 0
    RandomizerHandler.trainerNames.each { |key, name|
      clazz = key[0]
      ogname = key[1]
      len = $cache.trainertypes[clazz].title.length + 1 + name.length
      nameLength = len if len > nameLength
    }

    exporttext = "=== Trainer Changes ===\n"
    RandomizerHandler.trainerNames.each { |key, name|
      clazz = key[0]
      ogname = key[1]
      fullName = $cache.trainertypes[clazz].title + " " + ogname
      randomName = RandomizerHandler.trainerClasses[clazz] + " " + name
      exporttext += sprintf("%-#{nameLength}s => %s\n", fullName, randomName)
    }
    File.open("Randomizer Data/Trainer Name Changes.txt", "w") { |f|
      f.write(exporttext)
    }
  end

  def logTrainerChanges
    exporttext = "=== Trainer Changes ===\n"
    classLength = RandomizerHandler.trainerClassLength
    titleLength = RandomizerHandler.trainerTitleLength
    nameLength = RandomizerHandler.trainerNameLength
    idLength = RandomizerHandler.trainerIDLength

    exporttext += sprintf("%-#{classLength}s|%-#{titleLength}s|%-#{nameLength}s|%-#{idLength}s\n", "Trainer Class", "Title", "Name", "ID")
    RandomizerHandler.trainerCache.each { |tclass, trainers|
      next if tclass == :TEST
      title = RandomizerHandler.trainerTypeCache[tclass].title
      trainers.each { |trainerName, trainerData|
        trainerData.each { |trainer|
          team = trainer[1]
          id = trainer[0]
          teamString = ""
          team.each { |pokemon|
            pokeString = ""
            name, custom = getMonName(pokemon[:species], pokemon[:form])
            if custom
              pokeString += "  #{custom} (#{name})"
            elsif pokemon[:name]
              pokeString += "  #{pokemon[:name]} (#{name})"
            else
              pokeString += "  #{name}"
            end
            pokeString += " (#{pokemon[:gender]})" if pokemon[:gender]
            pokeString += " @ #{getItemName(pokemon[:item])}" if pokemon[:item]
            pokeString += "\n"

            pokeString += "  Ability: #{getAbilityName(pokemon[:ability])}\n" if pokemon[:ability]
            pokeString += "  Level: #{pokemon[:level]}\n"
            pokeString += "  Shiny: Yes\n" if pokemon[:shiny]
            pokeString += "  Happiness: #{pokemon[:happiness]}\n" if pokemon[:happiness]

            if pokemon[:ev]
              evs = pokemon[:ev]
              pokeString += "  EVs: "
              statAry = ["HP", "Atk", "Def", "SpA", "SpD", "Spe"]
              for e in 0...evs.length
                next if evs[e] == 0
                pokeString += "#{evs[e]} #{statAry[e]}"
                next if e == evs.length - 1
                pokeString += " / "
              end
              pokeString += "\n"
            end

            pokeString += "  #{getNatureName(pokemon[:nature])} Nature\n" if pokemon[:nature]

            if pokemon[:iv]
              iv = pokemon[:iv]
              pokeString += "  IVs: #{iv} HP / #{iv} Atk / #{iv} Def / #{iv} SpA / #{iv} SpD / #{iv == 32 ? 0 : iv} Spe\n"
            end

            if pokemon[:moves]
              for move in pokemon[:moves]
                next if !move
                pokeString += "  - #{getMoveName(move)}"
                pokeString += " [#{getTypeName(pokemon[:hptype])}]" if move == :HIDDENPOWER && pokemon[:hptype]
                pokeString += "\n"
              end
            end

            teamString += pokeString
            teamString += "\n"
          }
          #teamArr = teamString.split("\n")
          exporttext += sprintf("%-#{classLength}s|%-#{titleLength}s|%-#{nameLength}s|%-#{idLength}s\n", tclass, title, trainerName, id)
          exporttext += sprintf("[#{trainerName.inspect}, #{tclass.inspect}, #{id.inspect}]\n")
          exporttext += teamString

        }
      }
    }
    File.open("Randomizer Data/Trainer Changes.txt", "w") { |f|
      f.write(exporttext)
    }
  end

  def getMonName(mon, form = 0)
    form = 0 if form.nil?
    name = Kernel.getMonName(mon, form)

    formnames = $cache.pkmn[mon].forms
    return name if formnames.empty? || formnames.length == 1 || form == 0 || mon == :MINIOR
    return name + "-F" if (cancelledgenders.include?(mon) && form == 1)
    formName = formnames[form]
    return name + "-Alola" if formName.include?("Alola")
    return name + "-Galar" if formName.include?("Galar")
    return name + "-Hisui" if formName.include?("Hisui")
    return name + "-Aevian" if formName.include?("Aevian")
    return name + "-Paldea" if formName.include?("Paldea")
    return name + "-Mega-X" if formName.include?("Mega X")
    return name + "-Mega-Y" if formName.include?("Mega Y")
    return name + "-Mega" if formName.include?("Mega")
    return name + "-Primal" if formName.include?("Primal")
    return name + "-Therian" if formName.include?("Therian")
    return name + "-Origin" if formName.include?("Origin")
    return "Necrozma-Dusk-Mane" if mon == :NECROZMA && form == 1
    return "Necrozma-Dawn-Wings" if mon == :NECROZMA && form == 2
    return "Necrozma-Ultra" if mon == :NECROZMA && form == 3
    return "Deoxys-Attack" if mon == :DEOXYS && form == 1
    return "Deoxys-Defense" if mon == :DEOXYS && form == 2
    return "Deoxys-Speed" if mon == :DEOXYS && form == 3
    return "Shaymin-Sky" if mon == :SHAYMIN && form == 1
    return "Kyurem-White" if mon == :KYUREM && form == 1
    return "Kyurem-Black" if mon == :KYUREM && form == 2
    return "Hoopa-Unbound" if mon == :HOOPA && form == 1
    if mon == :ROTOM
      case form
        when 1 then return "Rotom-Heat"
        when 2 then return "Rotom-Wash"
        when 3 then return "Rotom-Frost"
        when 4 then return "Rotom-Fan"
        when 5 then return "Rotom-Mow"
      end
    end
    return "Lycanroc-Midnight" if mon == :LYCANROC && form == 1
    return "Lycanroc-Dusk" if mon == :LYCANROC && form == 2
    return "Zygarde-10%" if mon == :ZYGARDE && form == 1
    return "Zygarde-Complete" if mon == :ZYGARDE && form == 2
    return "Oriocorio-Pom-Pom" if mon == :ORICORIO && form == 1
    return "Oriocorio-Pa'u" if mon == :ORICORIO && form == 2
    return "Oriocorio-Sensu" if mon == :ORICORIO && form == 3
    if mon == :PUMPKABOO || mon == :GOURGEIST
      return name + "-Small" if formName.include?("Small")
      return name + "-Super"
    end
    if mon == :WOMRADAM
      return name + "-Sandy" if formName.include?("Sandy")
      return name + "-Trash" if formName.include?("Trash")
    end
    if mon == :ARCEUS || mon == :SILVALLY
      return name if form == 0
      return name + "-#{formName}" if form < 19
      return name + "-Steel" if formName == "Dev" && mon == :SILVALLY
    end
    return name, formName
  end

  def logStaticChanges
    monLength = 0
    RandomizerHandler.staticData.keys.each { |mon|
      name = getMonName(mon)
      monLength = name.length if name.length > monLength
    }
    mapLength = 0
    RandomizerHandler.staticMapData.keys.each { |map|
      next if !$cache.mapinfos[map]

      name = $cache.mapinfos[map].name
      mapLength = name.length if name.length > mapLength
    }
    exporttext = "=== Static Encounter Changes ===\n"
    exporttext += sprintf("%-#{mapLength}s|Change\n", "Area")
    maps = pbHashForwardizer(RandomizerHandler.staticMapData)
    RandomizerHandler.staticData.each { |oldStatic, newStatic|
      map = $cache.mapinfos[maps[oldStatic]]
      if map
        mapname = map.name
      else
        mapname = "Unknown"
      end
      mapname = "" if mapname == lastMap
      lastMap = mapname unless mapname == ""
      oldName = getMonName(oldStatic)
      if newStatic.nil?
        newName = "Unchanged"
      else
        newName = getMonName(newStatic[:species]) + " " + $cache.pkmn[newStatic[:species]].forms[newStatic[:form]]
      end
      exporttext += sprintf("%-#{mapLength}s|%-#{monLength}s => %s\n", mapname, oldName, newName)
    }
    File.open("Randomizer Data/Starter Changes.txt", "w") { |f|
      f.write(exporttext)
    }
  end

  def logStarterChanges
    nameLength = 0
    RandomizerHandler.starterData.keys.each { |mon|
      name = getMonName(mon)
      nameLength = name.length if name.length > nameLength
    }
    exporttext = "=== Starter Changes ===\n"
    RandomizerHandler.starterData.each { |oldStarter, newStarter|
      oldName = getMonName(oldStarter)
      newName = getMonName(newStarter[:species]) + " " + $cache.pkmn[newStarter[:species]].forms[newStarter[:form]]
      exporttext += sprintf("%-#{nameLength}s => %s\n", oldName, newName)
    }
    exporttext += sprintf("%-#{nameLength}s => %s\n", "Budew?", "Budew.") if Reborn # budew password :)
    File.open("Randomizer Data/Starter Changes.txt", "w") { |f|
      f.write(exporttext)
    }
  end

  def logEncounterChanges
    nameLength = 0
    RandomizerHandler.encounters.keys.each { |map|
      next if !$cache.mapinfos[map]

      # puts map
      mapname = $cache.mapinfos[map].name
      nameLength = mapname.length if mapname.length > nameLength
    }
    exporttext = "=== Encounter Changes ===\n"
    exporttext += sprintf("%-#{nameLength}s|Encounter Method|Change\n", "Map Name")
    RandomizerHandler.encounters.keys.each { |map|
      next if !$cache.mapinfos[map]

      # puts map
      rndom = RandomizerHandler.encounters[map]
      canon = $cache.mapdata[map]
      mapname = $cache.mapinfos[map].name
      exporttext += sprintf("%-#{nameLength}s", mapname)
      showMap = true
      encounterTypes = EncounterTypes::Names.to_h { |enc| [enc.to_sym, ("@" + enc).to_sym] }
      encounterTypes.each { |rndType, canType|
        randEncounters = rndom[rndType]
        next if !randEncounters || randEncounters.empty?

        canonEncounters = canon.instance_variable_get(canType)
        species = randEncounters.keys[0]
        multipleForms = {}
        form = RandomizerHandler.formHash.dig(map, species)
        form = $cache.pkmn[species].forms[0] if !form
        if form.is_a?(Array)
          if form.length > 1
            multipleForms[species] = form.dup
            form = multipleForms[species].sample
            multipleForms[species].delete(form)
          else
            form = form[0]
          end
        end
        name = $cache.pkmn[species, form].name
        fullname = name + " " + form
        exporttext += sprintf("%-#{showMap ? 0 : nameLength}s|%-16s|%-12s => %s\n", "", rndType, getMonName(canonEncounters.keys[0]), fullname)
        showMap = false
        for i in 1...randEncounters.length
          species = randEncounters.keys[i]
          form = RandomizerHandler.formHash.dig(map, species)
          form = $cache.pkmn[species].forms[0] if !form
          if form.is_a?(Array)
            if form.length > 1
              multipleForms[species] = form.dup
              form = multipleForms[species].sample
              multipleForms[species].delete(form)
            else
              form = form[0]
            end
          end
          name = $cache.pkmn[species, form].name
          fullname = name + " " + form
          exporttext += sprintf("%-#{nameLength}s|%-16s|%-12s => %s\n", "", "", getMonName(canonEncounters.keys[i]), fullname)

        end
      }
    }
    # exporttext += "Starters:\n"
    # @@starters.each { |oldMon, newMon|
    #  exporttext += sprintf("%-15s => %-15s\n", oldMon, newMon)
    # }
    # exporttext += "\n\nGifts:\n"
    # @@giftData.each { |oldMon, newMon|
    #  exporttext += sprintf("%-15s => %-15s\n", oldMon, newMon)
    # }
    File.open("Randomizer Data/Encounter Changes.txt", "w") { |f|
      f.write(exporttext)
    }
  end

  def logTMChanges
    nameLength = 0
    RandomizerHandler.tmPool.each { |item, data|
      nameLength = getMoveName(data.checkFlag?(:tm)).length if getMoveName(data.checkFlag?(:tm)).length > nameLength
    }
    output = "=== TM Changes ===\n"
    output += "TMs not listed do not get changed. These are typically field moves or anything else marked for story progression in itemtxt.rb\n"
    output += "TM#  |"
    output += sprintf("%-#{nameLength}s => %-#{nameLength}s\n", "Original Move", "New Move")
    RandomizerHandler.tmPool.each { |item, data|
      oldtm = getMoveName($cache.items[item].checkFlag?(:tm))
      newtm = getMoveName(data.checkFlag?(:tm))
      output += sprintf("%-5s|%-#{nameLength}s => %-#{nameLength}s\n", data.name, oldtm, newtm)
    }
    File.open("Randomizer Data/TM Changes.txt", "w") { |f|
      f.write(output)
    }
  end

  def logTutorChanges
    nameLength = 0
    RandomizerHandler.tutorMapping.each { |oldmove, newmove|
      nameLength = getMoveName(oldmove).length if getMoveName(oldmove).length > nameLength
      nameLength = getMoveName(newmove).length if getMoveName(newmove).length > nameLength
    }
    output = "=== Move Tutor Changes ===\n"
    output += sprintf("%-#{nameLength}s => %-#{nameLength}s\n", "Original Move", "New Move")
    RandomizerHandler.tutorMapping.each { |oldmove, newmove|
      output += sprintf("%-#{nameLength}s => %-#{nameLength}s\n", getMoveName(oldmove), getMoveName(newmove))
    }
    File.open("Randomizer Data/Move Tutor Changes.txt", "w") { |f|
      f.write(output)
    }
  end

  def logMartChanges
    nameLength = 0
    RandomizerHandler.martData.each { |loc| nameLength = loc.name.length if loc.name.length > nameLength }
    output = "=== PokeMart Changes ===\n"
    output += "#  |"
    output += sprintf("%-#{nameLength}s", "Mart Location")
    output += "|Map ID|Stock"
    RandomizerHandler.martData.each { |loc|
      output += sprintf("\n%-3s|%-#{nameLength}s|%-6s|", RandomizerHandler.martData.index(loc) + 1, loc.name, loc.map_id)
      loc.stock.each { |item|
        itemName = getItemName(item)
        if pbGetPocket(item) == 4
          itemName = "TM - "
          move = $cache.items[item].checkFlag?(:tm)
          if @tmMovesChanged
            move = $rndcache.items[item].checkFlag?(:tm)
          end
          moveName = getMoveName(move)
          if @settings.shouldRandomizeMoveNames?
            moveName = $rndcache.moves[move].name
          end
          itemName += moveName
        end
        output += "#{itemName}\n"
        output += sprintf("%-3s|%-#{nameLength}s|%-6s|", "", "", "")
      }
    }
    File.open("Randomizer Data/Mart Changes.txt", "w") { |f|
      f.write(output)
    }
  end

  def logMoveChanges
    exporttext = "=== Move Changes ===\n"
    exporttext += "Name                |Type    |BP   |Acc | PP| Category\n"
    RandomizerHandler.movePool.each { |move, data|
      next if move == :STRUGGLE || PBStuff::ANIMATIONDUMMIES.include?(move) || PBStuff::ZMOVES.include?(move)

      exporttext += sprintf("%-20s|%-8s|%5d|%4d|%3d| %s\n", data.name, getTypeName(data.type), data.basedamage, data.accuracy, data.maxpp, data.category.to_s)
    }
    File.open("Randomizer Data/Move Changes.txt", "w") { |f|
      f.write(exporttext)
    }
  end

  def logEvolutionChanges
    exporttext = "=== Evolution Changes ===\n"
    RandomizerHandler.pokemonPool.each { |pokemon|
      next if pokemon.data.checkFlag?(:ExcludeDex)
      next if !pokemon.data.evolutions || pokemon.data.evolutions.empty?

      evo = pokemon.data.evolutions[0]

      species = evo[:species]
      form = $cache.pkmn[species].forms[evo[:form]]
      name = $cache.pkmn[species, form].name
      pokemonNameString = sprintf("%-12s", pokemon.data.name) + " - " + sprintf("%-20s", pokemon.form)
      evoNameString = sprintf("%-12s", name) + " - " + sprintf("%-20s", form)
      exporttext += sprintf("%-35s evolves into %-35s at level %2d\n", pokemonNameString, evoNameString, evo[:parameter])
    }
    File.open("Randomizer Data/Evolution Changes.txt", "w") { |f|
      f.write(exporttext)
    }
  end

  def logPokemonChanges
    if @pokemonTraitsChanged
      exporttext = "=== Pokemon Changes ===\n"
      exporttext += "Dex |Name                               |Types              | HP|ATK|DEF|SPA|SPD|SPE|"
      abilCount = @settings.pkmn[:abilities][:abilityCount]
      exporttext += sprintf("%-#{abilCount * 18}s", "Abilities")
      exporttext += "|Held Item\n"
      RandomizerHandler.pokemonPool.each { |pokemon|
        bs = pokemon.BaseStats
        abilString = ""
        pokemon.Abilities.each { |a|
          abilString += sprintf("%-16s", getAbilityName(a, true)) + (pokemon.Abilities[-1] != a ? " / " : "")
        }
        heldItemString = ""

        pokemonNameString = sprintf("%-12s", pokemon.data.name) + " - " + sprintf("%-20s", pokemon.form)

        typeString = sprintf("%-8s", getTypeName(pokemon.Type1))
        typeString += " / #{sprintf("%-8s", getTypeName(pokemon.Type2))}" if pokemon.Type2 != nil

        exporttext += sprintf(
          "%4d|%-35s|%-19s|%3d|%3d|%3d|%3d|%3d|%3d|%s|%s\n", pokemon.data.dexnum,
          pokemonNameString, typeString,
          bs[0], bs[1], bs[2], bs[3], bs[4], bs[5],
          abilString,
          heldItemString
        )
      }
      File.open("Randomizer Data/Pokemon Trait Changes.txt", "w") { |f|
        f.write(exporttext)
      }
    end
    if @movesetsChanged
      exporttext = "=== Pokemon Movesets ===\n"
      exporttext += "Dex |Name                               | Moves\n"
      exporttext += ("-" * 81)
      exporttext += "\n"
      RandomizerHandler.pokemonPool.each { |pokemon|
        next if RandomizerUtils.getMegaEvolutions.include?(pokemon)
        next if RandomizerHandler::COSMETICFORMS.include?(pokemon.species) && RandomizerHandler.pokemonCache[pokemon.species].forms[0] != pokemon.form

        # puts pokemon.species
        pokemonNameString = sprintf("%-12s", pokemon.data.name) + " - " + sprintf("%-20s", pokemon.form)
        exporttext += sprintf("%4d|%-35s|", pokemon.data.dexnum, pokemonNameString)
        line = 0
        pokemon.Moveset.each { |movePair|
          level = movePair[0]
          move = getMoveName(movePair[1])
          offset = line == 0 ? 0 : 42
          if level == 0
            exporttext += sprintf("%#{offset}sLearned upon evolution: #{move}\n", " ")
          else
            exporttext += sprintf("%#{offset}sLevel #{level}: #{move}\n", " ")
          end
          line += 1
        }
        exporttext += ("-" * 81)
        exporttext += "\n"
      }
      File.open("Randomizer Data/Pokemon Moveset Changes.txt", "w") { |f|
        f.write(exporttext)
      }
    end
  end
end

def checkR
  l = RandomizerHandler.pokemonPool.sample
  if RandomizerUtils.getMegaEvolutions.include?(l)
    form = $cache.pkmn[l.species].forms[l.data.baseForm]
    l = RandomizerHandler.pokemonPool.find { |p| p.species == l.species && p.form == form }
  end
  while l.preevolution
    l = l.preevolution
  end
  puts l
  if l.evolutions
    l.evolutions.each { |e|
      puts e
      if e.megaEvolutions
        e.megaEvolutions.each { |m| puts m }
      end
      if e.evolutions
        e.evolutions.each { |e2|
          puts e2
          if e2.megaEvolutions
            e2.megaEvolutions.each { |m| puts m }
          end
        }
      end
    }
  end
  if l.megaEvolutions
    l.megaEvolutions.each { |m| puts m }
  end
end

def checkREvos
  check = []
  RandomizerUtils.getBasicPokemon.each { |mon|
    next if check.include?(mon)
    m = mon
    while m.preevolution
      m = m.preevolution
    end
    puts m
    check.push(m)

    check = evoRecur(mon, check)
    puts
  }
end

def evoRecur(mon, check)
  return check if mon.evolutions.empty?
  check.push(mon)
  puts mon
  mon.evolutions.each { |evo|
    check = evoRecur(mon, check)
    check.push(evo)
  }
  return check
end

Events.onSpritesetCreate += proc { |sender, e|
  spriteset = e[0]
  viewport = e[1]
  map = spriteset.map
  for i in map.events.keys
    if map.events[i].name == "BerryPlant"
      spriteset.addUserSprite(BerryPlantSprite.new(map.events[i], map, viewport))
    end
  end
}

class BerryPlantSprite
  # Berry, hours per stage, min yield, max yield, plural
  BERRYVALUES = [
    [:CHERIBERRY, 3, 2, 5, _INTL("Cheri Berries")],
    [:CHESTOBERRY, 3, 2, 5, _INTL("Chesto Berries")],
    [:PECHABERRY, 3, 2, 5, _INTL("Pecha Berries")],
    [:RAWSTBERRY, 3, 2, 5, _INTL("Rawst Berries")],
    [:ASPEARBERRY, 3, 2, 5, _INTL("Aspear Berries")],
    [:LEPPABERRY, 4, 2, 5, _INTL("Leppa Berries")],
    [:ORANBERRY, 4, 2, 5, _INTL("Oran Berries")],
    [:PERSIMBERRY, 4, 2, 5, _INTL("Persim Berries")],
    [:LUMBERRY, 12, 2, 5, _INTL("Lum Berries")],
    [:SITRUSBERRY, 8, 2, 5, _INTL("Sitrus Berries")],
    [:FIGYBERRY, 5, 2, 5, _INTL("Figy Berries")],
    [:WIKIBERRY, 5, 2, 5, _INTL("Wiki Berries")],
    [:MAGOBERRY, 5, 2, 5, _INTL("Mago Berries")],
    [:AGUAVBERRY, 5, 2, 5, _INTL("Aguav Berries")],
    [:IAPAPABERRY, 5, 2, 5, _INTL("Iapapa Berries")],
    [:RAZZBERRY, 2, 2, 10, _INTL("Razz Berries")],
    [:BLUKBERRY, 2, 2, 10, _INTL("Bluk Berries")],
    [:NANABBERRY, 2, 2, 10, _INTL("Nanab Berries")],
    [:WEPEARBERRY, 2, 2, 10, _INTL("Wepear Berries")],
    [:PINAPBERRY, 2, 2, 10, _INTL("Pinap Berries")],
    [:POMEGBERRY, 8, 2, 5, _INTL("Pomeg Berries")],
    [:KELPSYBERRY, 8, 2, 5, _INTL("Kelpsy Berries")],
    [:QUALOTBERRY, 8, 2, 5, _INTL("Qualot Berries")],
    [:HONDEWBERRY, 8, 2, 5, _INTL("Hondew Berries")],
    [:GREPABERRY, 8, 2, 5, _INTL("Grepa Berries")],
    [:TAMATOBERRY, 8, 2, 5, _INTL("Tamato Berries")],
    [:CORNNBERRY, 8, 2, 10, _INTL("Cornn Berries")],
    [:MAGOSTBERRY, 6, 2, 10, _INTL("Magost Berries")],
    [:RABUTABERRY, 6, 2, 10, _INTL("Rabuta Berries")],
    [:NOMELBERRY, 6, 2, 10, _INTL("Nomel Berries")],
    [:SPELONBERRY, 15, 3, 15, _INTL("Spelon Berries")],
    [:PAMTREBERRY, 15, 3, 15, _INTL("Pamtre Berries")],
    [:WATMELBERRY, 15, 3, 15, _INTL("Watmel Berries")],
    [:DURINBERRY, 15, 3, 15, _INTL("Durin Berries")],
    [:BELUEBERRY, 15, 3, 15, _INTL("Belue Berries")],
    [:OCCABERRY, 18, 2, 5, _INTL("Occa Berries")],
    [:PASSHOBERRY, 18, 2, 5, _INTL("Passho Berries")],
    [:WACANBERRY, 18, 2, 5, _INTL("Wacan Berries")],
    [:RINDOBERRY, 18, 2, 5, _INTL("Rindo Berries")],
    [:YACHEBERRY, 18, 2, 5, _INTL("Yache Berries")],
    [:CHOPLEBERRY, 18, 2, 5, _INTL("Chople Berries")],
    [:KEBIABERRY, 18, 2, 5, _INTL("Kebia Berries")],
    [:SHUCABERRY, 18, 2, 5, _INTL("Shuca Berries")],
    [:COBABERRY, 18, 2, 5, _INTL("Coba Berries")],
    [:PAYAPABERRY, 18, 2, 5, _INTL("Payapa Berries")],
    [:TANGABERRY, 18, 2, 5, _INTL("Tanga Berries")],
    [:CHARTIBERRY, 18, 2, 5, _INTL("Charti Berries")],
    [:KASIBBERRY, 18, 2, 5, _INTL("Kasib Berries")],
    [:HABANBERRY, 18, 2, 5, _INTL("Haban Berries")],
    [:COLBURBERRY, 18, 2, 5, _INTL("Colbur Berries")],
    [:BABIRIBERRY, 18, 2, 5, _INTL("Babiri Berries")],
    [:CHILANBERRY, 18, 2, 5, _INTL("Chilan Berries")],
    [:LIECHIBERRY, 24, 2, 5, _INTL("Liechi Berries")],
    [:GANLONBERRY, 24, 2, 5, _INTL("Ganlon Berries")],
    [:SALACBERRY, 24, 2, 5, _INTL("Salac Berries")],
    [:PETAYABERRY, 24, 2, 5, _INTL("Petaya Berries")],
    [:APICOTBERRY, 24, 2, 5, _INTL("Apicot Berries")],
    [:LANSATBERRY, 24, 2, 5, _INTL("Lansat Berries")],
    [:STARFBERRY, 24, 2, 5, _INTL("Starf Berries")],
    [:ENIGMABERRY, 24, 2, 5, _INTL("Enigma Berries")],
    [:MICLEBERRY, 24, 2, 5, _INTL("Micle Berries")],
    [:CUSTAPBERRY, 24, 2, 5, _INTL("Custap Berries")],
    [:JABOCABERRY, 24, 2, 5, _INTL("Jaboca Berries")],
    [:ROWAPBERRY, 24, 2, 5, _INTL("Rowap Berries")],
    [:ROSELIBERRY, 18, 2, 5, _INTL("Roseli Berries")],
    [:KEEBERRY, 16, 2, 10, _INTL("Kee Berries")],
    [:MARANGABERRY, 16, 2, 10, _INTL("Maranga Berries")]
  ]
  # REPLANTS=9

  def initialize(event, map, viewport)
    @event = event
    @map = map
    @disposed = false
    berryData = event.variable
    return if !berryData

    @event.character_name = ""
    berryvalues = nil
    if berryData[1] != 0 && berryData[1].is_a?(Integer)
      # stealing bag item conversion code
      # it's here so conversion doesn't have to iterate through every event on every map in the game to find the berries
      for i in $cache.items.keys
        if $cache.items[i].checkFlag?(:ID) == berryData[1]
          berryData[1] = i
          break
        end
      end
    end
    for i in BERRYVALUES
      if berryData[1] == i[0]
        berryvalues = i
        break
      end
    end
    berryvalues = BERRYVALUES[0] if !berryvalues
    hours = berryvalues[1]
    levels = 0
    if berryData[0] > 0 && berryData[0] < 5
      # Advance time
      timenow = pbGetTimeNow
      timeDiff = (timenow.to_i - berryData[3]) # in seconds
      if timeDiff >= hours * 3600
        levels += 1
      end
      if timeDiff >= hours * 2 * 3600
        levels += 1
      end
      if timeDiff >= hours * 3 * 3600
        levels += 1
      end
      if timeDiff >= hours * 4 * 3600
        levels += 1
      end
      levels = 5 - berryData[0] if levels > 5 - berryData[0]
      berryData[2] = false
      berryData[3] += levels * hours * 3600
      berryData[0] += levels
      berryData[0] = 5 if berryData[0] > 5
    end
    if berryData[0] > 0 && berryData[0] < 5
      # Reset watering
      if $game_screen &&
         [:Rain, :Storm, :Thunder, :RealThunder, :HeavyRain].include?($game_screen.weather_type)
        # If raining, plant is already watered
        if berryData[2] == false
          berryData[2] = true
          berryData[4] += 1
        end
      end
    end
    setGraphic(berryData, true) # Set the event's graphic
    event.setVariable(berryData) # Set new berry data
  end

  def dispose
    @event = nil
    @map = nil
    @disposed = true
  end

  def disposed?
    @disposed
  end

  def update # Constantly updates, used only to immediately
    berryData = @event.variable # change sprite when planting/picking berries
    setGraphic(berryData) if berryData
  end

  def setGraphic(berryData, fullcheck = false)
    if berryData[0] == 0
      @event.character_name = ""
    elsif berryData[0] == 1 # X planted
      @event.character_name = "berrytreeplanted" # Common to all berries
      @event.turn_down
    elsif fullcheck
      filename = sprintf("berrytree%s", getItemName(berryData[1])) rescue nil
      filename = "berrytree#{berryData[1]}" if !pbResolveBitmap("Graphics/Characters/" + filename)
      if pbResolveBitmap("Graphics/Characters/" + filename)
        @event.character_name = filename
        @event.turn_down if berryData[0] == 2   # X sprouted
        @event.turn_left if berryData[0] == 3   # X taller
        @event.turn_right if berryData[0] == 4  # X flowering
        @event.turn_up if berryData[0] == 5     # X berries
      else
        @event.character_name = "itemball"
      end
    end
  end
end

def pbBerryPlant
  interp = pbMapInterpreter
  thisEvent = interp.get_character(0)
  berryData = interp.getVariable
  if !berryData
    berryData = [0, 0, false, 0, 0, 0]
  end
  # Stop the event turning towards the player
  case berryData[0]
    when 1 then thisEvent.turn_down
    when 2 then thisEvent.turn_down
    when 3 then thisEvent.turn_left
    when 4 then thisEvent.turn_right
    when 5 then thisEvent.turn_up
  end
  berryvalues = nil
  for i in BerryPlantSprite::BERRYVALUES
    if berryData[1] == i[0]
      berryvalues = i
      break
    end
  end
  berryvalues = BerryPlantSprite::BERRYVALUES[0] if !berryvalues
  watering = []
  watering.push(:SPRAYDUCK)
  watering.push(:SQUIRTBOTTLE)
  watering.push(:WAILMERPAIL)
  berry = berryData[1]
  # Check on state of berry
  case berryData[0]
    when 0 # empty
      if Kernel.pbConfirmMessage(_INTL("It's soft, loamy soil.\nPlant a berry?"))
        pbFadeOutIn(99999) {
          scene = PokemonBag_Scene.new
          screen = PokemonBagScreen.new(scene, $PokemonBag)
          berry = screen.pbChooseBerryScreen
        }
        if !berry.nil? && berry != 0
          timenow = pbGetTimeNow
          berryData[0] = 1             # growth stage (1-5)
          berryData[1] = berry
          berryData[2] = false         # watered in this stage
          berryData[3] = timenow.to_i  # time planted
          berryData[4] = 0             # total waterings
          berryData[5] = 0             # number of replants
          berryData[6] = -1            # chosen amount of berries
          $PokemonBag.pbDeleteItem(berry, 1)
          Kernel.pbMessage(_INTL("{1} planted a {2} in the soft loamy soil.", $Trainer.name, getItemName(berry)))
          interp.setVariable(berryData)
        end
        return
      end
    when 1 # X planted
      Kernel.pbMessage(_INTL("A {1} was planted here.", getItemName(berry)))
    when 2  # X sprouted
      Kernel.pbMessage(_INTL("The {1} has sprouted.", getItemName(berry)))
    when 3  # X taller
      Kernel.pbMessage(_INTL("The {1} plant is growing bigger.", getItemName(berry)))
    when 4  # X flowering
      if berryData[4] == 4
        Kernel.pbMessage(_INTL("This {1} plant is in fabulous bloom!", getItemName(berry)))
      elsif berryData[4] == 3
        Kernel.pbMessage(_INTL("This {1} plant is blooming very beautifully!", getItemName(berry)))
      elsif berryData[4] == 2
        Kernel.pbMessage(_INTL("This {1} plant is blooming prettily!", getItemName(berry)))
      elsif berryData[4] == 1
        Kernel.pbMessage(_INTL("This {1} plant is blooming cutely!", getItemName(berry)))
      else
        Kernel.pbMessage(_INTL("This {1} plant is in bloom!", getItemName(berry)))
      end
    when 5  # X berries
      # get berry yield (berrycount)
      berrycount = 1
      if berryData[4] > 0
        berryData[6] = rand(1 + berryvalues[3] - berryvalues[2]) if !berryData[6] || berryData[6] == -1
        berrycount = (((berryvalues[3] - berryvalues[2]) * (berryData[4] - 1) + berryData[6]) / 4).floor + berryvalues[2]
        interp.setVariable(berryData)
      else
        berrycount = berryvalues[2]
      end
      if berrycount > 1
        Kernel.pbMessage(_INTL("There are {1} {2}!", berrycount, berryvalues[4]))
        askmessage = _INTL("Would you like to pick the berries?")
      else
        Kernel.pbMessage(_INTL("There is 1 {1}!", getItemName(berry)))
        askmessage = _INTL("Would you like to pick the berry?")
      end
      if Kernel.pbConfirmMessage(askmessage)
        if !$PokemonBag.pbCanStore?(berryData[1], berrycount)
          Kernel.pbMessage(_INTL("Too bad...\nThe bag is full."))
          return
        end
        $PokemonBag.pbStoreItem(berryData[1], berrycount)
        if berrycount > 1
          Kernel.pbMessage(_INTL("{1} picked {2} {3}!", $Trainer.name, berrycount, berryvalues[4]))
          Kernel.pbMessage(_INTL("{1} put the {2} {3} in the Berries Pocket.\1", $Trainer.name, berrycount, berryvalues[4]))
        else
          Kernel.pbMessage(_INTL("{1} picked the {2}!", $Trainer.name, getItemName(berry)))
          Kernel.pbMessage(_INTL("{1} put the {2} in the Berries Pocket.\1", $Trainer.name, getItemName(berry)))
        end
        Kernel.pbMessage(_INTL("The soil returned to its soft and loamy state.\1"))
        berryData[0] = 0
        berryData[1] = 0
        berryData[2] = false
        berryData[3] = 0
        berryData[4] = 0
        berryData[5] = 0
        berryData[6] = -1
        interp.setVariable(berryData)
      end
      return
  end
  # Watering of plants
  case berryData[0]
    when 1, 2, 3, 4
      for i in watering
        if i != 0 && $PokemonBag.pbQuantity(i) > 0
          if Kernel.pbConfirmMessage(_INTL("Would you like to water the {1} plant with the {2}?", getItemName(berryData[1]), getItemName(i)))
            if berryData[2] == false
              berryData[4] += 1
              berryData[2] = true
            end
            interp.setVariable(berryData)
            Kernel.pbMessage(_INTL("{1} watered the plant.\\wtnp[40]", $Trainer.name))
            Kernel.pbMessage(_INTL("The plant seemed to be delighted."))
          end
          break
        end
      end
      if $DEBUG && Input.pressex?(:LCTRL) && berryData[0] < 5
        berryData[0] += 1
        puts "Progressing berry #{getItemName(berryData[1])} to stage #{berryData[0]}"
        if berryData[0] == 1
          thisEvent.character_name = "berrytreeplanted"
          thisEvent.turn_down
        else
          filename = sprintf("berrytree%s", getItemName(berryData[1])) rescue nil
          filename = "berrytree#{berryData[1]}" if !pbResolveBitmap("Graphics/Characters/" + filename)
          thisEvent.character_name = filename
          thisEvent.turn_down if berryData[0] == 2   # X sprouted
          thisEvent.turn_left if berryData[0] == 3   # X taller
          thisEvent.turn_right if berryData[0] == 4  # X flowering
          thisEvent.turn_up if berryData[0] == 5     # X berries
        end
        thisEvent.update
        interp.setVariable(berryData)
      end
  end
end

def pbPickBerry(berry, qty = 1)
  interp = pbMapInterpreter
  thisEvent = interp.get_character(0)
  berryData = interp.getVariable
  berryplural = _INTL("unknown berries")
  for i in BerryPlantSprite::BERRYVALUES
    if berry == i[0]
      berryplural = i[4]
      break
    end
  end
  if qty > 1
    Kernel.pbMessage(_INTL("There are {1} {2}!", qty, berryplural))
    askmessage = _INTL("Would you like to pick the berries?")
  else
    Kernel.pbMessage(_INTL("There is 1 {1}!", getItemName(berry)))
    askmessage = _INTL("Would you like to pick the berry?")
  end
  if Kernel.pbConfirmMessage(askmessage)
    if !$PokemonBag.pbCanStore?(berry, qty)
      Kernel.pbMessage(_INTL("Too bad...\nThe bag is full."))
      return
    end
    $PokemonBag.pbStoreItem(berry, qty)
    if qty > 1
      Kernel.pbMessage(_INTL("{1} picked {2} {3}!\\wtnp[30]", $Trainer.name, qty, berryplural))
      Kernel.pbMessage(_INTL("{1} put the {2} {3} in the Berries Pocket.\1", $Trainer.name, qty, berryplural))
    else
      Kernel.pbMessage(_INTL("{1} picked the {2}!\\wtnp[30]", $Trainer.name, getItemName(berry)))
      Kernel.pbMessage(_INTL("{1} put the {2} in the Berries Pocket.\1", $Trainer.name, getItemName(berry)))
    end
    Kernel.pbMessage(_INTL("The soil returned to its soft and loamy state.\1"))
    berryData = [0, 0, false, 0, 0, 0, -1]
    interp.setVariable(berryData)
    pbSetSelfSwitch(thisEvent.id, "A", true)
  end
end

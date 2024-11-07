module Blindstep
  @@step = false

  def self.player_move(direction)
    stepVolume = $Settings.footstepVolume
    return if stepVolume == 0
    return if $Settings.accessibilityVolume == 0

    if $PokemonGlobal.surfing || $PokemonGlobal.diving
      pbAccessibilitySEPlay("Blindstep- Waterstep_D", stepVolume, @@step ? 80 : 100) if direction == 2
      pbAccessibilitySEPlay("Blindstep- Waterstep", stepVolume, @@step ? 80 : 100, x: Math.sin(-60 * Math::PI / 180), z: Math.cos(-60 * Math::PI / 180)) if direction == 4
      pbAccessibilitySEPlay("Blindstep- Waterstep", stepVolume, @@step ? 80 : 100, x: Math.sin(60 * Math::PI / 180), z: Math.cos(60 * Math::PI / 180)) if direction == 6
      pbAccessibilitySEPlay("Blindstep- Waterstep_U", stepVolume, @@step ? 80 : 100) if direction == 8
    else
      pbAccessibilitySEPlay("Blindstep- Footstep_D", stepVolume, @@step ? 80 : 100) if direction == 2
      pbAccessibilitySEPlay("Blindstep- Footstep_L", stepVolume, @@step ? 80 : 100) if direction == 4
      pbAccessibilitySEPlay("Blindstep- Footstep_R", stepVolume, @@step ? 80 : 100) if direction == 6
      pbAccessibilitySEPlay("Blindstep- Footstep_U", stepVolume, @@step ? 80 : 100) if direction == 8
    end
    @@step = !@@step
  end

  def self.character_update()
    return if pbMapInterpreterRunning? || $game_temp.message_window_showing
    return if $Settings.accessibilityVolume == 0

    rate = $Settings.ambientRate
    remainder = Graphics.frame_count % (rate * ($speed_up ? $Settings.turboSpeedMultiplier : 1)).floor

    if remainder == 0
      self.playAmbientSounds
      return if self.getFacingEventType == 0

      eventVolume = $Settings.eventVolume
      return if eventVolume == 0

      playerDirection = $game_player.direction
      case playerDirection
      when 8
        # pbAccessibilitySEPlay("Blindstep- Door", eventVolume, 80) if door
        pbAccessibilitySEPlay("Blindstep- ImmediateEvent", eventVolume, 80)
      when 2
        # pbAccessibilitySEPlay("Blindstep- Door", eventVolume, 20) if door
        pbAccessibilitySEPlay("Blindstep- ImmediateEvent", eventVolume, 20)
      when 4
        # pbAccessibilitySEPlay("Blindstep- DoorL", eventVolume) if door
        pbAccessibilitySEPlay("Blindstep- ImmediateEventL", eventVolume)
      when 6
        # pbAccessibilitySEPlay("Blindstep- DoorR", eventVolume) if door
        pbAccessibilitySEPlay("Blindstep- ImmediateEventR", eventVolume)
      end
    end
  end

  def self.playAmbientSounds
    wallVolume = $Settings.wallVolume
    return if wallVolume == 0
    return if $Settings.accessibilityVolume == 0

    volumeNorth = self.getDirectionVolume(8) * wallVolume / 100.0
    volumeSouth = self.getDirectionVolume(2) * wallVolume / 100.0
    volumeWest = self.getDirectionVolume(4) * wallVolume / 100.0
    volumeEast = self.getDirectionVolume(6) * wallVolume / 100.0

    pbAccessibilitySEPlay("Blindstep- AmbientNorth", volumeNorth) if volumeNorth > 0
    pbAccessibilitySEPlay("Blindstep- AmbientSouth", volumeSouth) if volumeSouth > 0
    pbAccessibilitySEPlay("Blindstep- AmbientWest", volumeWest) if volumeWest > 0
    pbAccessibilitySEPlay("Blindstep- AmbientEast", volumeEast) if volumeEast > 0
  end

  def self.getDirectionVolume(direction)
    radius = $Settings.wallRange
    x = $game_player.x
    y = $game_player.y
    intensity = radius
    while intensity > 0
      break unless $game_player.passable?(x, y, direction)

      intensity -= 1
      y += 1 if direction == 2
      x -= 1 if direction == 4
      x += 1 if direction == 6
      y -= 1 if direction == 8
    end
    return 100 * intensity / radius
  end

  def self.getFacingEventType
    event = $game_player.pbFacingEvent
    return 0 unless event
    # Ignore non-interactable events
    return 0 if event.trigger != 0 || event.list.length <= 1
    return 2 if event.name == "Item"

    # TODO: Separate value for door
    return 1
  end

  # TODO: This doesn't handle regions since Reborn only has one.
  def self.flyMenu()
    items = {}
    $cache.town_map.each do |key, value|
      if value.is_a?(TownMapData) && value.flyData != [] && $PokemonGlobal.visitedMaps[value.flyData[0]]
        items[value.name] = value.flyData
      end
    end
    items = items.sort_by { |key| key }.to_h
    cmd = Kernel.pbMessage("Choose destination...", items.keys, -1)
    if cmd == -1
      return nil
    end

    return items[items.keys[cmd]]
  end
end

class PokemonOptions
  attr_accessor :accessibilityVolume
  attr_accessor :footstepVolume
  attr_accessor :eventVolume
  attr_accessor :wallVolume
  attr_accessor :wallRange
  attr_accessor :ambientRate

  alias fixMissingValuesGeneral fixMissingValues

  def fixMissingValues
    fixMissingValuesGeneral
    @accessibilityVolume = 100 if @accessibilityVolume.nil? # Volume (0 - 100)
    @footstepVolume      = 100 if @footstepVolume.nil? # Volume (0 - 100)
    @eventVolume         = 75 if @eventVolume.nil? # Volume (0 - 100)
    @wallVolume          = 100 if @wallVolume.nil? # Volume (0 - 100)
    @wallRange           = 3 if @wallRange.nil? # Ambient SE wall detection range (1 - 6)
    @ambientRate         = 40 if @ambientRate.nil? # Ambient SE rate (10 - 200)
  end
end

class PokemonBlindstepOptionScene < PokemonOptionScene
  def initialize
    @title = "Accessibility Options"
  end

  def initOptions
    optionList = []
    optionList.push NumberOption.new(
      _INTL("Accessibility Volume"), _INTL("Type %d"), 0, 100, 1,
      proc { $Settings.accessibilityVolume },
      proc { |value| $Settings.accessibilityVolume = value },
      "Volume of sound effects for accessibility. Affects all Blindstep sounds."
    )
    optionList.push NumberOption.new(
      _INTL("Footstep Volume"), _INTL("Type %d"), 0, 100, 1,
      proc { $Settings.footstepVolume },
      proc { |value| $Settings.footstepVolume = value },
      "Volume of footstep sound effects."
    )
    optionList.push NumberOption.new(
      _INTL("Event Volume"), _INTL("Type %d"), 0, 100, 1,
      proc { $Settings.eventVolume },
      proc { |value| $Settings.eventVolume = value },
      "Volume of immediate event sound effects when the player faces it."
    )
    optionList.push NumberOption.new(
      _INTL("Wall Volume"), _INTL("Type %d"), 0, 100, 1,
      proc { $Settings.wallVolume },
      proc { |value| $Settings.wallVolume = value },
      "Volume of wall sound effects."
    )
    optionList.push NumberOption.new(
      _INTL("Wall Range"), _INTL("Type %d"), 1, 6, 1,
      proc { $Settings.wallRange - 1 },
      proc { |value| $Settings.wallRange = value + 1 },
      "Range of wall detection for wall sound effects."
    )
    optionList.push NumberOption.new(
      _INTL("Ambient SE Rate"), _INTL("Type %d"), 10, 200, 1,
      proc { $Settings.ambientRate - 10 },
      proc { |value| $Settings.ambientRate = value + 10 },
      "Rate (in frames) of event and wall sound effects. 40 frames is 1 second."
    )
    return optionList
  end
end

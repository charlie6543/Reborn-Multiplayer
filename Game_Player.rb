#===============================================================================
# ** Game_Player
#-------------------------------------------------------------------------------
#  This class handles the player. Its functions include event starting
#  determinants and map scrolling. Refer to "$game_player" for the one
#  instance of this class.
#===============================================================================
class Game_Player < Game_Character
  attr_accessor :bump_se

  def map
    @map = nil
    return $game_map
  end

  def initialize(*arg)
    super(*arg)
    @lastdir = 0
    @lastdirframe = 0
    @bump_se = 0
    @waiter = 0
  end

  # how many pixels high is the bush?
  def bush_depth
    return 0 if @tile_id > 0 || @always_on_top

    xbehind = (@direction == 4) ? @x + 1 : (@direction == 6) ? @x - 1 : @x
    ybehind = (@direction == 8) ? @y + 1 : (@direction == 2) ? @y - 1 : @y
    if !$game_map.valid?(@x, @y) || !$game_map.valid?(xbehind, ybehind)
      return 0 if !$MapFactory

      newhere = $MapFactory.getNewMap(@x, @y)
      newbehind = $MapFactory.getNewMap(xbehind, ybehind)
      if $game_map.valid?(@x, @y)
        heremap = self.map; herex = @x; herey = @y
      elsif newhere && newhere[0]
        heremap = newhere[0]; herex = newhere[1]; herey = newhere[2]
      else
        return 0
      end
      if $game_map.valid?(xbehind, ybehind)
        behindmap = self.map; behindx = xbehind; behindy = ybehind
      elsif newbehind && newbehind[0]
        behindmap = newbehind[0]; behindx = newbehind[1]; behindy = newbehind[2]
      else
        return 0
      end
      if @jump_count <= 0
        if heremap.deepBush?(herex, herey) && behindmap.deepBush?(behindx, behindy)
          return 32
        elsif heremap.bush?(herex, herey) && !moving?
          return 12
        else
          return 0
        end
      else
        return 0
      end
    else
      return super
    end
  end

  def pbHasDependentEvents?
    return $PokemonGlobal.dependentEvents.length > 0
  end

  def move_down(turn_enabled = true)
    if turn_enabled
      turn_down
    end
    if passable?(@x, @y, 2)
      if !@direction_fix
        return if pbLedge
      end
      return if pbEndSurf
      return if pbEndLavaSurf

      turn_down if turn_enabled
      @y += 1
      Blindstep.player_move(2) if $game_switches[:Blindstep]
      if turn_enabled || $PokemonGlobal.sliding
        $PokemonTemp.dependentEvents.pbMoveDependentEvents(@x, @y - 1)
      end
      increase_steps
    else
      if !check_event_trigger_touch(@x, @y + 1)
        if !@bump_se || @bump_se <= 0
          playBumpSE()
          @bump_se = 10
        end
      end
    end
  end

  def move_left(turn_enabled = true)
    if turn_enabled
      turn_left
    end
    if passable?(@x, @y, 4)
      if !@direction_fix
        return if pbLedge
      end
      return if pbEndSurf
      return if pbEndLavaSurf

      turn_left if turn_enabled
      @x -= 1
      Blindstep.player_move(4) if $game_switches[:Blindstep]
      if turn_enabled || $PokemonGlobal.sliding
        $PokemonTemp.dependentEvents.pbMoveDependentEvents(@x + 1, @y)
      end
      increase_steps
    else
      if !check_event_trigger_touch(@x - 1, @y)
        if !@bump_se || @bump_se <= 0
          playBumpSE()
          @bump_se = 10
        end
      end
    end
  end

  def move_right(turn_enabled = true)
    if turn_enabled
      turn_right
    end
    if passable?(@x, @y, 6)
      if !@direction_fix
        return if pbLedge
      end
      return if pbEndSurf
      return if pbEndLavaSurf

      turn_right if turn_enabled
      @x += 1
      Blindstep.player_move(6) if $game_switches[:Blindstep]
      if turn_enabled || $PokemonGlobal.sliding
        $PokemonTemp.dependentEvents.pbMoveDependentEvents(@x - 1, @y)
      end
      increase_steps
    else
      if !check_event_trigger_touch(@x + 1, @y)
        if !@bump_se || @bump_se <= 0
          playBumpSE()
          @bump_se = 10
        end
      end
    end
  end

  def move_up(turn_enabled = true)
    if turn_enabled
      turn_up
    end
    if passable?(@x, @y, 8)
      if !@direction_fix
        return if pbLedge
      end
      return if pbEndSurf
      return if pbEndLavaSurf

      turn_up if turn_enabled
      @y -= 1
      Blindstep.player_move(8) if $game_switches[:Blindstep]
      if turn_enabled || $PokemonGlobal.sliding
        $PokemonTemp.dependentEvents.pbMoveDependentEvents(@x, @y + 1)
      end
      increase_steps
    else
      if !check_event_trigger_touch(@x, @y - 1)
        if !@bump_se || @bump_se <= 0
          playBumpSE()
          @bump_se = 10
        end
      end
    end
  end

  def playBumpSE
    unless Reborn
      pbSEPlay("bump")
      return
    end

    terrain = Kernel.pbFacingTerrainTag
    event = pbFacingEvent()
    eventName = event.nil? ? "" : event.name
    character = event.nil? ? "" : event.character_name
    eventHasCommands = event.nil? || event.list.nil? ? false : event.list.length > 1

    # check events
    # npcs
    return pbSEPlay("bump-npc") if character.start_with?("trchar") || character.start_with?("NPC ") || character.start_with?("rby_char")
    # overworld pokemon
    return pbSEPlay("bump-pkmn") if character.start_with?("pkmn_")
    # berry tree
    return pbSEPlay("bump-berrytree") if character.start_with?("berrytree")
    # chess pieces, Agate Gym and VR tuners, Mirage Tower controllers/receivers
    return pbSEPlay("bump-block") if character.start_with?("chess") || eventName.start_with?("Tuner ") || eventName.start_with?("2Tuner ") || eventName.start_with?("Controller") || eventName.start_with?("Receiver")
    # cut tree
    return pbSEPlay("bump-cut") if eventName == "Tree"
    # headbutt tree
    return pbSEPlay("bump-headbutt") if eventName == "HeadbuttTree"
    # rock smash rock
    return pbSEPlay("bump-rocksmash") if eventName == "Rock"
    # breakable mirrors
    return pbSEPlay("bump-mirror") if eventName == "Glass"
    # zygarde cells
    return pbSEPlay("bump-zcell") if character == "zycell"
    # item balls
    return pbSEPlay("bump-item") if character.start_with?("itemball")
    # rock climb check names? found one in celestine that's wrong
    return pbSEPlay("bump-rockclimb") if eventName.start_with?("RockClimb") && eventHasCommands
    # check terrains
    return pbSEPlay("bump-water") if pbIsJustWaterTag?(terrain)
    # bad water
    return pbSEPlay("bump-grime") if pbIsGrimeTag?(terrain)
    # waterfall
    return pbSEPlay("bump-waterfall") if terrain == PBTerrain::WaterfallCrest || terrain == PBTerrain::Waterfall
    # ledge
    return pbSEPlay("bump-ledge") if terrain == PBTerrain::Ledge
    # strength rocks handled in pbPushThisBoulder

    pbSEPlay("bump")
  end

  def pbTriggeredTrainerEvents(triggers, checkIfRunning = true)
    result = []
    # If event is running
    if checkIfRunning && $game_system.map_interpreter.running?
      return result
    end

    # All event loops
    for event in $game_map.events.values
      next if !event.name[/^Trainer\((\d+)\)$/]

      distance = $~[1].to_i
      # If event coordinates and triggers are consistent
      if pbEventCanReachPlayer?(event, self, distance) && triggers.include?(event.trigger)
        # If starting determinant is front event (other than jumping)
        if !event.jumping? && !event.over_trigger?
          result.push(event)
        end
      end
    end
    return result
  end

  def pbTriggeredCounterEvents(triggers, checkIfRunning = true)
    result = []
    # If event is running
    if checkIfRunning && $game_system.map_interpreter.running?
      return result
    end

    # All event loops
    for event in $game_map.events.values
      next if !event.name[/^Counter\((\d+)\)$/]

      distance = $~[1].to_i
      # If event coordinates and triggers are consistent
      if pbEventFacesPlayer?(event, self, distance) && triggers.include?(event.trigger)
        # If starting determinant is front event (other than jumping)
        if !event.jumping? && !event.over_trigger?
          result.push(event)
        end
      end
    end
    return result
  end

  def pbCheckEventTriggerAfterTurning
  end

  def pbCheckEventTriggerFromDistance(triggers)
    ret = pbTriggeredTrainerEvents(triggers)
    ret.concat(pbTriggeredCounterEvents(triggers))
    return false if ret.length == 0

    for event in ret
      event.start
    end
    return true
  end

  def pbTerrainTag
    return $MapFactory.getTerrainTag(self.map.map_id, @x, @y) if $MapFactory

    return $game_map.terrain_tag(@x, @y)
  end

  def pbFacingEvent
    if $game_system.map_interpreter.running?
      return nil
    end

    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    for event in $game_map.events.values
      if event.x == new_x && event.y == new_y
        if !event.jumping? && !event.over_trigger?
          return event
        end
      end
    end
    if $game_map.counter?(new_x, new_y)
      new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
      new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
      for event in $game_map.events.values
        if event.x == new_x && event.y == new_y
          if !event.jumping? && !event.over_trigger?
            return event
          end
        end
      end
    end
    return nil
  end

  #-----------------------------------------------------------------------------
  # * Passable Determinants
  #     x : x-coordinate
  #     y : y-coordinate
  #     d : direction (0,2,4,6,8)
  #         * 0 = Determines if all directions are impassable (for jumping)
  #-----------------------------------------------------------------------------
  def passable?(x, y, d)
    # Get new coordinates
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # If coordinates are outside of map
    unless $game_map.validLax?(new_x, new_y)
      # Impassable
      return false
    end

    if !$game_map.valid?(new_x, new_y)
      return false if !$MapFactory

      return $MapFactory.isPassableFromEdge?(new_x, new_y)
    end
    # If debug mode is ON and ctrl key was pressed
    if $DEBUG && Input.press?(Input::CTRL)
      # Passable
      return true
    end

    super
  end

  #-----------------------------------------------------------------------------
  # * Set Map Display Position to Center of Screen
  #-----------------------------------------------------------------------------
  def center(x, y)
    # X coordinate in the center of the screen
    center_x = (Graphics.width * 2 - 64)
    # Y coordinate in the center of the screen
    center_y = (Graphics.height * 2 - 64)
    dispx = x * 128 - center_x
    dispy = y * 128 - center_y
    self.map.display_x = dispx
    self.map.display_y = dispy
  end

  #-----------------------------------------------------------------------------
  # * Move to Designated Position
  #     x : x-coordinate
  #     y : y-coordinate
  #-----------------------------------------------------------------------------
  def moveto(x, y)
    super
    # Centering
    center(x, y)
    # Make encounter count
    make_encounter_count
  end

  #-----------------------------------------------------------------------------
  # * Get Encounter Count
  #-----------------------------------------------------------------------------
  def encounter_count
    return @encounter_count
  end

  #-----------------------------------------------------------------------------
  # * Make Encounter Count
  #-----------------------------------------------------------------------------
  def make_encounter_count
    # Image of two dice rolling
    if $game_map.map_id != 0
      n = $game_map.encounter_step
      @encounter_count = rand(n) + rand(n) + 1
    end
  end

  #-----------------------------------------------------------------------------
  # * Refresh
  #-----------------------------------------------------------------------------
  def refresh
    @opacity = 255
    @blend_type = 0
  end

  #-----------------------------------------------------------------------------
  # * Same Position Starting Determinant
  #-----------------------------------------------------------------------------
  def check_event_trigger_here(triggers)
    result = false
    # If event is running
    if $game_system.map_interpreter.running?
      return result
    end

    # All event loops
    for event in $game_map.events.values
      # If event coordinates and triggers are consistent
      if event.x == @x && event.y == @y && triggers.include?(event.trigger)
        # If starting determinant is same position event (other than jumping)
        if !event.jumping? && event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end

  #-----------------------------------------------------------------------------
  # * Front Event Starting Determinant
  #-----------------------------------------------------------------------------
  def check_event_trigger_there(triggers)
    result = false
    # If event is running
    if $game_system.map_interpreter.running?
      return result
    end

    # Calculate front event coordinates
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    # All event loops
    for event in $game_map.events.values
      # If event coordinates and triggers are consistent
      if event.x == new_x && event.y == new_y &&
         triggers.include?(event.trigger)
        # If starting determinant is front event (other than jumping)
        if !event.jumping? && !event.over_trigger?
          event.start
          result = true
        end
      end
    end
    # If fitting event is not found
    if !result
      # If front tile is a counter
      if $game_map.counter?(new_x, new_y)
        # Calculate 1 tile inside coordinates
        new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
        new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
        # All event loops
        for event in $game_map.events.values
          # If event coordinates and triggers are consistent
          if event.x == new_x && event.y == new_y &&
             triggers.include?(event.trigger)
            # If starting determinant is front event (other than jumping)
            if !event.jumping? && !event.over_trigger?
              event.start
              result = true
            end
          end
        end
      end
    end
    return result
  end

  #-----------------------------------------------------------------------------
  # * Touch Event Starting Determinant
  #-----------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    result = false
    # If event is running
    if $game_system.map_interpreter.running?
      return result
    end

    # All event loops
    for event in $game_map.events.values
      if event.name[/^Trainer\((\d+)\)$/]
        distance = $~[1].to_i
        next if !pbEventCanReachPlayer?(event, self, distance)
      end
      if event.name[/^Counter\((\d+)\)$/]
        distance = $~[1].to_i
        next if !pbEventFacesPlayer?(event, self, distance)
      end
      # If event coordinates and triggers are consistent
      if event.x == x && event.y == y && [1, 2].include?(event.trigger)
        # If starting determinant is front event (other than jumping)
        if !event.jumping? && !event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end

  #-----------------------------------------------------------------------------
  # * Frame Update
  #-----------------------------------------------------------------------------
  def update
    # Remember whether or not moving in local variables
    last_moving = moving?
    # If moving, event running, move route forcing, and message window
    # display are all not occurring
    dir = Input.dir4

    unless moving? || $game_system.map_interpreter.running? ||
           @move_route_forcing || $game_temp.message_window_showing ||
           $PokemonTemp.miniupdate
      # Move player in the direction the directional button is being pressed
      @waiter = 0 if !@waiter
      @waiter = ($speed_up ? $Settings.turboSpeedMultiplier : 1).floor if @lastdir != dir && Graphics.frame_count - @lastdirframe != 1
      @waiter -= 1
      if dir == @lastdir && Graphics.frame_count - @lastdirframe > 0 && !(TAB_TURBO && Input.press?(Input::ALT))
        case dir
          when 2 then move_down
          when 4 then move_left
          when 6 then move_right
          when 8 then move_up
        end
      elsif dir != @lastdir && Graphics.frame_count - @lastdirframe > 0
        case dir
          when 2 then turn_down
          when 4 then turn_left
          when 6 then turn_right
          when 8 then turn_up
        end
      end
    end
    $PokemonTemp.dependentEvents.updateDependentEvents
    @waiter = 0 if !@waiter

    @lastdir = dir if @waiter < 0
    @lastdirframe = Graphics.frame_count if dir != 0
    # Remember coordinates in local variables
    last_real_x = @real_x
    last_real_y = @real_y
    super
    center_x = (Graphics.width / 2 - Game_Map::TILEWIDTH / 2) *
               Game_Map::XSUBPIXEL   # Center screen x-coordinate * 4
    center_y = (Graphics.height / 2 - Game_Map::TILEHEIGHT / 2) *
               Game_Map::YSUBPIXEL   # Center screen y-coordinate * 4
    # If character moves down and is positioned lower than the center
    # of the screen
    if @real_y > last_real_y && @real_y - $game_map.display_y > center_y
      # Scroll map down
      $game_map.scroll_down(@real_y - last_real_y)
    end
    # If character moves left and is positioned more left on-screen than
    # center
    if @real_x < last_real_x && @real_x - $game_map.display_x < center_x
      # Scroll map left
      $game_map.scroll_left(last_real_x - @real_x)
    end
    # If character moves right and is positioned more right on-screen than
    # center
    if @real_x > last_real_x && @real_x - $game_map.display_x > center_x
      # Scroll map right
      $game_map.scroll_right(@real_x - last_real_x)
    end
    # If character moves up and is positioned higher than the center
    # of the screen
    if @real_y < last_real_y && @real_y - $game_map.display_y < center_y
      # Scroll map up
      $game_map.scroll_up(last_real_y - @real_y)
    end
    # Count down the time between allowed bump sounds
    @bump_se -= 1 if @bump_se && @bump_se > 0
    # If not moving
    unless moving?
      # If player was moving last time
      if last_moving
        $PokemonTemp.dependentEvents.pbTurnDependentEvents
        result = pbCheckEventTriggerFromDistance([2])
        # Event determinant is via touch of same position event
        result |= check_event_trigger_here([1, 2])
        # If event which started does not exist
        Kernel.pbOnStepTaken(result) # *Added function call
      end
      # If C button was pressed
      if Input.trigger?(Input::C) && !$PokemonTemp.miniupdate
        # Same position and front event determinant
        check_event_trigger_here([0])
        check_event_trigger_there([0, 2]) # *Modified to prevent unnecessary triggers
      end
    end
  end
end

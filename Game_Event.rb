class Game_Event < Game_Character
  attr_reader   :trigger
  attr_reader   :list
  attr_reader   :starting
  attr_reader   :tempSwitches # Temporary self-switches
  attr_accessor :need_refresh
  attr_accessor :need_update

  def initialize(map_id, event, map = nil)
    super(map)
    @map_id = map_id
    @event = event
    @id = @event.id
    @erased = false
    @starting = false
    @need_refresh = false
    @need_update = false
    @route_erased = false
    @through = true
    @tempSwitches = {}
    moveto(@event.x, @event.y) if map
    refresh
  end

  #--------------------------------------------------------------------------
  # * Get Screen Z-Coordinates
  #     height : character height
  #--------------------------------------------------------------------------
  def screen_z(height = 0)
    return 0 if @always_on_top && @event.name[-20, 20] == "invert_always_on_top"

    # If display flag on closest surface is ON
    return 999 if @always_on_top

    # Get screen coordinates from real coordinates and map display position
    z = screen_y_ground

    # If tile
    return z + self.map.priorities[@tile_id] * 32 if @tile_id > 0

    # If character
    if @event.name[-6, 6] == "bottom"
      return [z - 64, 0].max
    elsif @event.name[-6, 6] == "ottom2"
      return [z - 128, 0].max
    end

    return z + ((height > 32) ? 31 : 0)
  end

  def map_id
    @map_id
  end

  def clear_starting
    @starting = false
  end

  def over_trigger?
    if @character_name != "" && !@through
      return false
    end
    if @event.name == "HiddenItem"
      return false
    end
    unless self.map.passable?(@x, @y, 0)
      return false
    end

    return true
  end

  def start
    if @list.size > 1
      @starting = true
    end
  end

  def erase
    @erased = true
    refresh
  end

  def erase_route
    @route_erased = true
    refresh
  end

  def name
    return @event.name
  end

  def id
    return @event.id
  end

  def pbCheckEventTriggerAfterTurning
    if $game_system.map_interpreter.running? || @starting
      return
    end

    if @event.name[/^Trainer\((\d+)\)$/]
      distance = $~[1].to_i
      if @trigger == 2 && pbEventCanReachPlayer?(self, $game_player, distance)
        if !jumping? && !over_trigger?
          start
        end
      end
    end
  end

  def tsOn?(c)
    return @tempSwitches && @tempSwitches[c] == true
  end

  def tsOff?(c)
    return !@tempSwitches || !@tempSwitches[c]
  end

  def setTempSwitchOn(c)
    @tempSwitches[c] = true
    refresh
  end

  def setTempSwitchOff(c)
    @tempSwitches[c] = false
    refresh
  end

  def variable
    return nil if !$PokemonGlobal.eventvars

    return $PokemonGlobal.eventvars[[@map_id, @event.id]]
  end

  def setVariable(variable)
    $PokemonGlobal.eventvars[[@map_id, @event.id]] = variable
  end

  def varAsInt
    return 0 if !$PokemonGlobal.eventvars

    return $PokemonGlobal.eventvars[[@map_id, @event.id]].to_i
  end

  def expired?(secs = 86400)
    ontime = self.variable
    time = pbGetTimeNow
    return ontime && (time.to_i - ontime).abs > secs
  end

  def expiredDays?(days = 1)
    ontime = self.variable.to_i
    return false if !ontime

    now = pbGetTimeNow
    elapsed = (now.to_i - ontime).abs / 86400
    elapsed += 1 if (now.to_i - ontime) % 86400 > (now.hour * 3600 + now.min * 60 + now.sec)
    return elapsed >= days
  end

  def onEvent?
    return @map_id == $game_map.map_id &&
           $game_player.x == self.x && $game_player.y == self.y
  end

  def isOff?(c)
    return !$game_self_switches[[@map_id, @event.id, c]]
  end

  def switchIsOn?(id)
    switchname = $cache.RXsystem.switches[id]
    return false if !switchname
    if switchname[/^s\:/]
      return eval($~.post_match)
    else
      return $game_switches[id]
    end
  end

  def variableIsActive?(id, value)
    varname = $cache.RXsystem.variables[id]
    return false if !varname
    if varname[/^s\:/]
      return eval($~.post_match) < value
    else
      return false if !$game_variables[id].is_a?(Numeric)

      return $game_variables[id] < value
    end
  end

  def graphicName
    return @event.pages[0].graphic.character_name
  end

  def refresh
    # Check which page active
    new_page = nil
    unless @erased
      for page in @event.pages.reverse
        c = page.condition
        next if c.switch1_valid && !switchIsOn?(c.switch1_id)
        next if c.switch2_valid && !switchIsOn?(c.switch2_id)
        next if c.variable_valid && variableIsActive?(c.variable_id, c.variable_value)

        if c.self_switch_valid
          key = [@map_id, @event.id, c.self_switch_ch]
          if $game_self_switches[key] != true
            next
          end
        end
        new_page = page
        break
      end
    end

    # No need to refresh if page isn't new
    return if new_page == @page

    # Set new page as active one
    @page = new_page
    clear_starting

    # if no page active
    if @page == nil
      @tile_id = 0
      @character_name = ""
      @character_hue = 0
      @move_type = 0
      @through = true
      @trigger = nil
      @list = nil
      @interpreter = nil
      return
    end

    # Update event attributes to that of page
    @tile_id = @page.graphic.tile_id
    @character_name = @page.graphic.character_name
    @character_hue = @page.graphic.character_hue
    if @original_direction != @page.graphic.direction
      @direction = @page.graphic.direction
      @original_direction = @direction
      @prelock_direction = 0
    end
    if @original_pattern != @page.graphic.pattern
      @pattern = @page.graphic.pattern
      @original_pattern = @pattern
    end
    @opacity = @page.graphic.opacity
    @blend_type = @page.graphic.blend_type
    @move_type = @page.move_type
    @move_speed = @page.move_speed * 1.25
    @move_frequency = @page.move_frequency
    @move_route = @route_erased ? RPG::MoveRoute.new : @page.move_route
    @move_route_index = 0
    @move_route_forcing = false
    @walk_anime = @page.walk_anime
    @step_anime = @page.step_anime
    @direction_fix = @page.direction_fix
    @through = @page.through
    @always_on_top = @page.always_on_top
    @trigger = @page.trigger
    @list = @page.list

    # Reset interpreter
    @interpreter = nil
    if @trigger == 4
      @interpreter = Interpreter.new
    end
    check_event_trigger_auto
  end

  def check_event_trigger_touch(x, y)
    if $game_system.map_interpreter.running?
      return
    end
    return if @trigger != 2
    return if x != $game_player.x || y != $game_player.y

    if !jumping? && !over_trigger?
      start
    end
  end

  def check_event_trigger_auto
    if @trigger == 2
      if @x == $game_player.x && @y == $game_player.y
        if !jumping? && over_trigger?
          start
        end
      end
    end
    if @trigger == 3
      start
    end
  end

  def update
    last_moving = moving?
    super
    if last_moving
      if moving?
        $game_player.pbCheckEventTriggerFromDistance([2])
      end
    end
    if @need_refresh
      @need_refresh = false
      refresh
    end
    check_event_trigger_auto
    if @interpreter != nil
      unless @interpreter.running?
        @interpreter.setup(@list, @event.id, @map_id)
      end
      @interpreter.update
    end
  end

  def graphical?
    return super || @event.pages.any? { |t| t.graphic.character_name != "" || t.graphic.tile_id != 0 }
  end

  def graphicalNow?
    return super
  end

  def set_starting
    @starting = true
  end

  def cooledDown?(seconds)
    if !(expired?(seconds) && tsOff?("A"))
      self.need_refresh = true
      return false
    else
      return true
    end
  end

  def cooledDownDays?(days)
    if !(expiredDays?(days) && tsOff?("A"))
      self.need_refresh = true
      return false
    else
      return true
    end
  end

  # Used to move dependent events between maps.
  def moveto_new_map(new_map)
    vector = $MapFactory.getRelativePos(new_map, 0, 0, self.map.map_id, @x, @y)
    @map = $MapFactory.getMap(new_map)
    # NOTE: Can't use moveto because vector is outside the boundaries of the
    #       map, and moveto doesn't allow setting invalid coordinates.
    @x = vector[0]
    @y = vector[1]
    @real_x = @x * Game_Map.realResX
    @real_y = @y * Game_Map.realResY
  end
end

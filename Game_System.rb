class Game_System
  attr_reader   :map_interpreter          # map event interpreter
  attr_reader   :battle_interpreter       # battle event interpreter
  attr_accessor :timer                    # timer
  attr_accessor :timer_working            # timer working flag
  attr_accessor :save_disabled            # save forbidden
  attr_accessor :menu_disabled            # menu forbidden
  attr_accessor :encounter_disabled       # encounter forbidden
  attr_accessor :message_position         # text option: positioning
  attr_accessor :message_frame            # text option: window frame
  attr_accessor :save_count               # save count
  attr_accessor :magic_number             # magic number
  attr_accessor :autoscroll_x_speed
  attr_accessor :autoscroll_y_speed
  attr_accessor :bgm_position
  attr_accessor :game_version
  attr_accessor :saved_bgm


  def initialize
    @map_interpreter = Interpreter.new(0, true)
    @battle_interpreter = Interpreter.new(0, false)
    @timer = 0
    @timer_working = false
    @save_disabled = false
    @menu_disabled = false
    @encounter_disabled = false
    @message_position = 2
    @message_frame = 0
    @save_count = 0
    @magic_number = 0
    @autoscroll_x_speed = 0
    @autoscroll_y_speed = 0
    @bgm_position = 0
    @bgs_position = 0
    @saved_bgm = nil
    @game_version = GAMEVERSION
  end

  def newInterp
    @map_interpreter = Interpreter.new(0, true)
  end

  def toggle_mute(bgmonly = false)
    $game_mute = $game_mute.nil? ? true : !$game_mute
    if $game_mute
      @bgm_position = Audio.bgm_pos
      Audio.bgm_fade(500)
      self.bgs_stop if bgmonly == false
      self.se_stop if bgmonly == false
      self.me_play(nil) if bgmonly == false
    else
      self.bgm_play_internal(@playing_bgm, @bgm_position)
    end
  end

  def resolve_volume(volume)
    return 0 if $game_mute

    return volume
  end

  def bgm_play(bgm)
    return if bgm != nil &&
              @playing_bgm != nil &&
              @playing_bgm.name == bgm.name &&
              @playing_bgm.volume == bgm.volume &&
              @playing_bgm.pitch == bgm.pitch

    bgm_play_internal(bgm, 0)
  end

  def bgm_play_internal2(name, volume, pitch, position) # :nodoc:
    begin
      Audio.bgm_play(name, self.resolve_volume(volume), pitch, position)
    rescue ArgumentError
      Audio.bgm_play(name, self.resolve_volume(volume), pitch)
    end
  end

  def bgm_play_internal(bgm, position) # :nodoc:
    @saved_bgm = bgm
    if !@bgm_paused
      @bgm_position = position
    end
    @playing_bgm = bgm == nil ? nil : bgm.clone
    if bgm != nil && bgm.name != ""
      if FileTest.audio_exist?("Audio/BGM/" + bgm.name)
        bgm_play_internal2("Audio/BGM/" + bgm.name, bgm.volume, bgm.pitch, @bgm_position) if !@defaultBGM
      end
    else
      if !@bgm_paused
        @bgm_position = position
      end
      @playing_bgm = nil
      Audio.bgm_stop if !@defaultBGM
    end
    if @defaultBGM
      bgm_play_internal2("Audio/BGM/" + @defaultBGM.name, @defaultBGM.volume, @defaultBGM.pitch, @bgm_position)
    end
    Graphics.frame_reset
  end

  def bgm_pause(fadetime = 0.0) # :nodoc:
    # pos=Audio.bgm_position rescue 0
    if fadetime > 0.0
      self.bgm_fade(fadetime)
    end
    # @bgm_position=pos
    @bgm_paused = true
  end

  def bgs_pause(fadetime = 0.0) # :nodoc:
    if fadetime > 0.0
      self.bgs_fade(fadetime)
    else
      self.bgs_stop
    end
    @bgs_paused = true
  end

  def bgm_unpause;  # :nodoc:
    @bgm_position = 0; @bgm_paused = false;
  end

  def bgs_unpause;  # :nodoc:
    @bgs_paused = false
  end

  def bgm_resume(bgm, position = nil) # :nodoc:
    @bgm_position = position if position
    if @bgm_paused
      self.bgm_play_internal(bgm, @bgm_position)
      @bgm_position = 0
      @bgm_paused = false
    end
  end

  def bgs_resume(bgs) # :nodoc:
    if @bgs_paused
      self.bgs_play(bgs)
      @bgs_paused = false
    end
  end

  def bgm_stop # :nodoc:
    @saved_bgm = nil
    if !@bgm_paused
      @bgm_position = 0
    end
    @playing_bgm = nil
    Audio.bgm_stop if !@defaultBGM
  end

  def bgm_fade(time) # :nodoc:
    @saved_bgm = nil
    if !@bgm_paused
      @bgm_position = 0
    end
    @playing_bgm = nil
    Audio.bgm_fade((time * 1000).floor) if !@defaultBGM
  end

  # Returns an RPG::AudioFile object for the currently playing background music
  def getPlayingBGM
    return @playing_bgm ? @playing_bgm.clone : nil
  end

  # Saves the currently playing background music for later playback.
  def bgm_memorize
    @memorized_bgm = @playing_bgm
  end

  # Plays the currently memorized background music
  def bgm_restore
    bgm_play(@memorized_bgm)
  end

  def bgs_play(bgs)
    @playing_bgs = bgs == nil ? nil : bgs.clone
    if bgs != nil && bgs.name != ""
      if FileTest.audio_exist?("Audio/BGS/" + bgs.name)
        Audio.bgs_play("Audio/BGS/" + bgs.name, self.resolve_volume(bgs.volume), bgs.pitch)
      end
    else
      @bgs_position = 0
      @playing_bgs = nil
      Audio.bgs_stop
    end
    Graphics.frame_reset
  end

  def bgs_fade(time)
    @bgs_position = 0
    @playing_bgs = nil
    Audio.bgs_fade((time * 1000).floor)
  end

  def bgs_stop
    @bgs_position = 0
    @playing_bgs = nil
    Audio.bgs_stop
  end

  def getPlayingBGS
    return @playing_bgs ? @playing_bgs.clone : nil
  end

  def bgs_memorize
    @memorized_bgs = @playing_bgs
  end

  def bgs_restore
    bgs_play(@memorized_bgs)
  end

  def setDefaultBGM(bgm, volume = $Settings.volume, pitch = 100)
    if bgm.is_a?(String)
      bgm = RPG::AudioFile.new(bgm, volume, pitch)
    end
    if bgm != nil && bgm.name != ""
      @defaultBGM = nil
      self.bgm_play(bgm)
      @defaultBGM = bgm.clone
      @playing_bgm = bgm.clone
    else
      @defaultBGM = nil
      bgm = @playing_bgm
      @playing_bgm = nil
      self.bgm_play(bgm)
    end
  end

  def me_play(me)
    if me.is_a?(String)
      me = RPG::AudioFile.new(me)
    end
    if me != nil && me.name != ""
      if FileTest.audio_exist?("Audio/ME/" + me.name)
        Audio.me_play("Audio/ME/" + me.name, self.resolve_volume(me.volume), me.pitch)
      end
    else
      Audio.me_stop
    end
    Graphics.frame_reset
  end

  def se_play(se, x: 0, y: 0, z: 0)
    if se.is_a?(String)
      se = RPG::AudioFile.new(se)
    end
    if se != nil && se.name != ""
      se.name = File.basename(se.name, File.extname(se.name))
      if FileTest.audio_exist?("Audio/SE/" + se.name)
        internal_se_play("Audio/SE/" + se.name, self.resolve_volume(se.volume), se.pitch, x, y, z)
      end
    end
  end

  def se_stop
    Audio.se_stop
  end

  def playing_bgm
    return @playing_bgm
  end

  def playing_bgs
    return @playing_bgs
  end

  def windowskin_name
    if @windowskin_name == nil
      return $cache.RXsystem.windowskin_name
    else
      return @windowskin_name
    end
  end

  def windowskin_name=(windowskin_name)
    @windowskin_name = windowskin_name
  end

  def battle_bgm
    if @battle_bgm == nil
      return $cache.RXsystem.battle_bgm
    else
      return @battle_bgm
    end
  end

  def battle_bgm=(battle_bgm)
    @battle_bgm = battle_bgm
  end

  def battle_end_me
    if @battle_end_me == nil
      return $cache.RXsystem.battle_end_me
    else
      return @battle_end_me
    end
  end

  def battle_end_me=(battle_end_me)
    @battle_end_me = battle_end_me
  end

  def update
    if @timer_working && @timer > 0
      @timer -= 1
    end
    if Input.trigger?(Input::F5) && pbCurrentEventCommentInput(1, "Cut Scene")
      event = @map_interpreter.get_character(0)
      @map_interpreter.pbSetSelfSwitch(event.id, "A", true)
      @map_interpreter.command_end
      event.start
    end
  end
end

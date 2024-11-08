class Spriteset_Map
  attr_reader :map
  attr_reader :viewport1

  def initialize(map = nil)
    @map = map ? map : $game_map

    # Viewport
    @viewport1 = Viewport.new(0, 0, Graphics.width, Graphics.height) # Panorama, map, events, player, fog
    @viewport1a = Viewport.new(0, 0, Graphics.width, Graphics.height) # Weather
    @viewport1b = Viewport.new(0, 0, Graphics.width, Graphics.height) # HP Hud
    @viewport2 = Viewport.new(0, 0, Graphics.width, Graphics.height) # "Show Picture" event command pictures
    @viewport3 = Viewport.new(0, 0, Graphics.width, Graphics.height) # Flashing
    @viewport1a.z = 100
    @viewport1b.z = 99998
    @viewport2.z = 200
    @viewport3.z = 500

    # Tilemap
    @tilemap = ($joiplay && $Settings.performanceMode == 1) ? CustomTilemap.new(@viewport1) : Tilemap.new(@viewport1)
    @tilemap.tileset = pbGetTileset(@map.tileset_name)
    for i in 0...7
      autotile_name = @map.autotile_names[i]
      next if autotile_name == ""

      @tilemap.autotiles[i] = pbGetAutotile(autotile_name)
    end
    @tilemap.map_data = @map.data
    @tilemap.priorities = @map.priorities

    # Panorama and fog
    @panorama = AnimatedPlane.new(@viewport1)
    @panorama.z = -1000
    @fog = AnimatedPlane.new(@viewport1)
    @fog.z = 3000

    # Sprites
    @reflectedSprites = []
    @character_sprites = {}
    @character_sprites_bounds = []
    for i in @map.events.keys.sort
      # Performance optimization.
      # This can however break animations if the animation is assigned to an event which doesn't have a graphic.
      next if Reborn && !@map.events[i].graphical?

      sprite = Sprite_Character.new(@viewport1, @map.events[i])
      @character_sprites[i] = sprite
      @character_sprites_bounds[i] = sprite.getRect
      if ReflectSpritesOn.include?($game_map.map_id)
        @reflectedSprites.push(ReflectedSprite.new(sprite, @map.events[i], @viewport1))
      end
    end
    @playersprite = Sprite_Character.new(@viewport1, $game_player)
    @reflectedSprites.push(ReflectedSprite.new(@playersprite, $game_player, @viewport1))
    @character_sprites[$game_player.id] = @playersprite

    # Other
    @weather = RPG::Weather.new(@viewport1a)
    @picture_sprites = []
    for i in 1..50
      @picture_sprites.push(Sprite_Picture.new(@viewport2, $game_screen.pictures[i]))
    end
    @timer_sprite = Sprite_Timer.new
    Kernel.pbOnSpritesetCreate(self, @viewport1)
    update
  end

  def dispose
    @tilemap.tileset.dispose
    for i in 0...7
      @tilemap.autotiles[i].dispose if @tilemap.autotiles[i]
    end
    @tilemap.dispose
    @panorama.dispose
    @fog.dispose
    for sprite in @character_sprites.values
      sprite.dispose
    end
    for sprite in @reflectedSprites
      sprite.dispose
    end
    @weather.dispose
    for sprite in @picture_sprites
      sprite.dispose
    end
    @timer_sprite.dispose
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
    @tilemap = nil
    @panorama = nil
    @fog = nil
    @character_sprites.clear
    @reflectedSprites.clear
    @weather = nil
    @picture_sprites.clear
    @viewport1 = nil
    @viewport2 = nil
    @viewport3 = nil
    @timer_sprite = nil
  end

  # Expanded range from 512px to 800px.
  def in_range?(object)
    spriteRect = @character_sprites_bounds[object.id]

    test_y = object.real_y - @map.display_y
    ydim = 800
    if spriteRect.height > Graphics.height / 2
      ydim += spriteRect.height * 2
    end
    return false if test_y <= -ydim
    return false if test_y >= Graphics.height * 4 + ydim

    test_x = object.real_x - @map.display_x
    xdim = 800
    if spriteRect.width > Graphics.width / 2
      xdim += spriteRect.width * 2
    end
    return false if test_x <= -xdim
    return false if test_x >= Graphics.width * 4 + xdim

    return true
  end

  def update
    # Add new sprites
    for i in @map.events.keys
      if !@character_sprites.include?(i) && @map.events[i].graphical?
        sprite = Sprite_Character.new(@viewport1, @map.events[i])
        @character_sprites[i] = sprite
        if ReflectSpritesOn.include?($game_map.map_id)
          @reflectedSprites.push(ReflectedSprite.new(sprite, @map.events[i], @viewport1))
        end
      end
    end

    # Panorama sprite
    if @panorama_name != @map.panorama_name || @panorama_hue != @map.panorama_hue
      @panorama_name = @map.panorama_name
      @panorama_hue = @map.panorama_hue
      if @panorama.bitmap != nil
        @panorama.setPanorama(nil)
      end
      if @panorama_name != ""
        @panorama.setPanorama(@panorama_name, @panorama_hue)
      end
      Graphics.frame_reset
    end
    @panorama.ox = @map.display_x / 8
    @panorama.oy = @map.display_y / 8
    @panorama.update

    # Fog
    if @fog_name != @map.fog_name || @fog_hue != @map.fog_hue
      @fog_name = @map.fog_name
      @fog_hue = @map.fog_hue
      if @fog.bitmap != nil
        @fog.setFog(nil)
      end
      if @fog_name != ""
        @fog.setFog(@fog_name, @fog_hue)
      end
      Graphics.frame_reset
    end
    fog_zoom = @map.fog_zoom / 100.0
    @fog.zoom_x = fog_zoom
    @fog.zoom_y = fog_zoom
    @fog.opacity = @map.fog_opacity
    @fog.blend_type = @map.fog_blend_type
    @fog.ox = @map.display_x / 4 + @map.fog_ox
    @fog.oy = @map.display_y / 4 + @map.fog_oy
    @fog.tone = @map.fog_tone
    @fog.update

    # Tilemap
    tmox = @map.display_x.to_i / 4
    tmoy = @map.display_y.to_i / 4
    @tilemap.ox = tmox
    @tilemap.oy = tmoy
    @tilemap.update

    # Viewport 1
    @viewport1.rect.set(0, 0, Graphics.width, Graphics.height)
    @viewport1.ox = 0
    @viewport1.oy = 0
    @viewport1.ox += $game_screen.shakeX
    @viewport1.oy += $game_screen.shakeY

    # Character sprite update
    for sprite in @character_sprites.values
      if sprite.character.is_a?(Game_Event)
        # The if in_range?(sprite.character) here was meant to prevent lag by disabling sprite updates for events which are far away.
        # However it's not as simple, we do have cases where this simple solution is causing sprites being stuck on screen such as Reborn's KotH.
        # Base essentials has this optimization too, however it has some extra conditions which can cause an update regardless of range.
        # See Game_Event.should_update? in base essentials for details. Adopting that solution would take a lot more work since our essentials is too old.
        sprite.update # if in_range?(sprite.character)
      else
        sprite.update
      end
    end
    for sprite in @reflectedSprites
      sprite.visible = true
      sprite.visible = (@map == $game_map) if sprite.event == $game_player
      sprite.update if sprite.visible
    end
    # Avoids overlap effect of player sprites if player is near edge of
    # a connected map
    @playersprite.visible = @playersprite.visible && (
       self.map == $game_map || $game_player.x <= 0 || $game_player.y <= 0 ||
       ($game_map && ($game_player.x >= $game_map.width ||
       $game_player.y >= $game_map.height)))

    # Weather
    if self.map != $game_map
      if @weather.max > 0
        @weather.max -= 2
      elsif @weather.max < 0
        @weather.max = 0
      else
        @weather.type = 0
        @weather.ox = 0
        @weather.oy = 0
      end
    else
      @weather.type = $game_screen.weather_type
      @weather.max = $game_screen.weather_max
      @weather.ox = @map.display_x / 4
      @weather.oy = @map.display_y / 4
    end
    @weather.update

    # Other
    for sprite in @picture_sprites
      sprite.update
    end
    @timer_sprite.update
    @viewport1.tone = $game_screen.tone
    @viewport1a.ox += $game_screen.shakeX
    @viewport1a.oy += $game_screen.shakeY
    @viewport3.color = $game_screen.flash_color
    @viewport1.update
    @viewport1a.update
    @viewport1b.update
    @viewport3.update
  end
end

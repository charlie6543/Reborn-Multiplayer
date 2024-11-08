class PokemonTrainerCardScene
  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    background = pbResolveBitmap(sprintf("Graphics/Pictures/trainercardbgf"))
    if $Trainer.isFemale? && background
      addBackgroundPlane(@sprites, "bg", "trainercardbgf", @viewport)
    else
      addBackgroundPlane(@sprites, "bg", "trainercardbg", @viewport)
    end
    cardexists = pbResolveBitmap(sprintf("Graphics/Pictures/trainercardf"))
    @sprites["card"] = IconSprite.new(0, 0, @viewport)
    if $Trainer.isFemale? && cardexists
      @sprites["card"].setBitmap("Graphics/Pictures/trainercardf")
    else
      @sprites["card"].setBitmap("Graphics/Pictures/trainercard")
    end
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    if Rejuv
      @sprites["trainer"] = IconSprite.new(336, 100, @viewport)
    else
      @sprites["trainer"] = IconSprite.new(336, 112, @viewport)
    end
    @sprites["trainer"].setBitmap(pbPlayerSpriteFile($Trainer.trainertype))
    @sprites["trainer"].x -= (@sprites["trainer"].bitmap.width - 128) / 2
    @sprites["trainer"].y -= (@sprites["trainer"].bitmap.height - 148) # UPDATED
    @sprites["trainer"].z = 2
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawTrainerCardFront
    pbFadeInAndShow(@sprites) { update }
  end

  def pbDrawTrainerCardFront
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    totalsec = Graphics.time_passed / 40 + (Process.clock_gettime(Process::CLOCK_MONOTONIC) - Graphics.start_playing).to_i
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time = _ISPRINTF("{1:02d}:{2:02d}", hour, min)
    $PokemonGlobal.startTime = pbGetTimeNow if !$PokemonGlobal.startTime
    #starttime = _ISPRINTF(
    #  "{1:s} {2:d}, {3:d}",
    #  pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
    #  $PokemonGlobal.startTime.day,
    #  $PokemonGlobal.startTime.year
    #)
    pubid = sprintf("%05d", $Trainer.publicID($Trainer.id))
    baseColor = Color.new(210, 215, 220) # Updated
    shadowColor = Color.new(70, 75, 80) # Updated
    ownedCount = $game_switches[:NotPlayerCharacter] ? "???" : $Trainer.pokedex.getOwnedCount
    seenCount = $game_switches[:NotPlayerCharacter] ? "???" : $Trainer.pokedex.getSeenCount
    money = $game_switches[:NotPlayerCharacter] ? "???" : "$#{$Trainer.money}"
    textPositions = [
      [_INTL("Name"), 34, 64, 0, baseColor, shadowColor],
      [_INTL("{1}", $Trainer.name), 302, 64, 1, baseColor, shadowColor],
      [_INTL("ID No."), 332, 64, 0, baseColor, shadowColor],
      [_INTL("{1}", pubid), 468, 64, 1, baseColor, shadowColor],
      [_INTL("Money"), 34, 112, 0, baseColor, shadowColor],
      [_INTL("{1}", money), 302, 112, 1, baseColor, shadowColor],
      [_INTL("Pokédex"), 34, 160, 0, baseColor, shadowColor],
      [_INTL("{1}/{2}", ownedCount, seenCount), 302, 160, 1, baseColor, shadowColor],
      [_INTL("Time"), 34, 208, 0, baseColor, shadowColor],

      # UPDATE- Adding room for 18 badges
      [time, 302, 208, 1, baseColor, shadowColor]
      #  [_INTL("Started"),34,256,0,baseColor,shadowColor],
      # [starttime,302,256,1,baseColor,shadowColor]
    ]
    pbDrawTextPositions(overlay, textPositions)
    return if $game_switches[:NotPlayerCharacter]

    y = 262
    imagePositions = []
    if Desolation
      x = 80
      for i in 0...7
        if $Trainer.badges[i]
          imagePositions.push(["Graphics/Pictures/badges", x, y, i * 48, 0, 48, 48])
        end
        x += 50
      end
      y += 50
      x = 130
      for i in 0...5
        if $Trainer.badges[i + 7]
          imagePositions.push(["Graphics/Pictures/badges", x, y, i * 48, 48, 48, 48])
        end
        x += 50
      end
    else
      for region in 0...2 # Two rows
        x = 32
        for i in 0...9
          if $Trainer.badges[i + region * 9]
            if Rejuv && ($game_variables[:V13Story] >= 11)
              imagePositions.push(["Graphics/Pictures/badges_1", x, y, i * 48, region * 48, 48, 48])
            else
              imagePositions.push(["Graphics/Pictures/badges", x, y, i * 48, region * 48, 48, 48])
            end
          end
          x += 50
        end
        y += 50
      end
    end
    tts("Trainer Card")
    tts(sprintf("Name: %s", $Trainer.name))
    tts(sprintf("ID Number: %s", pubid))
    tts(sprintf("Money: %s", money))
    tts(sprintf("Pokédex: %s seen, %s caught", seenCount, ownedCount))
    tts(sprintf("Time: %s hours and %s minutes", hour, min))
    tts(sprintf("Badges: %d", $Trainer.numbadges))
    tts(sprintf("Level Cap: %d", [LEVELCAPS[$Trainer.numbadges], 100 + $game_variables[:Extended_Max_Level]].min))
    pbDrawImagePositions(overlay, imagePositions)
  end

  def pbTrainerCard
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::B)
        break
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class PokemonTrainerCard
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbTrainerCard
    @scene.pbEndScene
  end
end

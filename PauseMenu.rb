class PokemonMenu_Scene
  attr_accessor :sprites
  attr_accessor :viewport

  def pbShowCommands(commands)
    ret = -1
    cmdwindow = @sprites["cmdwindow"]
    cmdwindow.viewport = @viewport
    cmdwindow.index = $PokemonTemp.menuLastChoice
    cmdwindow.resizeToFit(commands)
    cmdwindow.commands = commands
    cmdwindow.x = Graphics.width - cmdwindow.width
    cmdwindow.y = 0
    cmdwindow.visible = true
    lastread = nil
    loop do
      cmdwindow.update
      if commands[cmdwindow.index] != lastread
        tts(commands[cmdwindow.index])
        lastread = commands[cmdwindow.index]
      end
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::B)
        ret = -1
        break
      end
      if Input.trigger?(Input::C)
        ret = cmdwindow.index
        $PokemonTemp.menuLastChoice = ret
        break
      end
    end
    return ret
  end

  def pbShowInfo(text)
    @sprites["infowindow"].resizeToFit(text, Graphics.height)
    @sprites["infowindow"].text = text
    @sprites["infowindow"].visible = true
    @infostate = true
  end

  def pbShowHelp(text)
    @sprites["helpwindow"].resizeToFit(text, Graphics.height)
    @sprites["helpwindow"].text = text
    @sprites["helpwindow"].visible = true
    @helpstate = true
    pbBottomLeft(@sprites["helpwindow"])
  end

  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["cmdwindow"] = Window_CommandPokemon.new([], tts: false)
    @sprites["infowindow"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    @sprites["infowindow"].visible = false
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    @sprites["helpwindow"].visible = false
    @sprites["cmdwindow"].visible = false
    @infostate = false
    @helpstate = false
    $game_temp.in_menu = true
    pbSEPlay("menu")
  end

  def pbHideMenu
    @sprites["cmdwindow"].visible = false
    @sprites["infowindow"].visible = false
    @sprites["helpwindow"].visible = false
  end

  def pbShowMenu
    pbStartScene if @sprites["cmdwindow"].disposed?
    @sprites["cmdwindow"].visible = true
    @sprites["infowindow"].visible = @infostate
    @sprites["helpwindow"].visible = @helpstate
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    $game_temp.in_menu = false
    pbSEPlay("menuclose")
    @viewport.dispose
  end

  def pbRefresh
  end
end

class PokemonMenu
  def initialize(scene)
    @scene = scene
  end

  def pbShowMenu
    @scene.pbRefresh
    @scene.pbShowMenu
  end

  def pbStartPokemonMenu
    @scene.pbStartScene
    endscene = true
    pbSetViableDexes
    commands = []
    cmdPokedex = -1
    cmdPokemon = -1
    cmdBag = -1
    cmdTrainer = -1
    cmdSave = -1
    cmdOption = -1
    cmdPokegear = -1
    cmdControls = -1
    cmdDebug = -1
    cmdQuit = -1
    cmdEndGame = -1
    cmdQuest = -1
    if !$Trainer
      if $DEBUG
        Kernel.pbMessage(_INTL("The player trainer was not defined, so the menu can't be displayed."))
        Kernel.pbMessage(_INTL("Please see the documentation to learn how to set up the trainer player."))
      end
      return
    end
    commands[cmdPokedex = commands.length] = _INTL("Pokédex") if $Trainer.pokedex.canViewDex # && $PokemonGlobal.pokedexViable.length>0
    commands[cmdPokemon = commands.length] = _INTL("Pokémon") if $Trainer.party.length > 0
    commands[cmdBag = commands.length] = _INTL("Bag")
    if Rejuv
      commands[cmdPokegear = commands.length] = "CyberNav" if $Trainer.pokegear
      commands[cmdQuest = commands.length] = _INTL("Quests") # if hasAnyQuests?
    else
      commands[cmdPokegear = commands.length] = "Pokégear" if $Trainer.pokegear
    end
    commands[cmdTrainer = commands.length] = $Trainer.name if $Trainer.badges
    if pbInSafari?
      if SAFARISTEPS <= 0
        @scene.pbShowInfo(_INTL("Balls: {1}", pbSafariState.ballcount))
      else
        @scene.pbShowInfo(_INTL("Steps: {1}/{2}\nBalls: {3}", pbSafariState.steps, SAFARISTEPS, pbSafariState.ballcount))
      end
      commands[cmdQuit = commands.length] = _INTL("Quit")
    else
      commands[cmdSave = commands.length] = _INTL("Save") if !$game_system || !$game_system.save_disabled
    end
    commands[cmdOption = commands.length] = _INTL("Options")
    commands[cmdControls = commands.length] = _INTL("Controls")
    commands[cmdDebug = commands.length] = _INTL("Debug") if $DEBUG || (Reborn && $game_switches[:MiniDebug_Pass])
    commands[cmdEndGame = commands.length] = _INTL("Quit Game")
    $game_screen.getTimeCurrent(true)
    loop do
      command = @scene.pbShowCommands(commands)
      if cmdPokedex >= 0 && command == cmdPokedex
        # if DEXDEPENDSONLOCATION
        #  pbFadeOutIn(99999) {
        #     scene=PokemonPokedexScene.new
        #     screen=PokemonPokedex.new(scene)
        #     screen.pbStartScreen
        #     @scene.pbRefresh
        #  }
        # else
        #  if $PokemonGlobal.pokedexViable.length==1
        #    $PokemonGlobal.pokedexDex=$PokemonGlobal.pokedexViable[0]
        #    $PokemonGlobal.pokedexDex=-1 if $PokemonGlobal.pokedexDex==$PokemonGlobal.pokedexUnlocked.length-1
        pbFadeOutIn(99999) {
          scene = PokemonPokedexScene.new
          screen = PokemonPokedex.new(scene)
          screen.pbStartScreen
          @scene.pbRefresh
        }
        #  else
        #    pbLoadRpgxpScene(Scene_PokedexMenu.new)
        #  end
        # end
      elsif cmdPokegear >= 0 && command == cmdPokegear
        if Desolation
          Graphics.freeze
          @scene.pbFadeOutAndHide(@scene.sprites)
        end
        pbLoadRpgxpScene(Scene_Pokegear.new)
        if Desolation && $shouldCloseMenu
          @scene.pbFadeOutAndHide(@scene.sprites)
          $shouldCloseMenu = false
          @scene.pbDisposeSpriteHash(@scene.sprites)
          $game_temp.in_menu = false
          @scene.viewport.dispose
          Graphics.update
          pbToneChangeAll(Tone.new(0, 0, 0), 8)
          endscene = false
          break
        end
        Graphics.update
      elsif cmdPokemon >= 0 && command == cmdPokemon
        sscene = PokemonScreen_Scene.new
        sscreen = PokemonScreen.new(sscene, $Trainer.party)
        hiddenmove = nil
        pbFadeOutIn(99999) {
          hiddenmove = sscreen.pbPokemonScreen
          if hiddenmove
            @scene.pbEndScene
          else
            @scene.pbRefresh
          end
        }
        if hiddenmove
          Kernel.pbUseHiddenMove(hiddenmove[0], hiddenmove[1])
          return
        end
      elsif cmdBag >= 0 && command == cmdBag
        item = nil
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene, $PokemonBag)
        pbFadeOutIn(99999) {
          item = screen.pbStartScreen
          if item
            @scene.pbEndScene
          else
            @scene.pbRefresh
          end
        }
        if item
          Kernel.pbUseKeyItemInField(item)
          return
        end
      elsif cmdTrainer >= 0 && command == cmdTrainer
        PBDebug.logonerr {
          scene = PokemonTrainerCardScene.new
          screen = PokemonTrainerCard.new(scene)
          pbFadeOutIn(99999) {
            screen.pbStartScreen
            @scene.pbRefresh
          }
        }
      elsif cmdQuest >= 0 && command == cmdQuest
        pbPlayDecisionSE
        pbFadeOutIn(99999) {
          pbViewQuests
          @scene.pbRefresh
        }
      elsif cmdQuit >= 0 && command == cmdQuit
        @scene.pbHideMenu
        if pbInSafari?
          if Kernel.pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
            @scene.pbEndScene
            pbSafariState.decision = 1
            pbSafariState.pbGoToStart
            return
          else
            pbShowMenu
          end
        end
      elsif cmdSave >= 0 && command == cmdSave
        @scene.pbHideMenu
        scene = PokemonSaveScene.new
        screen = PokemonSave.new(scene)
        if screen.pbSaveScreen
          @scene.pbEndScene
          endscene = false
          break
        else
          pbShowMenu
        end
      elsif cmdDebug >= 0 && command == cmdDebug
        pbFadeOutIn(99999) {
          pbDebugMenu
          @scene.pbRefresh
        }
      elsif cmdControls >= 0 && command == cmdControls
        controlsDialogue
      elsif cmdOption >= 0 && command == cmdOption
        if Reborn && $game_switches[:Blindstep]
          optionCommands = []
          optionCommands.push(_INTL("General"))
          optionCommands.push(_INTL("Accessibility"))
          option = Kernel.pbMessage(_INTL("What options do you want to see?"), optionCommands, -1)
        end

        unless option == -1
          scene = option == 1 ? PokemonBlindstepOptionScene.new : PokemonOptionScene.new
          screen = PokemonOption.new(scene)
          pbFadeOutIn(99999) {
            screen.pbStartScreen
            pbUpdateSceneMap
            @scene.pbRefresh
          }
          $updateFLHUD = true
        end
      elsif cmdEndGame >= 0 && command == cmdEndGame
        @scene.pbHideMenu
        if Kernel.pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
          scene = PokemonSaveScene.new
          screen = PokemonSave.new(scene)
          if screen.pbSaveScreen
            @scene.pbEndScene
          end
          @scene.pbEndScene
          $scene = nil
          exit
        else
          pbShowMenu
        end
      else
        break
      end
    end
    @scene.pbEndScene if endscene
  end
end

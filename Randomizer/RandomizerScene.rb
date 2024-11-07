module Graphics
  def self.width=(value)
    @@width = value
  end

  def self.height=(value)
    @@height = value
  end
end

# RandomizerSettings.new
class RandomizerScene
  attr_accessor :settings
  attr_accessor :mainwin
  attr_accessor :pages
  attr_accessor :breakflag


  PAGENAMES = {
    :species => 0,
    :moves => 1,
    :abilities => 2,
    :types => 3,
    :items => 4,
    :other => 5,
    :folder => 6
  }

  def initialize(settings = RandomizerSettings.new)
    # Start by resizing the screen properly so it fits
    oldborder = $Settings.border
    $Settings.border = 0
    setScreenBorder
    $ResizeBorder.dispose
    resizeSpritesAndViewports
    Graphics.width = 800
    Graphics.height = 512
    Graphics.resize_screen(Graphics.width, Graphics.height)
    GC.start

    # Setting attributes
    @settings = settings
    # puts @settings.to_s
    # print 1
    @breakflag = false
    @confirmflag = false
    @settingsChanged = false
    @otherfileflag = false
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999

    # Right hand menu
    sidewinlength = 240
    sidewin = ControlWindow.new(0, 0, sidewinlength, Graphics.height)
    sidewin.addButton(_INTL("Species Traits"))
    sidewin.addButton(_INTL("Evolutions"))
    sidewin.addButton(_INTL("Moves & Movesets"))
    sidewin.addButton(_INTL("Encounters"))
    sidewin.addButton(_INTL("Trainers"))
    sidewin.addButton(_INTL("TMs & Tutors"))
    sidewin.addButton(_INTL("Items"))
    sidewin.addButton(_INTL("Types"))
    sidewin.addButton(_INTL("Misc Settings"))
    3.times do
      sidewin.addSpace
    end
    if Dir.exist?("Randomizer Data") && File.exist?("Randomizer Data/settings.txt")
      sidewin.addButton(_INTL("Use Existing Data"))
    else
      sidewin.addSpace
    end
    sidewin.addButton(_INTL("Cancel"))
    sidewin.addButton(_INTL("Done"))
    sidewin.viewport = viewport
    # create the 5 main windows
    # have a function that sets @mainwin to a specific ControlWindow
    @pages = makePages(viewport, sidewinlength)
    @mainwin = @pages[0]
    @mainwin.visible = true
    finished = nil
    loop do
      Graphics.update
      Input.update
      sidewinLoop(sidewin)
      mainwinloop()
      if @otherfileflag
        $game_switches[:Randomized_Challenge] = true
        str = ""
        File.open("Randomizer Data/settings.txt", "r") { |f| str = f.read() }
        @settings.load(str)
        $Randomizer = Randomizer.new(@settings)
        finished = true
        break
      end
      if Input.trigger?(Input::B) || @breakflag
        @breakflag = false
        if Kernel.pbConfirmMessageSerious(_INTL("Are you sure you want to exit without randomizing?"))
          finished = false
          break
        end
      end
      if @confirmflag
        @confirmflag = false
        @settingsChanged = true
        if !@settingsChanged
          if Kernel.pbConfirmMessageSerious(_INTL("Are you sure you want to exit without randomizing?"))
            finished = true
            break
          end
        else
          # Dir.mkdir("Randomizer Data") unless Dir.exist?("Randomizer Data")
          if Dir.exist?("Randomizer Data")
            if Kernel.pbConfirmMessageSerious("Are you sure you wish to overwrite the data in \\\\Randomizer Data\\\\\\c[0]?\nThe data will be lost forever \\r(a long time!) \\c[0]and may \\raffect other saves!")
              Dir.each_child("Randomizer Data") { |file| File.delete("Randomizer Data/#{file}") }
              @settings.initRandom(@seedField.text.javaHash) if @seedField.text != ""
              $Randomizer = Randomizer.new(@settings)
              $game_switches[:Randomized_Challenge] = true
              finished = true
              break
            end
          else
            @settings.initRandom(@seedField.text.javaHash) if @seedField.text != ""
            $Randomizer = Randomizer.new(@settings)
            $game_switches[:Randomized_Challenge] = true
            finished = true
            break
          end
        end
      end
    end
    sidewin.dispose
    @pages.each { |win| win.dispose }
    viewport.dispose

    # Return screen to normal size
    $Settings.border = oldborder
    setScreenBorder
    setScreenBorderName("border")
    resizeSpritesAndViewports
    Graphics.resize_screen(DEFAULTSCREENWIDTH + 2 * $ResizeOffsetX, DEFAULTSCREENHEIGHT + 2 * $ResizeOffsetY)
    Graphics.width = DEFAULTSCREENWIDTH
    Graphics.height = DEFAULTSCREENHEIGHT
    GC.start
    return finished
  end

  def sidewinLoop(sidewin)
    sidewin.update

    # Going to a specific menu option
    for i in 0..@pages.length
      pbUpdateSidebar(i) if sidewin.changed?(i)
    end
    if sidewin.changed?(12)
      @otherfileflag = true
    end
    # Returning
    @confirmflag = true       if sidewin.changed?(14)
    @breakflag = true         if sidewin.changed?(13)
  end

  def mainwinloop
    @mainwin.update
    for i in 0...@mainwin.controls.length
      option = @mainwin.controls[i]
      if @mainwin.changed?(i)
        option.setvalue unless option.is_a?(TextBox)
        @settingsChanged = true
      end
    end
  end

  def makePages(viewport, sidewinlength)
    # Making Move page
    movepage = ControlWindow.new(240, 0, 800 - sidewinlength, 512)
    movepage.visible = false
    movepage.viewport = viewport
    movepage.addLabel("Move Data:")
    movepage.addCheckbox("Have Move Typings randomize", proc { |value| @settings.moves[:type] = value })
    movepage.addCheckbox("Have Move Base Powers randomize", proc { |value| @settings.moves[:power] = value })
    movepage.addCheckbox("Have Move Accuracy randomize", proc { |value| @settings.moves[:accuracy] = value })
    movepage.addCheckbox("Have Move Category randomize", proc { |value| @settings.moves[:category] = value })
    movepage.addLabel("Movesets:")
    movepage.addTextSlider(
      "", ["Unchanged", "Random", "Prefer Type", "Metronome"], 0,
      proc { |value|
        case value
          when 0
            @settings.pkmn[:movesets][:random]     = false
            @settings.pkmn[:movesets][:preferType] = false
            @settings.pkmn[:movesets][:metronome]  = false
          when 1
            @settings.pkmn[:movesets][:random]     = true
            @settings.pkmn[:movesets][:preferType] = false
            @settings.pkmn[:movesets][:metronome]  = false
          when 2
            @settings.pkmn[:movesets][:random]     = true
            @settings.pkmn[:movesets][:preferType] = true
            @settings.pkmn[:movesets][:metronome]  = false
          when 3
            @settings.pkmn[:movesets][:random]     = true
            @settings.pkmn[:movesets][:preferType] = false
            @settings.pkmn[:movesets][:metronome]  = true
        end
      }
    )
    movepage.addTextSlider(
      "Force Good Move %", ["0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100"], 0,
      proc { |value| @settings.pkmn[:movesets][:forceGoodMoves] = value * 10 }
    )
    movepage.addCheckbox("Scale Moves with Level", proc { |value| @settings.pkmn[:movesets][:scaleMoves] = value })
    movepage.addCheckbox("Ban Set Damage Moves", proc { |value| @settings.pkmn[:movesets][:banSetDamage] = value })
    movepage.addControl(Checkbox.new("Learn Moves on Evolutions?", proc { |value| @settings.pkmn[:movesets][:newEvoMove] = value })) # ,x:248,y:8)

    # Making Species page
    specpage = ControlWindow.new(240, 0, 800 - sidewinlength, 512)
    specpage.visible = false
    specpage.viewport = viewport
    specpage.addLabel("Base Stats:")
    specpage.addTextSlider(
      "", ["Unchanged", "Random", "Shuffle", "Flipped!"], 0,
      proc { |value|
        case value
          when 0
            @settings.pkmn[:stats][:random]  = false
            @settings.pkmn[:stats][:shuffle] = false
            @settings.pkmn[:stats][:flipped] = false
          when 1
            @settings.pkmn[:stats][:random]  = true
            @settings.pkmn[:stats][:shuffle] = false
            @settings.pkmn[:stats][:flipped] = false
          when 2
            @settings.pkmn[:stats][:random]  = false
            @settings.pkmn[:stats][:shuffle] = true
            @settings.pkmn[:stats][:flipped] = false
          when 3
            @settings.pkmn[:stats][:random]  = false
            @settings.pkmn[:stats][:shuffle] = false
            @settings.pkmn[:stats][:flipped] = true
        end
      }
    )
    specpage.addCheckbox("Follow Evolutions", proc { |value| @settings.pkmn[:stats][:followEvolutions] = value })
    specpage.addLabel("Abilities:")
    specpage.addCheckbox("Randomize Abilities", proc { |value| @settings.pkmn[:abilities][:random] = value })
    specpage.addCheckbox("Follow Evolutions", proc { |value| @settings.pkmn[:abilities][:followEvolutions] = value })
    specpage.addControl(Checkbox.new("Allow Wonder Guard?", proc { |value| @settings.pkmn[:abilities][:allowWonderGuard] = value })) # ,x:288,y:4)
    specpage.addControl(Checkbox.new("Ban Trapping Abilities", proc { |value| @settings.pkmn[:abilities][:banTrappingAbilities] = value })) # ,x:288,y:5)
    specpage.addLabel("Types:") # ,y:6)
    specpage.addCheckbox("Randomize Typings", proc { |value| @settings.pkmn[:types][:random] = value }) # ,y:7)
    specpage.addCheckbox("Follow Evolutions", proc { |value| @settings.pkmn[:types][:followEvolutions] = value }) # ,y:8)
    typeChanceArr = Array.new(11) { |i| (i * 10).to_s + "%" }
    specpage.addTextSlider("Dual Type Chance:", typeChanceArr, 5, proc { |value| @settings.pkmn[:types][:dualType] = value * 10 }) # ,y:9)

    # Making Evo page
    evopage = ControlWindow.new(240, 0, 800 - sidewinlength, 512)
    evopage.visible = false
    evopage.viewport = viewport
    evopage.addLabel("Evolution Options:")
    evopage.addCheckbox("Randomize Evolutions", proc { |value| @settings.pkmn[:evolutions][:random] = value })
    evopage.addCheckbox("Force Different?", proc { |value| @settings.pkmn[:evolutions][:forceNewEvos] = value })
    evopage.addCheckbox("Limit Evolutions?", proc { |value| @settings.pkmn[:evolutions][:limitEvos] = value })
    evopage.addCheckbox("Same Typing?", proc { |value| @settings.pkmn[:evolutions][:forceTyping] = value })
    evopage.addCheckbox("Similar Strength?", proc { |value| @settings.pkmn[:evolutions][:similarTarget] = value })

    # Making Type page
    typepage = ControlWindow.new(240, 0, 800 - sidewinlength, 512)
    typepage.visible = false
    typepage.viewport = viewport
    typepage.addLabel("Type Options:")
    typepage.addCheckbox("Allow ??? Type?", proc { |value| @settings.types[:allowQmarks?] = value })
    typepage.addCheckbox("Allow Shadow Type?", proc { |value| @settings.types[:allowShadow?] = value })
    # typepage.addCheckbox("Have Type Effectiveness Chart randomize",proc {|value| @settings.typeeff = value})
    # typepage.addTextSlider(" Set Type Chart generation             ",
    #  randGenText, 0, proc {|value| @settings.typeeffgen = randGenHash[value]})
    # typepage.addLabel("Shuffle - Values are changed around maintaing the original")
    # typepage.addLabel("amount of values.")
    # typepage.addLabel("Distributed - Values are changed based on the ratios of")
    # typepage.addLabel("original values.")
    # typepage.addLabel("Chaos - Values are randomly generated with no regard to the")
    # typepage.addLabel("original values.")

    # Making Items page
    itempage = ControlWindow.new(240, 0, 800 - sidewinlength, 512)
    itempage.visible = false
    itempage.viewport = viewport
    itempage.addLabel("Item Options:")
    itempage.addCheckbox("Have field items randomize", proc { |value| @settings.items[:field][:random] = value })
    itempage.addCheckbox("Have random field items match pockets", proc { |value| @settings.items[:field][:typeMatch] = value })
    itempage.addCheckbox("Have PokeMarts randomize", proc { |value| @settings.items[:mart][:random] = value })
    itempage.addCheckbox("Have random PokeMarts match pockets", proc { |value| @settings.items[:mart][:typeMatch] = value })

    pokepage = ControlWindow.new(240, 0, 800 - sidewinlength, 512)
    pokepage.visible = false
    pokepage.viewport = viewport
    pokepage.addLabel("Encounter Options:")
    pokepage.addTextSlider(
      "", ["Unchanged", "Random", "Area", "Global"], 0,
      proc { |value|
        case value
          when 0
            @settings.encounters[:random] = false
            @settings.encounters[:areamap] = false
            @settings.encounters[:globalmap] = false
          when 1
            @settings.encounters[:random] = true
            @settings.encounters[:areamap] = false
            @settings.encounters[:globalmap] = false
          when 2
            @settings.encounters[:random] = false
            @settings.encounters[:areamap] = true
            @settings.encounters[:globalmap] = false
          when 3
            @settings.encounters[:random] = false
            @settings.encounters[:areamap] = false
            @settings.encounters[:globalmap] = true
        end
      }
    )
    pokepage.addCheckbox("Similar Strength?", proc { |value| @settings.encounters[:similarBST] = value })
    pokepage.addCheckbox("Match Types?", proc { |value| @settings.encounters[:typeThemed] = value })
    pokepage.addCheckbox("Disable Legendaries?", proc { |value| @settings.encounters[:disableLegends] = value })
    pokepage.addCheckbox("Have starters randomize", proc { |value| @settings.statics[:starters][:random] = value })
    pokepage.addCheckbox("Force starters to have 2 evolutions", proc { |value| @settings.statics[:starters][:forceThreeStage] = value })
    pokepage.addCheckbox("Have static Pokemon randomize", proc { |value| @settings.statics[:statics][:random] = value })

    trainerpage = ControlWindow.new(240, 0, 800 - sidewinlength, 512)
    trainerpage.visible = false
    trainerpage.viewport = viewport
    trainerpage.addLabel("Trainer Options:")
    trainerpage.addCheckbox("Have all trainers randomize", proc { |value| @settings.trainers[:random] = value })
    trainerpage.addCheckbox("Randomize trainer classes", proc { |value| @settings.trainers[:class] = value })
    trainerpage.addCheckbox("Randomize trainer names", proc { |value| @settings.trainers[:name] = value })
    trainerpage.addCheckbox("Fill trainer parties", proc { |value| @settings.trainers[:fillParties] = value })

    trainerpage.addCheckbox("Keep rivals' starters?", proc { |value| @settings.trainers[:keepStarters] = value })
    trainerpage.addCheckbox("Ensure Mega Evolutions?", proc { |value| @settings.trainers[:ensureMega] = value })
    trainerpage.addCheckbox("Ensure ZMoves?", proc { |value| @settings.trainers[:ensureZMove] = value })
    trainerpage.addCheckbox("Ensure Type Themes?", proc { |value| @settings.trainers[:forceTypeTheme] = value })

    trainerpage.addCheckbox("Smart Randomization", proc { |value| @settings.trainers[:smartGeneration] = value })
    trainerpage.addCheckbox("Similar Strength?", proc { |value| @settings.trainers[:similarBST] = value })
    trainerpage.addCheckbox("Force Full Evolutions", proc { |value| @settings.trainers[:forceFullEvo] = value })
    trainerpage.addLabel("Evolution Level:")
    trainerpage.addSlider("", 0, 120, 30, proc { |value| @settings.trainers[:forceFullEvoLevel] = value })

    tmpage = ControlWindow.new(240, 0, 800 - sidewinlength, 512)
    tmpage.visible = false
    tmpage.viewport = viewport
    tmpage.addLabel("TM and Tutor Options:")
    tmpage.addCheckbox("Have TMs randomize", proc { |value| @settings.tms[:random] = value })
    tmpage.addLabel("TM Compatibility:")
    tmpage.addTextSlider(
      "", ["Unchanged", "Random", "Type", "Full"], 0,
      proc { |value|
        case value
          when 0
            @settings.tms[:randomCompatibility] = false
            @settings.tms[:typeCompatibility]   = false
            @settings.tms[:fullCompatibility]   = false
          when 1
            @settings.tms[:randomCompatibility] = true
            @settings.tms[:typeCompatibility]   = false
            @settings.tms[:fullCompatibility]   = false
          when 2
            @settings.tms[:randomCompatibility] = false
            @settings.tms[:typeCompatibility]   = true
            @settings.tms[:fullCompatibility]   = false
          when 3
            @settings.tms[:randomCompatibility] = false
            @settings.tms[:typeCompatibility]   = false
            @settings.tms[:fullCompatibility]   = true
        end
      }
    )
    tmpage.addTextSlider(
      "Force Good Move %", ["0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100"], 0,
      proc { |value| @settings.tms[:forceGoodMoves] = value * 10 }
    )
    tmpage.addCheckbox("Have tutors randomize", proc { |value| @settings.tutors[:random] = value })
    tmpage.addLabel("Tutor Compatibility:")
    tmpage.addTextSlider(
      "", ["Unchanged", "Random", "Type", "Full"], 0,
      proc { |value|
        case value
          when 0
            @settings.tutors[:randomCompatibility] = false
            @settings.tutors[:typeCompatibility]   = false
            @settings.tutors[:fullCompatibility]   = false
          when 1
            @settings.tutors[:randomCompatibility] = true
            @settings.tutors[:typeCompatibility]   = false
            @settings.tutors[:fullCompatibility]   = false
          when 2
            @settings.tutors[:randomCompatibility] = false
            @settings.tutors[:typeCompatibility]   = true
            @settings.tutors[:fullCompatibility]   = false
          when 3
            @settings.tutors[:randomCompatibility] = false
            @settings.tutors[:typeCompatibility]   = false
            @settings.tutors[:fullCompatibility]   = true
        end
      }
    )
    tmpage.addTextSlider(
      "Force Good Move %", ["0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100"], 0,
      proc { |value| @settings.tutors[:forceGoodMoves] = value * 10 }
    )

    miscpage = ControlWindow.new(240, 0, 800 - sidewinlength, 512)
    miscpage.visible = false
    miscpage.viewport = viewport
    miscpage.addLabel("Miscellaneous Options:")
    miscpage.addCheckbox("Allow Mega Pokemon to generate?", proc { |value| @settings.misc[:allowMegas] = value })
    miscpage.addCheckbox("Allow Trainer Exclusive Pokemon to generate?", proc { |value| @settings.misc[:allowForms] = value })
    @seedField = TextBox.new("Enter a custom seed:", "")
    miscpage.addControl(@seedField) unless $joiplay

    return [specpage, evopage, movepage, pokepage, trainerpage, tmpage, itempage, typepage, miscpage]
  end
  # RandomizerSettings.new


  def pbUpdateSidebar(page)
    return if @mainwin == @pages[page]
    Input.text_input = false
    # set the old window to invisible, vhange it and set the new one to visible
    @mainwin.visible = false
    @mainwin = @pages[page]
    @mainwin.visible = true
  end
end

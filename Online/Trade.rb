################################################################################
#-------------------------------------------------------------------------------
# Author: Alexandre
# Simple trade system.
#-------------------------------------------------------------------------------
################################################################################
class Scene_Trade
  ################################################################################
  #-------------------------------------------------------------------------------
  # Author: Alexandre
  # Lets initialise the scene:
  # @list is the main trade background
  # @info is the background that appears when confirming the trade
  #-------------------------------------------------------------------------------
  ################################################################################
  def initialize(user)
    @username = user
    @partysent = false
    @pokemonselected = false
    @theirparty = nil
    @theirchosen = nil
    @theirindex = -1
    @index = 1
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @overlay = SpriteWrapper.new(@viewport)
    @overlay.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @overlay.z = 1000005
    @overlay2 = SpriteWrapper.new(@viewport)
    @overlay2.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @overlay2.z = 1000009
    @overlay3 = SpriteWrapper.new(@viewport)
    @overlay3.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @overlay3.z = 1000009
    @list = SpriteWrapper.new(@viewport)
    @list.visible = true
    @list.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/tradebackground.png")
    @list.z = 1000004
    @selector = SpriteWrapper.new(@viewport)
    @selector.visible = true
    @selector.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/Storage/boxpoint1.png")
    @selector.z = 1000006
    @waiting = Window_AdvancedTextPokemon.new("Waiting...")
    @waiting.visible = false
    @waiting.width = 120
    @waiting.x = Graphics.width / 2 - 50
    @waiting.y = 160
    @sprite = []
    @spritehidden = []
    @spritex = []
    @spritexhidden = []
    @sprites = {}
    @info = SpriteWrapper.new(@viewport)
    @info.visible = true
    @info.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/tradebottom.png")
    @info.z = 1000008
    @info.visible = false
    @accepted = false
    @received = false
    @listreceived = false
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Main procedure of the Scene, contains the loop that keeps it alive. When B is
  # pressed, the Trade dead message is sent to the server and the scene is disposed
  #-------------------------------------------------------------------------------
  ################################################################################
  def main
    for pokemon in $Trainer.party
      if pokemon.ot == ""
        pokemon.ot = $Trainer.name
        pokemon.trainerID = $Trainer.id
      end
    end
    mylist
    Graphics.transition
    lastread = nil
    loop do
      Graphics.update
      Input.update
      update
      if lastread != @index
        # player pokemon
        if @index >= 1 && @index <= 6 && $Trainer.party[@index - 1] != nil
          tts(getMonName($Trainer.party[@index - 1].species, $Trainer.party[@index - 1].form))
        elsif @index >= 7 && @theirparty && @theirparty[@index - 7] != nil # opponent pokemon
          tts(@username + "'s" + getMonName(@theirparty[@index - 7].species, @theirparty[@index - 7].form))
        end
        lastread = @index
      end
      if $scene != self
        break
      end

      if Input.trigger?(Input::B)
        $network.send("<TRA dead>")
        endtrade
      end
    end
    Graphics.freeze
    @waiting.dispose
    @viewport.dispose
    @list.dispose
    @overlay.dispose
    @overlay2.dispose
    @overlay3.dispose
    @sprite[0].dispose if @sprite[0] != nil
    @sprite[1].dispose if @sprite[1] != nil
    @sprite[2].dispose if @sprite[2] != nil
    @sprite[3].dispose if @sprite[3] != nil
    @sprite[4].dispose if @sprite[4] != nil
    @sprite[5].dispose if @sprite[5] != nil
    @spritex[0].dispose if @spritex[0] != nil
    @spritex[1].dispose if @spritex[1] != nil
    @spritex[2].dispose if @spritex[2] != nil
    @spritex[3].dispose if @spritex[3] != nil
    @spritex[4].dispose if @spritex[4] != nil
    @spritex[5].dispose if @spritex[5] != nil
    @sprites["mypokemon"].dispose if @sprites["mypokemon"] != nil
    @sprites["theirpokemon"].dispose if @sprites["theirpokemon"] != nil
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Just a procedure to update the scene and check for any incoming messages
  #-------------------------------------------------------------------------------
  ################################################################################
  def update
    if !$network.loggedin
      Kernel.pbMessage("Disconnected from the server.")
      endtrade
    end
    their_info if @received && @pokemonselected
    their_list if @listreceived
    message = $network.listen
    handle(message)
    for i in 0...6
      @sprite[i].update if @sprite[i] != nil
      @spritehidden[i].update if @sprite[i] != nil
      @spritex[i].update if @spritex[i] != nil
      @spritexhidden[i].update if @spritex[i] != nil
    end
    @viewport.update
    @overlay.update
    @overlay2.update
    @overlay3.update
    @selector.update
    check_input
    if !@pokemonselected && @theirparty != nil
      update_selector_input
      update_selector
    end
    @waiting.update
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Listens to incoming messages and determines what to do when trade messages are
  # received.
  #-------------------------------------------------------------------------------
  ################################################################################
  def handle(message)
    case message
      when /<TRA party=(.*)>/ # $Trainer.party dump
        theirparty($1) if @theirparty == nil
      when /<TRA offer=(.*) index=(.*)>/ # Trainer.party[@index - 1] dump
        receiveoffer($1, $2.to_i) if @theirchosen == nil
      when /<TRA accepted>/
        execute_trade if @accepted
      when /<TRA declined>/ then trade_declined
      when /<TRA dead>/
        Kernel.pbMessage("The user exited the trade.")
        endtrade
      when /<TRA diffgame>/
        Kernel.pbMessage("The trade partner is using a different game.")
        endtrade
      when /<TRA diffver>/
        Kernel.pbMessage("The trade partner is using a different version of the game.")
        endtrade
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Checks for input from C to select a pokemon or show the summary.
  #-------------------------------------------------------------------------------
  ################################################################################
  def check_input
    return if !Input.trigger?(Input::C) || @pokemonselected

    # Player's pokemon
    if @index >= 1 && @index <= 6
      commands = [_INTL("Offer"), _INTL("Summary"), _INTL("Cancel")]
      choice = Kernel.pbMessage(_INTL("What do you want to do?"), commands) unless $Trainer.party[@index - 1] == nil

      # Select pokemon for trade
      if choice == 0 && (!pbIsGoodItem($Trainer.party[@index - 1].item) || Kernel.pbConfirmMessageSerious(_INTL("Are you sure you want to trade away your {1}?", getItemName(($Trainer.party[@index - 1].item)))))
        serialized = [Marshal.dump($Trainer.party[@index - 1])].pack("m").delete("\n")
        $network.send("<TRA offer=" + serialized + " index=#{@index - 1}>")
        show_information
        @waiting.visible = true
        @pokemonselected = true

      # See summary of pokemon
      elsif choice == 1
        scene = PokemonSummaryScene.new
        screen = PokemonSummary.new(scene)
        screen.pbStartScreen($Trainer.party, @index - 1)
      elsif choice == 2
        # do nothing
      end
    else
      # Other user's pokemon
      commands = [_INTL("Summary"), _INTL("Cancel")]
      choice = Kernel.pbMessage(_INTL("What do you want to do?"), commands) unless @theirparty[@index - 7] == nil
      if choice == 0
        scene = PokemonSummaryScene.new
        screen = PokemonSummary.new(scene)
        screen.pbStartScreen(@theirparty, @index - 7)
      elsif choice == 1
        # do nothing
      end
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Checks for left and right input to move selector.
  #-------------------------------------------------------------------------------
  ################################################################################
  def update_selector_input
    if Input.trigger?(Input::RIGHT)
      case @index
        when 1, 3, 5, 7, 9, 11
          @index += 1
        when 2, 4, 6
          @index += 5
        when 8, 10, 12
          @index -= 7
      end
    end
    if Input.trigger?(Input::DOWN)
      case @index
        when 1, 2, 3, 4, 7, 8, 9, 10
          @index += 2
        when 5, 6, 11, 12
          @index -= 4
      end
    end
    if Input.trigger?(Input::LEFT)
      case @index
        when 2, 4, 6, 8, 10, 12
          @index -= 1
        when 1, 3, 5
          @index += 7
        when 7, 9, 11
          @index -= 5
      end
    end
    if Input.trigger?(Input::UP)
      case @index
        when 3, 4, 5, 6, 9, 10, 11, 12
          @index -= 2
        when 1, 2, 7, 8
          @index += 4
      end
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Updates the position of the selector.
  #-------------------------------------------------------------------------------
  ################################################################################
  def update_selector
    case @index
      when 1 then @selector.x = 54; @selector.y = 31
      when 2 then @selector.x = 149; @selector.y = 31
      when 3 then @selector.x = 54; @selector.y = 127
      when 4 then @selector.x = 149; @selector.y = 127
      when 5 then @selector.x = 54; @selector.y = 223
      when 6 then @selector.x = 149; @selector.y = 223
      when 7 then @selector.x = 307; @selector.y = 31
      when 8 then @selector.x = 406; @selector.y = 31
      when 9 then @selector.x = 307; @selector.y = 127
      when 10 then @selector.x = 406; @selector.y = 127
      when 11 then @selector.x = 307; @selector.y = 223
      when 12 then @selector.x = 406; @selector.y = 223
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Receives the other user's party.
  #-------------------------------------------------------------------------------
  ################################################################################
  def theirparty(data)
    @theirparty = Marshal.load(data.unpack("m")[0]) # load serialised party data
    if !isLegalParty?(@theirparty)
      Kernel.pbMessage(_INTL("Illegal Pokémon have been detected in #{@username}'s party. The trade will now exit."))
      $network.send("<TRA dead>")
      endtrade
    end
    @listreceived = true
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Display the other user's party.
  #-------------------------------------------------------------------------------
  ################################################################################
  def their_list
    @listreceived = false
    for i in 0..@theirparty.length - 1
      @spritex[i] =
        PokemonTradeIcon.new(@theirparty[i], @theirparty[i].eggsteps, @theirparty[i].personalID, false, @viewport)
      @spritexhidden[i] =
        PokemonTradeIcon.new(@theirparty[i], @theirparty[i].eggsteps, @theirparty[i].personalID, false, @viewport)
      @spritexhidden[i].visible = false if @spritexhidden[i] != nil
      @spritexhidden[i].x = 444 if @spritexhidden[i] != nil
      @spritexhidden[i].y = 87 if @spritexhidden[i] != nil
      @spritexhidden[i].z = 1000009 if @spritexhidden[i] != nil
    end
    @spritex[0].x = 302 if @spritex[0] != nil
    @spritex[0].y = 71 if @spritex[0] != nil
    @spritex[1].x = 401 if @spritex[1] != nil
    @spritex[1].y = 71 if @spritex[1] != nil
    @spritex[2].x = 302 if @spritex[2] != nil
    @spritex[2].y = 167 if @spritex[2] != nil
    @spritex[3].x = 401 if @spritex[3] != nil
    @spritex[3].y = 167 if @spritex[3] != nil
    @spritex[4].x = 302 if @spritex[4] != nil
    @spritex[4].y = 263 if @spritex[4] != nil
    @spritex[5].x = 401 if @spritex[5] != nil
    @spritex[5].y = 263 if @spritex[5] != nil
    @spritex[0].z = 1000005 if @spritex[0] != nil
    @spritex[1].z = 1000005 if @spritex[1] != nil
    @spritex[2].z = 1000005 if @spritex[2] != nil
    @spritex[3].z = 1000005 if @spritex[3] != nil
    @spritex[4].z = 1000005 if @spritex[4] != nil
    @spritex[5].z = 1000005 if @spritex[5] != nil
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Show's information about your chosen pokemon.
  #-------------------------------------------------------------------------------
  ################################################################################
  def show_information
    @waiting.visible = false
    @info.visible = true
    pkmn = $Trainer.party[@index - 1]
    itemname = pkmn.item.nil? ? _INTL("NO ITEM") : getItemName(pkmn.item)
    @overlay2.bitmap.clear
    @yourtype1bitmap = pbPokemonTypeBitmap(pkmn.type1)
    @yourtype2bitmap = pbPokemonTypeBitmap(pkmn.type2) if pkmn.type2
    @spritehidden[@index - 1].visible = true
    @chosenpokemon = false
    move0 = pkmn.moves[0] ? getMoveName(pkmn.moves[0].move) : "--"
    move1 = pkmn.moves[1] ? getMoveName(pkmn.moves[1].move) : "--"
    move2 = pkmn.moves[2] ? getMoveName(pkmn.moves[2].move) : "--"
    move3 = pkmn.moves[3] ? getMoveName(pkmn.moves[3].move) : "--"
    textpositions = [
      [_INTL("#{pkmn.name}"), 4, 0, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Lv: #{pkmn.level}"), 4, 27, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("#{getAbilityName(pkmn.ability)}"), 4, 257, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("#{move0}"), 4, 149, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("#{move1}"), 4, 175, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("#{move2}"), 4, 201, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("#{move3}"), 4, 227, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("#{itemname}"), 4, 58, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
    ]
    if pkmn.gender == 0
      textpositions.push([_INTL("♂"), 227, 60, false, Color.new(120, 184, 248), Color.new(0, 120, 248)])
    elsif pkmn.gender == 1
      textpositions.push([_INTL("♀"), 227, 60, false, Color.new(248, 128, 128), Color.new(168, 24, 24)])
    end
    pbSetExtraSmallFont(@overlay2.bitmap)
    if !pkmn.isEgg?
      pbDrawTextPositions(@overlay2.bitmap, textpositions)
      @overlay2.bitmap.blt(186, 4, @yourtype1bitmap, Rect.new(0, 0, 64, 28))
      @overlay2.bitmap.blt(186, 4 + 28, @yourtype2bitmap, Rect.new(0, 0, 64, 28)) if @yourtype2bitmap
    end
    tts("Your Pokémon: Level #{pkmn.level} #{pkmn.name}")
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Display's the user's party.
  #-------------------------------------------------------------------------------
  ################################################################################
  def mylist
    textpos = [
      [_INTL("#{$network.username}'s list"), 130, 6, 2, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("#{@username}'s list"), 385, 6, 2, Color.new(255, 255, 255), Color.new(0, 0, 0)],
    ]
    @overlay.bitmap.font.name = "PokemonEmerald"
    @overlay.bitmap.font.size = 36
    pbDrawTextPositions(@overlay.bitmap, textpos)
    if !@partysent
      # we must serialie the data in order to send the whole class then encode
      # in base 64 (and delete the newline that the packing causes) in order for
      # server not to go beserk (serialised data is binary, server does not understand
      # how to receive this data as it is, encoding in base 64 avoids this)
      party = [Marshal.dump($Trainer.party)].pack("m").delete("\n")
      $network.send("<TRA party=" + party + ">")
      @partysent = true
    end
    for i in 0..$Trainer.party.length - 1
      @sprite[i] =
        PokemonTradeIcon.new($Trainer.party[i], $Trainer.party[i].eggsteps, $Trainer.party[i].personalID, false, @viewport)
      @spritehidden[i] =
        PokemonTradeIcon.new($Trainer.party[i], $Trainer.party[i].eggsteps, $Trainer.party[i].personalID, false, @viewport)
      @spritehidden[i].visible = false if @spritehidden[i] != nil
      @spritehidden[i].x = 186 if @spritehidden[i] != nil
      @spritehidden[i].y = 87 if @spritehidden[i] != nil
      @spritehidden[i].z = 1000009 if @spritehidden[i] != nil
    end
    @sprite[0].x = 49 if @sprite[0] != nil
    @sprite[0].y = 71 if @sprite[0] != nil
    @sprite[1].x = 144 if @sprite[1] != nil
    @sprite[1].y = 71 if @sprite[1] != nil
    @sprite[2].x = 49 if @sprite[2] != nil
    @sprite[2].y = 167 if @sprite[2] != nil
    @sprite[3].x = 144 if @sprite[3] != nil
    @sprite[3].y = 167 if @sprite[3] != nil
    @sprite[4].x = 49 if @sprite[4] != nil
    @sprite[4].y = 263 if @sprite[4] != nil
    @sprite[5].x = 144 if @sprite[5] != nil
    @sprite[5].y = 263 if @sprite[5] != nil
    @sprite[0].z = 1000005 if @sprite[0] != nil
    @sprite[1].z = 1000005 if @sprite[1] != nil
    @sprite[2].z = 1000005 if @sprite[2] != nil
    @sprite[3].z = 1000005 if @sprite[3] != nil
    @sprite[4].z = 1000005 if @sprite[4] != nil
    @sprite[5].z = 1000005 if @sprite[5] != nil
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Receives the data for the other user's chosen pokemon.
  #-------------------------------------------------------------------------------
  ################################################################################
  def receiveoffer(data, index)
    @theirchosen = Marshal.load(data.unpack("m")[0]) # decode base 64 and load serialised data
    @theirindex = index
    @received = true
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Displays the information about the other user's chosen pokemon.
  #-------------------------------------------------------------------------------
  ################################################################################
  def their_info
    @received = false
    @waiting.visible = false
    itemname = @theirchosen.item.nil? ? _INTL("NO ITEM") : getItemName(@theirchosen.item)
    @spritexhidden[@theirindex].visible = true
    @overlay3.bitmap.clear
    imagepos2 = []
    @theirtype1bitmap = pbPokemonTypeBitmap(@theirchosen.type1)
    @theirtype2bitmap = pbPokemonTypeBitmap(@theirchosen.type2) if @theirchosen.type2
    move0x = @theirchosen.moves[0] ? getMoveName(@theirchosen.moves[0].move) : "--"
    move1x = @theirchosen.moves[1] ? getMoveName(@theirchosen.moves[1].move) : "--"
    move2x = @theirchosen.moves[2] ? getMoveName(@theirchosen.moves[2].move) : "--"
    move3x = @theirchosen.moves[3] ? getMoveName(@theirchosen.moves[3].move) : "--"
    textpositions2 = [
      [_INTL("{1}", @theirchosen.name), 262, 0, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("Lv: {1}", @theirchosen.level), 262, 27, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("{1}", getAbilityName(@theirchosen.ability)), 262, 257, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("{1}", move0x), 262, 149, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("{1}", move1x), 262, 175, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("{1}", move2x), 262, 201, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("{1}", move3x), 262, 227, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
      [_INTL("{1}", itemname), 262, 58, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)],
    ]
    if @theirchosen.gender == 0
      textpositions2.push([_INTL("♂"), 485, 60, false, Color.new(120, 184, 248), Color.new(0, 120, 248)])
    elsif @theirchosen.gender == 1
      textpositions2.push([_INTL("♀"), 485, 60, false, Color.new(248, 128, 128), Color.new(168, 24, 24)])
    end
    pbSetExtraSmallFont(@overlay3.bitmap)
    if !@theirchosen.isEgg?
      pbDrawTextPositions(@overlay3.bitmap, textpositions2)
      @overlay3.bitmap.blt(444, 4, @theirtype1bitmap, Rect.new(0, 0, 64, 28))
      @overlay3.bitmap.blt(444, 4 + 28, @theirtype2bitmap, Rect.new(0, 0, 64, 28)) if @theirtype2bitmap
    end
    yourName = getMonName($Trainer.party[@index - 1].species, $Trainer.party[@index - 1].form)
    theirName = getMonName(@theirchosen.species, @theirchosen.form)
    # tts
    tts("Pokémon Offered:")
    tts("Level #{@theirchosen.level} #{@theirchosen.name}")
    tts("Species: #{theirName}")
    tts("Item: #{itemname}")
    if @theirchosen.gender == 0
      tts("Gender: Male")
    elsif @theirchosen.gender == 1
      tts("Gender: Female")
    end
    tts("Ability: #{getAbilityName(@theirchosen.ability)}")
    tts("Moves: ")
    tts(move0x) if move0x != "--"
    tts(move1x) if move1x != "--"
    tts(move2x) if move2x != "--"
    tts(move3x) if move3x != "--"
    if Kernel.pbConfirmMessage(_INTL("Trade your #{yourName} for their #{theirName}?"))
      @waiting.visible = true
      $network.send("<TRA accepted>")
      @accepted = true
    else
      trade_declined
      $network.send("<TRA declined>")
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Procedure that is called when the other player declines the trade.
  #-------------------------------------------------------------------------------
  ################################################################################
  def trade_declined
    @waiting.visible = false
    @info.visible = false
    for i in 0...$Trainer.party.length
      @spritehidden[i].visible = false
    end
    for i in 0...@theirparty.length
      @spritexhidden[i].visible = false
    end
    @overlay2.bitmap.clear
    @overlay3.bitmap.clear
    @pokemonselected = false
    @theirchosen = nil
    @theirindex = -1
    @accepted = false
    @received = false
    @listreceived = false
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Excutes the trade, this is where the pokemon chosen is modified to the new one.
  #-------------------------------------------------------------------------------
  ################################################################################
  def execute_trade
    @waiting.visible = false
    @theirchosen.obtainMode = 2
    @theirchosen.obtainLevel = @theirchosen.level
    @theirchosen.happiness = $cache.pkmn[@theirchosen.species, @theirchosen.form].Happiness
    old = $Trainer.party[@index - 1]
    $Trainer.party[@index - 1] = @theirchosen
    pbSave
    Kernel.pbMessage("Saved the game!")
    pbFadeOutInWithMusic(99999) {
      evo = PokemonTradeScene.new
      evo.pbStartScreen(old, @theirchosen, $network.username, @username)
      evo.pbTrade
      evo.pbEndScreen
    }
    $Trainer.pokedex.dexList[@theirchosen.species][:seen?] = true
    $Trainer.pokedex.dexList[@theirchosen.species][:owned?] = true
    $Trainer.pokedex.setFormSeen(@theirchosen)
    $scene = Scene_Trade.new(@username)
  end
end

################################################################################
#-------------------------------------------------------------------------------
# Other Essentials based classes and methods needed for the scene to function
#-------------------------------------------------------------------------------
################################################################################
class PokemonTradeIcon < SpriteWrapper
  attr_accessor :selected
  attr_accessor :active
  attr_reader :pokemon

  def initialize(pokemon, eggsteps, personalID, active, viewport = nil)
    super(viewport)
    @eggsteps = eggsteps
    @personalID = personalID
    @animbitmap = nil
    @frames = [
      Rect.new(0, 0, 64, 64),
      Rect.new(64, 0, 64, 64)
    ]
    @active = active
    @selected = false
    @animframe = 0
    self.pokemon = pokemon
    @frame = 0
    @pokemon = pokemon
    @spriteX = self.x
    @spriteY = self.y
    @updating = false
  end

  def width
    return 300
  end

  def height
    return 300
  end

  def pokemon=(pokemon)
    @animbitmap.dispose if @animbitmap
    @animbitmap = pbPokemonIconBitmap(pokemon, pokemon.isEgg?)
    self.bitmap = @animbitmap
    self.src_rect = @frames[@animframe]
  end

  def dispose
    @animbitmap.dispose
    super
  end

  def update
    @updating = true
    super
    frameskip = 5
    if frameskip == -1
      @animframe = 0
      self.src_rect = @frames[@animframe]
    else
      @frame += 1
      @frame = 0 if @frame > 100
      if @frame >= frameskip
        @animframe = (@animframe == 1) ? 0 : 1
        self.src_rect = @frames[@animframe]
        @frame = 0
      end
    end
    if self.selected
      if !self.active
        self.x = @spriteX + 8
        self.y = (@animframe == 0) ? @spriteY - 6 : @spriteY + 2
      else
        self.x = @spriteX
        self.y = (@animframe == 0) ? @spriteY + 2 : @spriteY + 10
      end
    end
  end

  def x=(value)
    super
    @spriteX = value if !@updating
  end

  def y=(value)
    super
    @spriteY = value if !@updating
  end
end

=begin
def pbLoadTradeIcon(pokemon,eggsteps,personalID)
  return RPG::Cache.load_bitmap(pbPokemonTradeFile(pokemon))
end

def pbPokemonTradeFile(pokemon)
  return pbCheckPokemonIconFiles([pokemon.species,
                          (pokemon.isFemale?),
                          pokemon.isShiny?,
                          (pokemon.form rescue 0),
                          (pokemon.isShadow? rescue false)],
                          pokemon.isEgg?)
end

def pbLoadTradeBitmap(species,eggsteps,personalID,trainerID)
  return pbLoadTradeBitmapSpecies(species,eggsteps,personalID,trainerID)
end

def pbLoadTradeBitmapSpecies(species,eggsteps,personalID,trainerID)
    return RPG::Cache.load_bitmap(
    sprintf("Graphics/Pictures/Battle/ball00.png"))
end

def pbcheckShiny(personalID,trainerID)
  a=personalID.to_i^trainerID.to_i
  b=a&0xFFFF
  c=(a>>16)&0xFFFF
  d=b^c
  return (d<8)
end
=end

def pbSetExtraSmallFont(bitmap)
  bitmap.font.name = MessageConfig.pbGetSystemFontName
  bitmap.font.size = 32
end

def pbPokemonTypeBitmap(type)
  return RPG::Cache.load_bitmap(sprintf("Graphics/Icons/type#{type}.png"))
end

def endtrade
  $network.close
  $scene = Scene_Map.new
end

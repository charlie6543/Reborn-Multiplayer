################################################################################
#-------------------------------------------------------------------------------
# Author: Alexandre
# Handles Connection, Registration and Login
#-------------------------------------------------------------------------------
################################################################################
class Connect
  ################################################################################
  #-------------------------------------------------------------------------------
  # Let's start the Scene
  #-------------------------------------------------------------------------------
  ################################################################################
  def initialize(sbase = false)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @overlay = SpriteWrapper.new(@viewport)
    @overlay.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @viewport.z = 99999
    @waitgraph = SpriteWrapper.new(@viewport)
    @waitgraph.visible = false
    @waitgraph.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/onlinewaiting.png")
    @username = ""
    @password = ""
    @email = ""
    @peer = ""
    @base = sbase
    @tiebreak = nil
    @host = false
    @waitfortrade = false
    @waitforwondertrade = false
    @waitforbattle = false
    @waitforrandombattle = false
    @allowrandbat = true
    @allowtrade = true
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Opens a connection tests if it can and is allowed to connect to the server
  #-------------------------------------------------------------------------------
  ################################################################################
  def main
    Graphics.transition
    Graphics.update
    if GAMETITLE == "Pokemon Reborn" && $Trainer.pokedex.dexList.length != 807
      Kernel.pbMessage(_INTL("You're playing a mod with an extended Pokédex. Such mods should override GAMETITLE and GAMEVERSION in order to access online features to ensure compatibility."))
      $scene = Scene_Map.new
      return
    end
    if $game_switches
      if $game_switches[:Randomized_Challenge] || $game_switches[:Disabled_Randomizer]
        Kernel.pbMessage(_INTL("Unfortunately, online features cannot be used in Randomizer playthroughs."))
        $scene = Scene_Map.new
        return
      end
      # Restrict online play
      restrictOnlineFeatures
      if $game_switches[:No_Online_Randbats]
        Kernel.pbMessage(_INTL("Random battles are restricted on this save file."))
        @allowrandbat = false
      end
      if $game_switches[:No_Online_Trades]
        Kernel.pbMessage(_INTL("Trades are restricted on this save file."))
        @allowtrade = false
      end
    end
    if !isLegalParty?($Trainer.party)
      Kernel.pbMessage(_INTL("Illegal Pokémon have been detected in your party."))
      Kernel.pbMessage(_INTL("Random battles and trades are restricted until the illegal Pokémon are removed."))
      @allowrandbat = false
      @allowtrade = false
    end
    if !nicknameFilterCheck($Trainer)
      $scene = Scene_Map.new
      return
    end
    if !nicknameFilterCheck($Trainer)
      $scene = Scene_Map.new
      return
    end
    if !trainerNameFilterCheck($Trainer.name)
      commands = [_INTL("Yes"), _INTL("No")]
      choice = Kernel.pbMessage(_INTL("Would you like to change your trainer name to allow online access?"), commands)
      if choice == 0
        Kernel.pbMessage(_INTL("Please note that any Pokémon that have your old name as their OT will have it changed to reflect your new name."))
        onlineNameChange
        $scene = Scene_Map.new
        return
      elsif choice == 1
        $scene = Scene_Map.new
        return
      end
    end
    $Trainer.storedOnlineParty = []
    version = getAPIVersion()
    begin
      $network = Network.new
      $network.open
      $network.send("<CON version=#{version}>")
      Kernel.pbMessage("Connecting to server...\n(Press C / Enter / Space)")
    rescue
      if localServer?
        Kernel.pbMessage("Your local testing server #{NETWORK_HOST}:#{NETWORK_PORT} is offline.")
      else
        Kernel.pbMessage("Server is not online or your internet connection has a problem.")
      end
      $scene = Scene_Map.new
      Graphics.freeze
      $network.close
      @viewport.dispose
    end
    loop do
      break if $scene != self

      update
      if Input.trigger?(Input::B)
        @waitfortrade = false
        @waitforwondertrade = false
        @waitforbattle = false
        @waitforrandombattle = false
        restore_trainer_party
        if @waitgraph.visible == false
          exit_online_play
          break
        else
          @waitgraph.visible = false
          tradeorbattle
        end
      end
    end
    Graphics.freeze
    @viewport.dispose
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Loop to constantly check for messages from the server
  #-------------------------------------------------------------------------------
  ################################################################################
  def update
    message = $network.listen
    handle(message)
    @viewport.update
    @overlay.update
    Graphics.update
    Input.update
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Handles incoming messages from server. Aborts connection if unknown message is
  # received
  #-------------------------------------------------------------------------------
  ################################################################################
  def handle(message)
    if message.kind_of?(Array)
      message = message[0]
    end
    case message
      when /<CON result=(.*)>/ then check_connection($1.to_i)
      when /<DSC>/ then disconnect("")
      when /<DSC reason=(.*)>/ then disconnect($1.to_s)
      when /<REG result=(.*)>/ then check_registration($1.to_i)
      when /<LOG result=(.*)>/ then check_login($1.to_i)
      when /<TRAREQ user=(.*) result=(.*) name=(.*)>/ then check_trade($1.to_s, $2.to_i, $3.to_s) if @waitfortrade
      when /<TRARES user=(.*) player=(.*)>/ then initiate_trade($1.to_i, $2.to_s) if (($1.to_i == 0) || @waitfortrade)
      when /<TRAREJ user=(.*)>/ then rejectionT($1.to_s) if @waitfortrade
      when /<TRA ready>/ then $scene = Scene_Trade.new(@peer)
      when /<BATCHAL user=(.*) result=(.*) trainer=(.*) name=(.*)>/ then choose_field($1.to_s, $2.to_i, $3, $4.to_s) if @waitforbattle
      when /<BATHOST opponent=(.*) result=(.*) field=(.*) name=(.*)>/ then offer_field($1, $2.to_i, $3.to_i, $4.to_s) if @waitforbattle
      when /<BATFIELD result=(.*) effect=(.*) user=(.*)>/ then initiate_battle($1.to_i, $2.to_i, $3.to_i)
      when /<BAT ready>/ then start_battle($onlineChallenger, @host ? 1 : 0)
      when /<BATREJ user=(.*)>/ then rejectionB($1.to_s) if @waitforbattle
      when /<RANBAT user=(.*) tie=(.*)>/ then rand_verify($1.to_s, $2.to_i) if @waitforrandombattle
      when /<BAT trainer=(.*)>/ then get_randopp($1.to_s)
      when /<YESRAN>/ then initiate_battle(0, 0, @tiebreak.to_i)
      when /<NORAN name=(.*)>/ then rand_reject($1.to_s)
      when /<WONTRA err=(.*)>/ then wonder_err($1.to_s) if @waitforwondertrade
      when /<WONTRA pokemon=(.*) user=(.*) id=(.*)>/ then wonder_trading($1.to_s, $2.to_s, $3.to_i) if @waitforwondertrade
      when /<WONTRA gift>/ then give_wonder_gift if @waitforwondertrade
      when "" then nil

      when /<GLOBAL message=(.*)>/ then Kernel.pbMessage("#{$1.to_s}")

      when /<ACTI>/ then $network.send("<ACTI>")
      when /<PNG>/ then nil
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Check's response from server to see if we are allowed to connect
  #-------------------------------------------------------------------------------
  ################################################################################
  def check_connection(result)
    if result == 0
      Kernel.pbMessage("Your version is outdated; please download the latest version.")
      exit_online_play
    elsif result == 1
      Kernel.pbMessage("The server is full; please try again later.")
      exit_online_play
    else
      Kernel.pbMessage("Connection successful.")
      registerorlogin
    end
  end

  def getAPIVersion()
    return "2"
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Simply asks the user if he or she wants to register, login or abort.
  #-------------------------------------------------------------------------------
  ################################################################################
  def registerorlogin
    commands = [_INTL("Login"), _INTL("Register"), _INTL("Options"), _INTL("Cancel")]
    choice = Kernel.pbMessage(_INTL("What do you want to do?"), commands, commands.length)
    if choice == 0
      attempt_login
    elsif choice == 1
      attempt_register
    elsif choice == 2
      commands = [_INTL("Online Battle Music"), _INTL("Wonder-Trade Nicknames"), _INTL("Cancel")]
      choose = Kernel.pbMessage(_INTL("What do you want to do?"), commands, commands.length)
      case choose
        when 0 then selectOnlineBGM($Trainer)
        when 1 then selectAllowingNickNames($Trainer)
        when 2 then registerorlogin
      end
    elsif choice == 3
      exit_online_play
    end
  end

  def selectOnlineBGM(trainer)
    commands = []
    OnlineBGM.each { |bgm| commands.push(_INTL(bgm[0])) } if OnlineBGM
    commands.push(_INTL("Back"))
    choice = Kernel.pbMessage(_INTL("What music would you like to play in online battles?"), commands, OnlineBGM ? OnlineBGM.length : 0)
    trainer.onlineMusic = OnlineBGM[choice][1] if OnlineBGM && choice != OnlineBGM.length
    registerorlogin
  end

  def selectAllowingNickNames(trainer)
    trainer.onlineAllowNickNames = Kernel.pbConfirmMessage("Do you allow wonder-traded Pokémon to hold their nicknames?")
    registerorlogin
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Disconnects the user if the server requires it.
  #-------------------------------------------------------------------------------
  ################################################################################
  def disconnect(reason)
    Kernel.pbMessage("You have been disconnected: #{reason}")
    exit_online_play
  end

  def exit_online_play
    $network.close
    restore_trainer_party
    $scene = Scene_Map.new
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Attempts to register the user.
  #-------------------------------------------------------------------------------
  ################################################################################
  def attempt_register
    loop do
      @username = Kernel.pbMessageFreeText(_INTL("Please enter a username."), "", false, 32)
      break if @username == ""

      if @username != ""
        username = Kernel.pbMessageFreeText(_INTL("Please re-enter your username."), "", false, 32)
        break if @username == username

        Kernel.pbMessage("The username you entered does not match, please try again.")
      end
    end
    return registerorlogin if @username == ""
    return registerorlogin if !usernameFilterCheck(@username)

    loop do
      @password = Kernel.pbMessageFreeText(_INTL("Please enter a password."), "", true, 32)
      if @password != ""
        password = Kernel.pbMessageFreeText(_INTL("Please re-enter your password."), "", true, 32)
        break if @password == password

        Kernel.pbMessage("The password you entered does not match, please try again.")
      end
      break if @password == ""
    end
    if @password == ""
      registerorlogin
    else
      $network.send("<REG user=#{@username} pass=#{@password}>")
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Checks server's result for registration.
  #-------------------------------------------------------------------------------
  ################################################################################
  def check_registration(result)
    if result == 0
      Kernel.pbMessage("The username is already taken, please try a different username.")
      attempt_register
    elsif result == 1
      Kernel.pbMessage("The email you entered has already been used to register an account, you can only have one acount per email.")
      attempt_register
    elsif result == 2
      Kernel.pbMessage("Registration was successful!")
      registerorlogin
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Attempts to log into the server.
  #-------------------------------------------------------------------------------
  ################################################################################
  def attempt_login
    tempuser = ""
    @username = Kernel.pbMessageFreeText(_INTL("Please enter your username."), tempuser, false, 32)
    if @username == ""
      registerorlogin
    else
      temppass = ""
      @password = Kernel.pbMessageFreeText(_INTL("Please enter your password."), temppass, true, 32)
      if @password == ""
        registerorlogin
      else
        $network.send("<LOG user=#{@username} pass=#{@password} gametitle=#{GAMETITLE} gameversion=#{GAMEVERSION}>")
        Kernel.pbMessage("Logging in...\n(Press C / Enter / Space)")
      end
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Check's login result from server
  #-------------------------------------------------------------------------------
  ################################################################################
  def check_login(result)
    if result == 0
      Kernel.pbMessage("The username entered does not exist.")
      registerorlogin
    elsif result == 1
      Kernel.pbMessage("The password entered is incorrect.")
      registerorlogin
    elsif result == 2
      Kernel.pbMessage("This account has been banned.")
      registerorlogin
    elsif result == 3
      Kernel.pbMessage("Your IP has been banned.")
      exit_online_play
    elsif result == 4
      $network.loggedin = true
      $network.username = @username
      Kernel.pbMessage("Login was successful!")
      tradeorbattle
    elsif result == 5
      Kernel.pbMessage("This account is already logged in.")
      registerorlogin
    elsif result == 6
      Kernel.pbMessage("Login attempt timeout.")
      registerorlogin
    elsif result == 7
      Kernel.pbMessage("Invalid version.")
      registerorlogin
    else
      Kernel.pbMessage("Unknown login failure: #{result}")
      registerorlogin
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Simply asks the user if they want to trade or battle.
  #-------------------------------------------------------------------------------
  ################################################################################
  def tradeorbattle
    restore_trainer_party
    commands = [_INTL("Battle")]
    commands.push(_INTL("Trade")) if @allowtrade
    commands.push(_INTL("Cancel"))
    choice = Kernel.pbMessage(_INTL("What do you want to do?"), commands, commands.length)
    label = commands[choice]
    if label == _INTL("Battle")
      battlecommands = [_INTL("Challenge")]
      battlecommands.push(_INTL("Wait for Challenge"))
      battlecommands.push(_INTL("Random Matchup")) if @allowrandbat
      battlecommands.push(_INTL("Back"))
      battlechoice = Kernel.pbMessage(_INTL("What do you want to do?"), battlecommands, battlecommands.length)
      battlelabel = battlecommands[battlechoice]
      if battlelabel == _INTL("Challenge")
        battlechallenge
      elsif battlelabel == _INTL("Wait for Challenge")
        battlehost
      elsif battlelabel == _INTL("Random Matchup")
        randbat
      elsif battlelabel == _INTL("Back")
        tradeorbattle
      end
    elsif label == _INTL("Trade")
      tradecommands = [_INTL("Request Trade")]
      tradecommands.push(_INTL("Wait for Request"))
      tradecommands.push(_INTL("Wonder Trade"))
      tradecommands.push(_INTL("Back"))
      tradechoice = Kernel.pbMessage(_INTL("What do you want to do?"), tradecommands, tradecommands.length)
      tradelabel = tradecommands[tradechoice]
      if tradelabel == _INTL("Request Trade")
        traderequest
      elsif tradelabel == _INTL("Wait for Request")
        tradehost
      elsif tradelabel == _INTL("Wonder Trade")
        wondertrade
      elsif tradelabel == _INTL("Back")
        tradeorbattle
      end
    else
      exit_online_play
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Starts trade procedures
  #-------------------------------------------------------------------------------
  ################################################################################
  def traderequest
    @host = false
    loop do
      @player = Kernel.pbMessageFreeText(_INTL("Who would you like to request to trade with?"), "", false, 32)
      sameplayer = @player.downcase == $network.username.downcase
      Kernel.pbMessage("You cannot trade with yourself.") if sameplayer
      return tradeorbattle if @player == "" || sameplayer
      break if @player != "" || !sameplayer
    end
    $network.send("<TRAREQ user=#{@player} name=#{$network.username}>")
    @waitfortrade = true
    @waitgraph.visible = true
  end

  def tradehost
    @host = true
    @waitfortrade = true
    @waitgraph.visible = true
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Checks server's response for trade
  #-------------------------------------------------------------------------------
  ################################################################################
  def rejectionT(user)
    @waitfortrade = false
    @waitgraph.visible = false
    Kernel.pbMessage("#{user} has declined your request.")
    return tradeorbattle
  end

  def check_trade(player, result, name)
    @waitfortrade = false
    @waitgraph.visible = false
    if result == 0
      Kernel.pbMessage(_INTL("The user #{player} does not exist."))
      tradeorbattle
    elsif result == 1
      Kernel.pbMessage(_INTL("The user #{player} has been banned."))
      tradeorbattle
    elsif result == 2
      Kernel.pbMessage(_INTL("The user #{player} is not online."))
      tradeorbattle
    elsif result == 3
      Kernel.pbMessage(_INTL("The user #{player} has declined or did not respond to your trade request."))
      tradeorbattle
    elsif result == 4
      commands = [_INTL("Yes")]
      commands.push(_INTL("No"))
      choice = Kernel.pbMessage(_INTL("The user #{name} has sent a trade request. Do you accept?"), commands)
      if choice == 0
        $network.send("<TRAHOST user=#{name} name=#{player}>")
      elsif choice == 1
        $network.send("<TRAREJ user=#{$network.username} name=#{name}>")
        tradeorbattle
      end
    end
  end

  def initiate_trade(user, player)
    if user == 0
      Kernel.pbMessage(_INTL("Your trade will begin shortly."))
    elsif user == 1
      @waitfortrade = false
      @waitgraph.visible = false
      Kernel.pbMessage(_INTL("Your request was accepted. The trade will begin shortly."))
    end
    @peer = player
    $network.send("<TRA ready>")
    @waitgraph.visible = true
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Wonder Trade
  #-------------------------------------------------------------------------------
  ################################################################################
  def wondertrade
    pbChoosePokemon(
      Variables[:Party_Pokemon_Index], Variables[:Party_Pokemon_Name],
      proc { |poke| !poke.egg? }
    )
    if $game_variables[:Party_Pokemon_Index] >= 0
      trainerMon = $Trainer.party[$game_variables[:Party_Pokemon_Index]]
      monName = trainerMon.name
      commands = [_INTL("Yes")]
      commands.push(_INTL("No"))
      choice = Kernel.pbMessage(_INTL("Are you sure you want to wonder trade #{monName}?"), commands)
      if choice == 1
        return wondertrade
      elsif choice == 0
        $network.send("<WONTRA p_id=#{trainerMon.personalID}>")
        @waitforwondertrade = true
        @waitgraph.visible = true
      end
    else
      tradeorbattle
    end
  end

  def wonder_err(error)
    @waitforwondertrade = false
    @waitgraph.visible = false
    if error == "limit"
      Kernel.pbMessage(_INTL("Unable to find a trade partner right now. Please try again later."))
    end
    if error == "p_id"
      Kernel.pbMessage(_INTL("This Pokémon can't be traded right now. Please try again later."))
    end
    exit_online_play
  end

  def decline_wonder_trade
    Kernel.pbMessage(_INTL("Something went wrong. Please try again later."))
    exit_online_play
  end

  def wonder_trading(mon, owner, id)
    @waitforwondertrade = false
    @waitgraph.visible = false
    begin
      wondermon = Marshal.load(mon.unpack("m")[0])
    rescue
      decline_wonder_trade
    else
      if isLegal?(wondermon)
        trainerMon = $Trainer.party[$game_variables[:Party_Pokemon_Index]]
        serialized = [Marshal.dump(trainerMon)].pack("m").delete("\n")
        $network.send("<WONTRA species=#{trainerMon.species} p_id=#{trainerMon.personalID} insert=#{serialized} delete=#{id}>")
      else
        decline_wonder_trade
      end
    end
    Kernel.pbMessage(_INTL("You will be trading with #{owner}."))
    # Allowing nicknamed Pokemon
    nickname = $Trainer.onlineAllowNickNames ? wondermon.name : getMonName(wondermon.species, wondermon.form)
    wondermon.name = nickname
    ot = wondermon.ot
    wondermon.obtainMode = 2
    wondermon.obtainLevel = wondermon.level
    wondermon.happiness = $cache.pkmn[wondermon.species, wondermon.form].Happiness
    pbStartTrade($game_variables[:Party_Pokemon_Index], wondermon, nickname, ot, true)
    pbSave
    Kernel.pbMessage("Saved the game!")
    tradeorbattle
  end

  def get_wonder_gift
    firstformlist = []
    $cache.pkmn.each { |poke|
      next if poke[0] == :DITTO
      next if poke[0] == :MANAPHY
      next if poke[1][0].evolutions
      next if poke[1][0].EggGroups.include?(:Undiscovered)

      pokemon = pbGetBabySpecies(poke[0])[0]
      firstformlist.push(pokemon)
    }
    firstformlist.push(:UNOWN)
    firstformlist.push(:PIKACHU)
    firstformlist = firstformlist.uniq
    giftspecies = firstformlist.sample
    forms = []
    formban = [
      "Mega", "Giga", "Busted", "Meteor", "Sunny", "Rainy", "Snowy",
      "Purple", " Rotom", "School", "PULSE", "Rift", "Perfection"
    ]
    $cache.pkmn[giftspecies].forms.each { |form|
      next if formban.any? { |ban| form[1].include?(ban) }
      next if form[1].include?("Aevian") && !Rejuv

      forms.push(form[0])
    }
    giftform = forms.sample
    eggmoves = $cache.pkmn[giftspecies, giftform].EggMoves
    eggmove = eggmoves.sample if eggmoves != []
    gift = PokeBattle_Pokemon.new(giftspecies, 1, knownTrainer("Nyu"), true, giftform)
    gift.name = "Pikachu"
    gift.pbLearnMove(eggmove) if eggmove
    gift.pbRecordFirstMoves
    gift.obtainMode = 2
    gift.obtainMap = 299
    return gift
  end

  def give_wonder_gift
    @waitforwondertrade = false
    @waitgraph.visible = false
    wondermon = get_wonder_gift
    nickname = $Trainer.onlineAllowNickNames ? wondermon.name : getMonName(wondermon.species, wondermon.form)
    wondermon.name = nickname
    trainerMon = $Trainer.party[$game_variables[:Party_Pokemon_Index]]
    serialized = [Marshal.dump(trainerMon)].pack("m").delete("\n")
    $network.send("<WONTRA species=#{trainerMon.species} p_id=#{trainerMon.personalID} insert=#{serialized} delete=0>")
    Kernel.pbMessage(_INTL("You will be trading with Nyu!"))
    pbStartTrade($game_variables[:Party_Pokemon_Index], wondermon, nickname, "Nyu", true)
    pbSave
    Kernel.pbMessage("Saved the game!")
    tradeorbattle
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Starts battle procedures
  #-------------------------------------------------------------------------------
  ################################################################################
  def battlechallenge
    @host = false
    party_check
    @doubles = Kernel.pbMessage(_INTL("Would you like a singles or doubles battle?"), ["Singles", "Doubles"])
    backup_trainer_party
    set_party_levels

    mons = trainer_to_string
    trainerAry = [$Trainer.name, $Trainer.id, $Trainer.trainertype, mons, @doubles]

    serialized = trainerAry.join("/g/")
    loop do
      @player = Kernel.pbMessageFreeText(_INTL("Who would you like to challenge?"), "", false, 32)
      sameplayer = @player.downcase == $network.username.downcase
      Kernel.pbMessage("You cannot battle with yourself.") if sameplayer
      if @player == "" || sameplayer
        restore_trainer_party
        return tradeorbattle
      end
      break
    end
    $network.send("<BATCHAL user=#{@player} trainer=#{serialized} name=#{$network.username}>")
    @waitforbattle = true
    @waitgraph.visible = true
  end

  def battlehost
    @host = true
    party_check
    backup_trainer_party
    set_party_levels

    mons = trainer_to_string
    trainerAry = [$Trainer.name, $Trainer.id, $Trainer.trainertype, mons, 2]

    serialized = trainerAry.join("/g/")
    $onlineChallengee = serialized
    # Storing own trainer data to send later
    @waitforbattle = true
    @waitgraph.visible = true
  end

  def party_check
    if !$Trainer.party[0] || $Trainer.party[0].egg? || $Trainer.party[0].hp < 1
      Kernel.pbMessage("You need to be able to use the first Pokémon in your party.")
      return tradeorbattle
    end
  end

  def backup_trainer_party
    $Trainer.storedOnlineParty = Array.new
    for i in 0..$Trainer.party.length - 1
      $Trainer.storedOnlineParty[i] = $Trainer.party[i].clone
    end
    for i in 0..$Trainer.party.length - 1
      $Trainer.party[i].moves = $Trainer.party[i].moves.clone
      $Trainer.party[i].moves.map! { |move| move.clone }
      $Trainer.party[i].heal
    end
  end

  def restore_trainer_party
    if $Trainer.storedOnlineParty != []
      $Trainer.party = $Trainer.storedOnlineParty
      $Trainer.storedOnlineParty = []
    end
  end

  def set_party_levels
    for i in $Trainer.party
      next if i.nil?

      unless i.isEgg?
        i.level = 100
        i.exp = PBExp.startExperience(100, i.growthrate)
        i.calcStats
      end
    end
  end

  def trainer_to_string
    pokemonArray = []
    for poke in $Trainer.party
      shininess = poke.isShiny? ? 1 : 0
      varArray = [
        poke.species,
        100,
        poke.iv[0],
        poke.iv[1],
        poke.iv[2],
        poke.iv[3],
        poke.iv[4],
        poke.iv[5],
        poke.ev[0],
        poke.ev[1],
        poke.ev[2],
        poke.ev[3],
        poke.ev[4],
        poke.ev[5],
        poke.personalID,
        poke.trainerID,
        poke.item ? poke.item : nil,
        poke.name,
        poke.exp,
        poke.happiness,
        poke.moves[0] ? poke.moves[0].move : nil,
        poke.moves[0] ? poke.moves[0].pp : nil,
        poke.moves[1] ? poke.moves[1].move : nil,
        poke.moves[1] ? poke.moves[1].pp : nil,
        poke.moves[2] ? poke.moves[2].move : nil,
        poke.moves[2] ? poke.moves[2].pp : nil,
        poke.moves[3] ? poke.moves[3].move : nil,
        poke.moves[3] ? poke.moves[3].pp : nil,
        poke.form,
        poke.nature,
        poke.totalhp,
        poke.attack,
        poke.defense,
        poke.spatk,
        poke.spdef,
        poke.speed,
        poke.ballused,
        poke.ot,
        shininess,
        poke.ability,
        pbHiddenPower(poke)
      ]
      pokemonArray.push(varArray.join("^%*"))
    end
    for var in pokemonArray
      var = var.to_s
    end
    return pokemonArray.join("/u/")
  end

  def get_opponent_team(data)
    pokeAry = []
    for prePoke in data[3]
      longarray = prePoke.split("^%*")
      mon = PokeBattle_Pokemon.new(longarray[0].to_sym, 100, $Trainer, false)
      thing = 0
      for v in 2..7
        mon.iv[thing] = longarray[v].to_i
        thing += 1
      end
      thing = 0
      for v in 8..13
        mon.ev[thing] = longarray[v].to_i
        thing += 1
      end
      mon.personalID = longarray[14].to_i
      mon.trainerID = longarray[15].to_i
      mon.item = longarray[16].to_sym if !longarray[16].empty?
      mon.name = longarray[17]
      mon.exp = longarray[18].to_i
      mon.happiness = longarray[19].to_i
      for i in 0..3
        mon.pbLearnMove(longarray[20 + (i * 2)].to_sym) if !longarray[20 + (i * 2)].empty?
        mon.moves[i].pp = longarray[21 + (i * 2)].to_i if !longarray[20 + (i * 2)].empty?
      end
      mon.form = longarray[28].to_i
      mon.setNature(longarray[29].to_sym)
      mon.ballused = longarray[36].to_sym
      mon.ot = longarray[37]
      if longarray[38].to_i == 0 && mon.isShiny?
        mon.makeNotShiny
      elsif longarray[38].to_i == 1
        mon.makeShiny
      end
      mon.ability = (longarray[39].to_sym)
      mon.hptype = (longarray[40].to_sym)
      pokeAry.push(mon)
    end
    deserialized = PokeBattle_Trainer.new(data[0], data[2].to_sym)
    deserialized.id = data[1]
    deserialized.party = pokeAry
    return deserialized
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Checks server's response for battle
  #-------------------------------------------------------------------------------
  ################################################################################
  def rejectionB(user)
    @waitforbattle = false
    @waitgraph.visible = false
    Kernel.pbMessage("#{user} has declined your challenge.")
    restore_trainer_party
    return tradeorbattle
  end

  def choose_field(player, result, opponent, name)
    @waitforbattle = false
    @waitgraph.visible = false
    response = [
      "The user #{player} does not exist.",
      "The user #{player} has been banned.",
      "The user #{player} is not online.",
      "The user #{player} has declined or did not respond to your battle request.",
      "",
      "The user #{player} is using a different game.",
      "The user #{player} is using a different version of the game.",
    ]
    if result == 4
      commands = [_INTL("Yes")]
      commands.push(_INTL("No"))
      unpacked = opponent.split("/g/")
      @doubles = unpacked[4].to_i
      if @doubles == 0 # Single battle
        choice = Kernel.pbMessage(_INTL("You have been challenged by #{name} for a singles battle. Do you accept?"), commands)
      else # Doubles battle
        choice = Kernel.pbMessage(_INTL("You have been challenged by #{name} for a doubles battle. Do you accept?"), commands)
      end
      if choice == 0
        # Gather opponent's details into $onlineChallenger
        unpacked[3] = unpacked[3].split("/u/")
        $onlineChallenger = get_opponent_team(unpacked)
        commands = [_INTL("Accept")]
        commands.push(_INTL("Decline"))
        if !isLegalParty?($onlineChallenger.party)
          choice = Kernel.pbMessage(_INTL("#{name}'s party has illegal Pokémon. The battle may be unfair or cause errors. Do you still accept this challenge?"), commands)
          if choice == 1
            reject_battle(name)
          end
        end
        # Opponent information gathered and stored
        fields = [_INTL("No Field")]
        fields.push(_INTL("Random"))
        for i in 1..TOTALFIELDS
          fields.push($cache.FEData[fieldIDToSym(i)].name)
        end
        choose = Kernel.pbMessage(_INTL("What field would you like to battle on?"), fields)
        $network.send("<BATHOST user=#{name} trainer=#{$onlineChallengee} field=#{choose} name=#{player}>")
      elsif choice == 1
        reject_battle(name)
      end
    else
      Kernel.pbMessage(_INTL(response[result]))
      restore_trainer_party
      tradeorbattle
    end
  end

  def offer_field(opponent, result, field, name)
    @waitforbattle = false
    @waitgraph.visible = false
    # Gather opponent's details into $onlineChallenger
    begin
      unpacked = opponent.split("/g/")
      unpacked[3] = unpacked[3].split("/u/")
    rescue
      Kernel.pbMessage("Something has gone wrong. It might be possible that you've both challenged each other instead of one waiting for a challenge.")
      return tradeorbattle
    end
    $onlineChallenger = get_opponent_team(unpacked)
    # Opponent information gathered and stored
    commands = [_INTL("Yes")]
    commands.push(_INTL("No"))
    case result
      when 0 # No field
        Kernel.pbMessage("Your opponent has chosen to battle with no field.")
        $feonline = 0
        $network.send("<BATFIELD result=0 effect=#{field} name=#{name}>")
        return
      when 1 # Random field
        mess = "Your opponent has chosen to battle in a random field. Do you accept?"
      when 5, 24, 26 # Dark Crystal Cavern, Cave, Cystal Cavern
        mess = "Your opponent has chosen to battle in the " + $cache.FEData[fieldIDToSym(field)].name + ". Do you accept?"
      when 23 # Underwater
        mess = "Your opponent has chosen to battle " + $cache.FEData[fieldIDToSym(field)].name + ". Do you accept?"
      else
        mess = "Your opponent has chosen to battle on the " + $cache.FEData[fieldIDToSym(field)].name + ". Do you accept?"
    end
    choice = Kernel.pbMessage(_INTL(mess), commands)
    if choice == 0
      $feonline = field
      $network.send("<BATFIELD result=#{choice} effect=#{field} name=#{name}>")
    elsif choice == 1
      $feonline = 0
      $network.send("<BATFIELD result=#{choice} effect=0 name=#{name}>")
    end
  end

  def initiate_battle(result, effect, user)
    if user == 0
      if effect == 0
        $feonline = :INDOOR # double check this
      else
        $feonline = fieldIDToSym(effect)
      end
      Kernel.pbMessage(_INTL("Your battle will begin shortly."))
      # Kernel.pbMessage(_INTL("Do not click outside the window during the battle!"))
      # return start_battle($onlineChallenger, user)
    elsif user == 1
      if result == 0
        if effect == 0
          $feonline = :INDOOR # double check this
        else
          $feonline = fieldIDToSym(effect)
        end
        Kernel.pbMessage(_INTL("The opponent has accepted your field choice. Your battle will begin shortly."))
        # Kernel.pbMessage(_INTL("Do not click outside the window during the battle!"))
        # return start_battle($onlineChallenger, user)
      elsif result == 1
        $feonline = :INDOOR # double check this
        Kernel.pbMessage(_INTL("The opponent has declined your field choice. Your battle will begin shortly."))
        # Kernel.pbMessage(_INTL("Do not click outside the window during the battle!"))
        # return start_battle($onlineChallenger, user)
      end
    end
    $network.send("<BAT ready>")
    @waitgraph.visible = true
  end

  def reject_battle(name)
    $network.send("<BATREJ user=#{$network.username} name=#{name}>")
    restore_trainer_party
    return tradeorbattle
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Executes a battle
  #-------------------------------------------------------------------------------
  ################################################################################
  def start_battle(opponent, tiebreak)
    @waitgraph.visible = false
    scene = pbNewBattleScene
    battle = PokeBattle_OnlineBattle.new(scene, $Trainer.party, opponent.party, $Trainer, opponent, tiebreak)
    battle.doublebattle = @doubles == 1
    $OnlineBattle = battle

    battle.fullparty1 = $Trainer.party.length == 6
    battle.fullparty2 = opponent.party.length == 6
    battle.endspeech = ""
    battle.internalbattle = false
    playingBGS = $game_system.getPlayingBGS
    playingBGM = $game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgs_pause
    decision = battle.pbStartBattle(true)

    # After the battle is over
    $OnlineBattle = nil
    exit_online_play if !$network.loggedin
    restore_trainer_party
    if decision == 1
      Kernel.pbMessage("You won the battle.")
    else
      Kernel.pbMessage("You lost the battle.")
    end
    $game_system.bgm_resume(playingBGM)
    $game_system.bgs_resume(playingBGS)
    tradeorbattle
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Handles Random Battling
  #-------------------------------------------------------------------------------
  ################################################################################
  def randbat
    party_check
    backup_trainer_party
    set_party_levels

    mons = trainer_to_string
    trainerAry = [$Trainer.name, $Trainer.id, $Trainer.trainertype, mons]

    serialized = trainerAry.join("/g/")
    $onlineChallengee = serialized
    # Storing own trainer data to send later
    $network.send("<RANBAT>")
    @waitforrandombattle = true
    @waitgraph.visible = true
  end

  def rand_verify(name, tie)
    @waitforrandombattle = false
    @waitgraph.visible = false
    @tiebreak = tie
    commands = [_INTL("Yes")]
    commands.push(_INTL("No"))
    choice = Kernel.pbMessage(_INTL("Would you like to battle with #{name}?"), commands)
    if choice == 0
      $network.send("<RANVER name=#{name} trainer=#{$onlineChallengee}>")
    elsif choice == 1
      $network.send("<NORAN name=#{name}>")
      randbat
    end
  end

  def rand_reject(name)
    Kernel.pbMessage("Your opponent either declined or did not respond.")
    restore_trainer_party
    randbat
  end

  def get_randopp(opponent)
    # Gather opponent's details into $onlineChallenger
    unpacked = opponent.split("/g/")
    unpacked[3] = unpacked[3].split("/u/")
    $onlineChallenger = get_opponent_team(unpacked)
    # Opponent information gathered and stored
    $network.send("<YESRAN>")
  end
end

module Graphics
  PING_RATE = 5 # Amount of seconds between each server ping
  @@last_ping = Time.now

  class << self
    alias __ping_update update unless method_defined?(:__ping_update)
  end

  def self.update
    self.sendPing
    __ping_update
  end

  def self.sendPing
    return unless defined?($network)
    return unless $network.loggedin

    time = Time.now
    if time - @@last_ping >= PING_RATE
      $network.send("<BEAT>")
      @@last_ping = time
    end
  end
end

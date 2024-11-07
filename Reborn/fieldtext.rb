FIELDEFFECTS = {
  :INDOOR => {
    :name => "",
    :fieldAppSwitch => nil, # Switch ID which determines if the player has the data for this field
    :fieldMessage => [
      ""
    ],
    :graphic => ["Indoor", "IndoorA", "IndoorB", "IndoorC", "City", "CityNew"],
    :secretPower => :TRIATTACK,
    :naturePower => :TRIATTACK,
    :mimicry => :NORMAL,
    :damageMods => { # damage modifiers for specific moves, written as multipliers (e.g. 1.5 => [:TACKLE])
    }, # a damage mod of 0 denotes the move failing on this field
    :accuracyMods => { # accuracy chance for specific moves, written as percent chance to hit (e.g. 80 => [:TOXIC])
    }, # a accuracy mod of 0 denotes the move always hitting on this field
    :moveMessages => { # the field message displayed when using a move (written as "message" => [move1,move2....] )
    },
    :typeMods => { # secondary types applied to moves (written as "type" => [move1,move2,....])
    },
    :typeAddOns => { # secondary types applied to entire types (written as SecondaryTypeSymbol => [typesymbol1,typesymbol2,...])
    },
    :fieldCounterIncreases => { # field counter increases towards field transformations
    }, # needs to be separate from moveEffects so that we can correctly apply the 1.3 damage multiplier
    :moveEffects => { # arbitrary commands that are evaled after a move executes but before fieldchanges are checked
    }, # evaled in "fieldEffectAfterMove" method in the battle class
    :typeBoosts => { # damage multipliers applied to all moves of a specific type (e.g. 1.3 => [:FIRE,:WATER])
    },
    :typeMessages => { # field message shown when using a move of the denoted type ("message" => [type1,type2,....])
    },
    :typeCondition => { # conditions for the type boost written as a string of conditions that are evaled later
    }, # evaled as a function on the move class
    :typeEffects => { # arbitrary commands attached to all moves of a type that are evaled after a move executes but before fieldchanges are checked
    }, # evaled in "fieldEffectAfterMove" method in the battle class
    :changeCondition => { # conditions for a field change written as a string of conditions that are evaled later
    }, # evaled as a function on the move class
    :fieldChange => { # moves that change this field to a different field (Fieldsymbol => [move1,move2,....])
    },
    :dontChangeBackup => [], # list of moves which store the current field as backup when changing the field
    :changeMessage => { # message displayed when changing a field to a different one ("message" => [move1,move2,....])
    },
    :statusMods => [], # list of non-damaging moves boosted by the field in different ways, for field highlighting
    :changeEffects => { # additional effects that happen when specific moves change a field (such as corrisive mist explosion)
    }, # evaled in "fieldEffectAfterMove" method in the battle class
    :seed => { # the seed effects on this field
      :seedtype => nil, # which seed is activated
      :effect => nil, # which battler effect is being changed if any
      :duration => nil, # duration of the extra effect
      :message => nil, # message shown with the seeds boost
      :animation => nil, # animation associated with the effect
      :stats => { # statchanges caused by the seed
      },
    },
  },
  :ELECTERRAIN => {
    :name => "Electric Terrain",
    :fieldAppSwitch => 600,
    :fieldMessage => [
      "The field is hyper-charged!"
    ],
    :graphic => ["Electric"],
    :secretPower => :SHOCKWAVE,
    :naturePower => :THUNDERBOLT,
    :mimicry => :ELECTRIC,
    :damageMods => {
      1.5 => [:EXPLOSION, :SELFDESTRUCT, :HURRICANE, :SURF, :SMACKDOWN, :MUDDYWATER, :THOUSANDARROWS],
      2.0 => [:MAGNETBOMB],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The explosion became hyper-charged!" => [:EXPLOSION, :SELFDESTRUCT],
      "The attack became hyper-charged!" => [:HURRICANE, :SURF, :SMACKDOWN, :MUDDYWATER, :THOUSANDARROWS],
      "The attack powered up!" => [:MAGNETBOMB],
    },
    :typeMods => {
      :ELECTRIC => [:EXPLOSION, :SELFDESTRUCT, :SMACKDOWN, :SURF, :MUDDYWATER, :HURRICANE, :THOUSANDARROWS, :HYDROVORTEX],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:ELECTRIC],
    },
    :typeMessages => {
      "The Electric Terrain strengthened the attack!" => [:ELECTRIC],
    },
    :typeCondition => {
      :ELECTRIC => "!attacker.isAirborne?",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :INDOOR => [:MUDSPORT, :TECTONICRAGE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The hyper-charged terrain shorted out!" => [:MUDSPORT, :TECTONICRAGE],
    },
    :statusMods => [:CHARGE, :EERIEIMPULSE, :MAGNETRISE],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => :Charge,
      :duration => 2,
      :message => "{1} began charging power!",
      :animation => :CHARGE,
      :stats => {
        PBStats::SPEED => 1,
      },
    },
  },
  :GRASSY => {
    :name => "Grassy Terrain",
    :fieldAppSwitch => 601,
    :fieldMessage => [
      "The field is in full bloom."
    ],
    :graphic => ["Grassy"],
    :secretPower => :SEEDBOMB,
    :naturePower => :ENERGYBALL,
    :mimicry => :GRASS,
    :damageMods => {
      1.5 => [:FAIRYWIND, :SILVERWIND],
      0.5 => [:MUDDYWATER, :SURF, :EARTHQUAKE, :MAGNITUDE, :BULLDOZE],
    },
    :accuracyMods => {
      80 => [:GRASSWHISTLE],
    },
    :moveMessages => {
      "The wind picked up strength from the field!" => [:FAIRYWIND, :SILVERWIND],
      "The grass softened the attack..." => [:MUDDYWATER, :SURF, :EARTHQUAKE, :MAGNITUDE, :BULLDOZE],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:GRASS, :FIRE],
    },
    :typeMessages => {
      "The Grassy Terrain strengthened the attack!" => [:GRASS],
      "The grass below caught flame!" => [:FIRE],
    },
    :typeCondition => {
      :GRASS => "!attacker.isAirborne?",
      :FIRE => "!opponent.isAirborne?",
    },
    :typeEffects => {},
    :changeCondition => {
      :BURNING => "ignitecheck",
    },
    :fieldChange => {
      :BURNING => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE],
      :CORROSIVE => [:SLUDGEWAVE, :ACIDDOWNPOUR],
    },
    :dontChangeBackup => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE, :SLUDGEWAVE, :ACIDDOWNPOUR],
    :changeMessage => {
      "The grassy terrain caught fire!" => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE],
      "The grassy terrain was corroded!" => [:SLUDGEWAVE, :ACIDDOWNPOUR],
    },
    :statusMods => [:COIL, :GROWTH, :FLORALHEALING, :GRASSWHISTLE],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => :Ingrain,
      :duration => true,
      :message => "{1} planted its roots!",
      :animation => :INGRAIN,
      :stats => {
        PBStats::DEFENSE => 1,
      },
    },
  },
  :MISTY => {
    :name => "Misty Terrain",
    :fieldAppSwitch => 602,
    :fieldMessage => [
      "Mist settles on the field."
    ],
    :graphic => ["Misty"],
    :secretPower => :MISTBALL,
    :naturePower => :MISTBALL,
    :mimicry => :FAIRY,
    :damageMods => {
      1.5 => [:FAIRYWIND, :MYSTICALFIRE, :MOONBLAST, :MAGICALLEAF, :DOOMDUMMY, :ICYWIND, :MISTBALL, :AURASPHERE, :STEAMERUPTION, :DAZZLINGGLEAM, :SILVERWIND, :MOONGEISTBEAM],
      0.5 => [:DARKPULSE, :SHADOWBALL, :NIGHTDAZE],
      0 => [:SELFDESTRUCT, :EXPLOSION, :MINDBLOWN],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The mist's energy strengthened the attack!" => [
        :FAIRYWIND, :MYSTICALFIRE, :MOONBLAST, :MAGICALLEAF, :DOOMDUMMY,
        :ICYWIND, :MISTBALL, :AURASPHERE, :STEAMERUPTION, :DAZZLINGGLEAM, :SILVERWIND, :MOONGEISTBEAM
      ],
      "The mist softened the attack..." => [:DARKPULSE, :SHADOWBALL, :NIGHTDAZE],
      "The dampness prevents the explosion!" => [:SELFDESTRUCT, :EXPLOSION, :MINDBLOWN],
    },
    :typeMods => {},
    :typeAddOns => {},
    :fieldCounterIncreases => {
      [1, 1] => [:CLEARSMOG, :POISONGAS, :SMOG],
      [1, 2] => [:ACIDDOWNPOUR],
    },
    :moveEffects => {},
    :typeBoosts => {
      0.5 => [:DRAGON],
    },
    :typeMessages => {
      "The Misty Terrain weakened the attack!" => [:DRAGON],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :CORROSIVEMIST => "@battle.field.counter > 1",
    },
    :fieldChange => {
      :INDOOR => [:WHIRLWIND, :GUST, :RAZORWIND, :DEFOG, :HURRICANE, :TWISTER, :TAILWIND, :SUPERSONICSKYSTRIKE],
      :CORROSIVEMIST => [:CLEARSMOG, :POISONGAS, :SMOG, :ACIDDOWNPOUR]
    },
    :dontChangeBackup => [:CLEARSMOG, :POISONGAS, :SMOG, :ACIDDOWNPOUR],
    :changeMessage => {
      "The mist was blown away!" => [:WHIRLWIND, :GUST, :RAZORWIND, :DEFOG, :HURRICANE, :TWISTER, :TAILWIND, :SUPERSONICSKYSTRIKE],
      "The mist was corroded!" => [:CLEARSMOG, :POISONGAS, :SMOG, :ACIDDOWNPOUR],
    },
    :statusMods => [:COSMICPOWER, :AROMATICMIST, :SWEETSCENT],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },
  :DARKCRYSTALCAVERN => {
    :name => "Dark Crystal Cavern",
    :fieldAppSwitch => 603,
    :fieldMessage => [
      "Darkness is gathering..."
    ],
    :graphic => ["DarkCrystalCavern"],
    :secretPower => :DARKPULSE,
    :naturePower => :DARKPULSE,
    :mimicry => :DARK,
    :damageMods => {
      1.5 => [
        :DARKPULSE, :NIGHTDAZE, :NIGHTSLASH, :SHADOWBALL, :SHADOWPUNCH, :SHADOWCLAW, :SHADOWSNEAK, :SHADOWFORCE,
        :SHADOWBONE, :AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :LUSTERPURGE, :DAZZLINGGLEAM, :MIRRORSHOT, :TECHNOBLAST, :DOOMDUMMY, :POWERGEM, :MOONGEISTBEAM, :PHOTONGEYSER, :DIAMONDSTORM, :MENACINGMOONRAZEMAELSTROM
      ],
      2.0 => [:PRISMATICLASER, :BLACKHOLEECLIPSE],
      0.5 => [:LIGHTTHATBURNSTHESKY],
    },
    :accuracyMods => {
      100 => [:DARKVOID],
    },
    :moveMessages => {
      "The darkness began to gather...!" => [:DARKPULSE, :NIGHTDAZE, :NIGHTSLASH],
      "The darkness strengthened the attack!" => [:SHADOWBALL, :SHADOWPUNCH, :SHADOWCLAW, :SHADOWSNEAK, :SHADOWFORCE, :SHADOWBONE, :MENACINGMOONRAZEMAELSTROM],
      "The crystals' light strengthened the attack!" => [:AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :LUSTERPURGE, :DAZZLINGGLEAM, :MIRRORSHOT, :TECHNOBLAST, :DOOMDUMMY, :POWERGEM, :MOONGEISTBEAM, :PHOTONGEYSER, :DIAMONDSTORM],
      "The crystal split the attack!" => [:PRISMATICLASER],
      "The consuming darkness fed the attack!" => [:BLACKHOLEECLIPSE],
      "{1} couldn't consume much light..." => [:LIGHTTHATBURNSTHESKY],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :CRYSTALCAVERN => "suncheck",
    },
    :fieldChange => {
      :CAVE => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE],
      :CRYSTALCAVERN => [:SUNNYDAY],
    },
    :dontChangeBackup => [:SUNNYDAY],
    :changeMessage => {
      "The dark crystals were shattered!" => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE],
      "The sun lit up the crystal cavern!" => [:SUNNYDAY],
    },
    :statusMods => [:FLASH, :DARKVOID, :MOONLIGHT],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => :MagicCoat,
      :duration => true,
      :message => "{1} shrouded itself with Magic Coat!",
      :animation => :MAGICCOAT,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },
  :CHESS => {
    :name => "Chess Board",
    :fieldAppSwitch => 604,
    :fieldMessage => [
      "Opening variation set."
    ],
    :graphic => ["Chess"],
    :secretPower => :FEINT,
    :naturePower => :ANCIENTPOWER,
    :mimicry => :PSYCHIC,
    :damageMods => {
      1.5 => [
        :FEINT, :FEINTATTACK, :FAKEOUT, :SUCKERPUNCH, :FIRSTIMPRESSION, :SHADOWSNEAK, :SMARTSTRIKE, :STRENGTH,
        :ANCIENTPOWER, :PSYCHIC, :CONTINENTALCRUSH, :SECRETPOWER, :SHATTEREDPSYCHE
      ],
    },
    :accuracyMods => {},
    :moveMessages => {
      "En passant!" => [:FEINT, :FEINTATTACK, :FAKEOUT, :SUCKERPUNCH, :FIRSTIMPRESSION, :SHADOWSNEAK, :SMARTSTRIKE],
    },
    :typeMods => {
      :ROCK => [:STRENGTH, :ANCIENTPOWER, :PSYCHIC, :CONTINENTALCRUSH, :SECRETPOWER, :SHATTEREDPSYCHE],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :INDOOR => [:STOMPINGTANTRUM, :TECTONICRAGE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The board was destroyed!" => [:STOMPINGTANTRUM, :TECTONICRAGE],
    },
    :statusMods => [:CALMMIND, :NASTYPLOT, :TRICKROOM],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :MagicCoat,
      :duration => true,
      :message => "{1} shrouded itself with Magic Coat!",
      :animation => :MAGICCOAT,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },
  :BIGTOP => {
    :name => "Big Top Arena",
    :fieldAppSwitch => 605,
    :fieldMessage => [
      "Now presenting...!"
    ],
    :graphic => ["BigTop"],
    :secretPower => :DYNAMICPUNCH,
    :naturePower => :ACROBATICS,
    :mimicry => :NORMAL,
    :damageMods => {
      1.5 => [:VINEWHIP, :POWERWHIP, :FIRELASH, :FIERYDANCE, :PETALDANCE, :REVELATIONDANCE, :FLY, :ACROBATICS, :FIRSTIMPRESSION],
      2.0 => [:PAYDAY],
    },
    :accuracyMods => {
      100 => [:SING],
    },
    :moveMessages => {
      "Back, foul beast!" => [:VINEWHIP, :POWERWHIP, :FIRELASH],
      "What grace!" => [:FIERYDANCE, :PETALDANCE, :REVELATIONDANCE],
      "An extravagant aerial finish!" => [:FLY, :ACROBATICS],
      "And what an entrance it is!" => [:FIRSTIMPRESSION],
      "And a little extra for you, darling!" => [:PAYDAY],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusMods => [:ENCORE, :DRAGONDANCE, :QUIVERDANCE, :SWORDSDANCE, :FEATHERDANCE, :SING, :RAINDANCE, :BELLYDRUM, :SPOTLIGHT],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :HelpingHand,
      :duration => true,
      :message => "{1} accepts the crowd's help!",
      :animation => :HELPINGHAND,
      :stats => {
        PBStats::ATTACK => 1,
      },
    },
  },
  :BURNING => {
    :name => "Burning Field",
    :fieldAppSwitch => 606,
    :fieldMessage => [
      "The field is ablaze!"
    ],
    :graphic => ["Burning"],
    :secretPower => :FLAMETHROWER,
    :naturePower => :FLAMETHROWER,
    :mimicry => :FIRE,
    :damageMods => {
      1.5 => [:SMOG, :CLEARSMOG],
      2.0 => [:SMACKDOWN, :THOUSANDARROWS],
    },
    :accuracyMods => {
      100 => [:WILLOWISP],
    },
    :moveMessages => {
      "The flames spread from the attack!" => [:SMOG, :CLEARSMOG],
      "{1} was knocked into the flames!" => [:SMACKDOWN, :THOUSANDARROWS],
    },
    :typeMods => {
      :FIRE => [:SMACKDOWN, :SMOG, :CLEARSMOG, :THOUSANDARROWS],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:FIRE],
      0.5 => [:GRASS, :ICE],
    },
    :typeMessages => {
      "The blaze amplified the attack!" => [:FIRE],
      "The blaze softened the attack..." => [:GRASS, :ICE],
    },
    :typeCondition => {
      :FIRE => "!attacker.isAirborne?",
      :GRASS => "!opponent.isAirborne?",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :INDOOR => [
        :WHIRLWIND, :GUST, :RAZORWIND, :DEFOG, :HURRICANE, :TWISTER, :TAILWIND, :SUPERSONICSKYSTRIKE, :WATERSPORT, :SURF, :MUDDYWATER, :WATERSPOUT, :WATERPLEDGE, :SPARKLINGARIA, :SLUDGEWAVE, :SANDTOMB, :CONTINENTALCRUSH,
        :HYDROVORTEX, :OCEANICOPERETTA
      ],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The grime snuffed out the flame!" => [:SLUDGEWAVE],
      "The wind snuffed out the flame!" => [:WHIRLWIND, :GUST, :RAZORWIND, :DEFOG, :HURRICANE, :TWISTER, :TAILWIND, :SUPERSONICSKYSTRIKE],
      "The water snuffed out the flame!" => [:WATERSPORT, :SURF, :MUDDYWATER, :WATERSPOUT, :WATERPLEDGE, :SPARKLINGARIA, :HYDROVORTEX, :OCEANICOPERETTA],
      "The sand snuffed out the flame!" => [:SANDTOMB, :CONTINENTALCRUSH],
    },
    :statusMods => [:WILLOWISP, :SMOKESCREEN],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => :MultiTurnAttack,
      :duration => :FIRESPIN,
      :message => "{1} was trapped in the vortex!",
      :animation => :FIRESPIN,
      :stats => {
        PBStats::ATTACK => 1,
        PBStats::SPATK => 1,
        PBStats::SPEED => 1,
      },
    },
  },
  :SWAMP => {
    :name => "Swamp Field",
    :fieldAppSwitch => 607,
    :fieldMessage => [
      "The field is swamped."
    ],
    :graphic => ["Swamp"],
    :secretPower => :MUDDYWATER,
    :naturePower => :MUDDYWATER,
    :mimicry => :WATER,
    :damageMods => {
      1.5 => [:MUDBOMB, :MUDSHOT, :MUDSLAP, :MUDDYWATER, :SURF, :SLUDGEWAVE, :GUNKSHOT, :BRINE, :SMACKDOWN,
              :THOUSANDARROWS, :HYDROVORTEX],
      0.25 => [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE],
      0 => [:SELFDESTRUCT, :EXPLOSION, :MINDBLOWN],
    },
    :accuracyMods => {
      100 => [:SLEEPPOWDER],
    },
    :moveMessages => {
      "The murk strengthened the attack!" => [:MUDBOMB, :MUDSHOT, :MUDSLAP, :MUDDYWATER, :SURF, :SLUDGEWAVE, :GUNKSHOT, :BRINE, :SMACKDOWN, :THOUSANDARROWS, :HYDROVORTEX],
      "The attack dissipated in the soggy ground..." => [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE],
      "The dampness prevents the explosion!" => [:SELFDESTRUCT, :EXPLOSION, :MINDBLOWN],
    },
    :typeMods => {
      :WATER => [:SMACKDOWN, :THOUSANDARROWS],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:POISON],
    },
    :typeMessages => {
      "The poison infected the nearby murk!" => [:POISON],
    },
    :typeCondition => {
      :POISON => "!opponent.isAirborne?",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusMods => [:SLEEPPOWDER, :AQUARING],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => :Ingrain,
      :duration => true,
      :message => "{1} planted its roots!",
      :animation => :INGRAIN,
      :stats => {
        PBStats::DEFENSE => 1,
        PBStats::SPDEF => 1,
      },
    },
  },
  :RAINBOW => {
    :name => "Rainbow Field",
    :fieldAppSwitch => 608,
    :fieldMessage => [
      "What does it mean?"
    ],
    :graphic => ["Rainbow"],
    :secretPower => :AURORABEAM,
    :naturePower => :AURORABEAM,
    :mimicry => :DRAGON,
    :damageMods => {
      1.5 => [:SILVERWIND, :MYSTICALFIRE, :DRAGONPULSE, :TRIATTACK, :SACREDFIRE, :FIREPLEDGE, :WATERPLEDGE, :GRASSPLEDGE,
              :AURORABEAM, :JUDGMENT, :RELICSONG, :HIDDENPOWER, :SECRETPOWER, :WEATHERBALL, :MISTBALL, :HEARTSTAMP, :MOONBLAST, :ZENHEADBUTT, :SPARKLINGARIA, :FLEURCANNON, :PRISMATICLASER, :TWINKLETACKLE, :OCEANICOPERETTA, :SOLARBEAM, :SOLARBLADE, :DAZZLINGGLEAM],
      0.5 => [:DARKPULSE, :SHADOWBALL, :NIGHTDAZE, :NEVERENDINGNIGHTMARE],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The attack was rainbow-charged!" => [
        :SILVERWIND, :MYSTICALFIRE, :DRAGONPULSE, :TRIATTACK, :SACREDFIRE, :FIREPLEDGE, :WATERPLEDGE, :GRASSPLEDGE, :AURORABEAM, :JUDGMENT, :RELICSONG, :HIDDENPOWER, :SECRETPOWER, :WEATHERBALL,
        :MISTBALL, :HEARTSTAMP, :MOONBLAST, :ZENHEADBUTT, :SPARKLINGARIA, :FLEURCANNON, :PRISMATICLASER, :TWINKLETACKLE, :OCEANICOPERETTA, :SOLARBEAM, :SOLARBLADE, :DAZZLINGGLEAM
      ],
      "The rainbow softened the attack..." => [:DARKPULSE, :SHADOWBALL, :NIGHTDAZE, :NEVERENDINGNIGHTMARE],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:NORMAL],
    },
    :typeMessages => {
      "The rainbow energized the attack!" => [:NORMAL],
    },
    :typeCondition => {
      :NORMAL => "self.pbIsSpecial?(type)",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :INDOOR => [:LIGHTTHATBURNSTHESKY],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The rainbow was consumed!" => [:LIGHTTHATBURNSTHESKY],
    },
    :statusMods => [:COSMICPOWER, :MEDITATE, :WISH],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },
  :CORROSIVE => {
    :name => "Corrosive Field",
    :fieldAppSwitch => 609,
    :fieldMessage => [
      "The field is corrupted!"
    ],
    :graphic => ["Corrosive"],
    :secretPower => :ACID,
    :naturePower => :ACIDSPRAY,
    :mimicry => :POISON,
    :damageMods => {
      1.5 => [:SMACKDOWN, :MUDSLAP, :MUDSHOT, :MUDBOMB, :MUDDYWATER, :WHIRLPOOL, :THOUSANDARROWS],
      2.0 => [:ACID, :ACIDSPRAY, :GRASSKNOT],
    },
    :accuracyMods => {
      100 => [:POISONPOWDER, :SLEEPPOWDER, :STUNSPORE, :TOXIC],
    },
    :moveMessages => {
      "The corrosion strengthened the attack!" => [:SMACKDOWN, :MUDSLAP, :MUDSHOT, :MUDBOMB, :MUDDYWATER, :WHIRLPOOL, :THOUSANDARROWS, :ACID, :ACIDSPRAY, :GRASSKNOT],
    },
    :typeMods => {
      :POISON => [:SMACKDOWN, :MUDSLAP, :MUDSHOT, :MUDDYWATER, :WHIRLPOOL, :MUDBOMB, :THOUSANDARROWS],
    },
    :typeAddOns => {
      :POISON => [:GRASS],
    },
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :GRASSY => [:SEEDFLARE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The polluted field was purified!" => [:SEEDFLARE],
    },
    :statusMods => [:ACIDARMOR, :POISONPOWDER, :SLEEPPOWDER, :STUNSPORE, :TOXIC],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => :Protect,
      :duration => :BanefulBunker,
      :message => "The Telluric Seed shielded {1} against damage!",
      :animation => :BANEFULBUNKER,
      :stats => {},
    },
  },
  :CORROSIVEMIST => {
    :name => "Corrosive Mist Field",
    :fieldAppSwitch => 610,
    :fieldMessage => [
      "Corrosive mist settles on the field!"
    ],
    :graphic => ["CorrosiveMist"],
    :secretPower => :ACIDSPRAY,
    :naturePower => :VENOSHOCK,
    :mimicry => :POISON,
    :damageMods => {
      1.5 => [:BUBBLEBEAM, :ACIDSPRAY, :BUBBLE, :SMOG, :CLEARSMOG, :SPARKLINGARIA],
    },
    :accuracyMods => {
      100 => [:TOXIC],
    },
    :moveMessages => {
      "The poison strengthened the attack!" => [:BUBBLEBEAM, :ACIDSPRAY, :BUBBLE, :SMOG, :CLEARSMOG, :SPARKLINGARIA],
    },
    :typeMods => {
      :POISON => [:BUBBLE, :BUBBLEBEAM, :ENERGYBALL, :SPARKLINGARIA],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:FIRE],
    },
    :typeMessages => {
      "The toxic mist caught flame!" => [:FIRE],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :INDOOR => [
        :WHIRLWIND, :GUST, :RAZORWIND, :DEFOG, :HURRICANE, :TWISTER, :TAILWIND, :SUPERSONICSKYSTRIKE, :HEATWAVE,
        :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE, :SELFDESTRUCT, :EXPLOSION
      ],
      :MISTY => [:SEEDFLARE],
      :CORROSIVE => [:GRAVITY],
    },
    :dontChangeBackup => [:GRAVITY],
    :changeMessage => {
      "The mist was blown away!" => [:WHIRLWIND, :GUST, :RAZORWIND, :DEFOG, :HURRICANE, :TWISTER, :TAILWIND, :SUPERSONICSKYSTRIKE],
      "The polluted mist was purified!" => [:SEEDFLARE],
      "The toxic mist collected on the ground!" => [:GRAVITY],
    },
    :statusMods => [:ACIDARMOR],
    :changeEffects => {
      "@battle.mistExplosion(basemove, user)" => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE, :SELFDESTRUCT, :EXPLOSION],
    },
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::ATTACK => 1,
        PBStats::SPATK => 1,
      },
    },
  },
  :DESERT => {
    :name => "Desert Field",
    :fieldAppSwitch => 611,
    :fieldMessage => [
      "The field is rife with sand."
    ],
    :graphic => ["Desert"],
    :secretPower => :SANDTOMB,
    :naturePower => :SANDTOMB,
    :mimicry => :GROUND,
    :damageMods => {
      1.5 => [:NEEDLEARM, :PINMISSILE, :DIG, :SANDTOMB, :HEATWAVE, :THOUSANDWAVES, :BURNUP, :SEARINGSUNRAZESMASH,
              :SOLARBLADE, :SOLARBEAM],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The desert strengthened the attack!" => [:NEEDLEARM, :PINMISSILE, :DIG, :SANDTOMB, :HEATWAVE, :THOUSANDWAVES, :BURNUP, :SEARINGSUNRAZESMASH, :SOLARBLADE, :SOLARBEAM],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      0.5 => [:WATER, :ELECTRIC],
    },
    :typeMessages => {
      "The desert softened the attack..." => [:WATER, :ELECTRIC],
    },
    :typeCondition => {
      :WATER => "!attacker.isAirborne?",
      :ELECTRIC => "!opponent.isAirborne?",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusMods => [:SANDSTORM, :SUNNYDAY, :SANDATTACK, :SHOREUP],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => :MultiTurnAttack,
      :duration => :SANDTOMB,
      :message => "{1} was trapped by Sand Tomb!",
      :animation => :SANDTOMB,
      :stats => {
        PBStats::DEFENSE => 1,
        PBStats::SPDEF => 1,
        PBStats::SPEED => 1,
      },
    },
  },
  :ICY => {
    :name => "Icy Field",
    :fieldAppSwitch => 612,
    :fieldMessage => [
      "The field is covered in ice."
    ],
    :graphic => ["Icy"],
    :secretPower => :ICESHARD,
    :naturePower => :ICEBEAM,
    :mimicry => :ICE,
    :damageMods => {
      0.5 => [:SCALD, :STEAMERUPTION],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The cold softened the attack..." => [:SCALD, :STEAMERUPTION],
    },
    :typeMods => {},
    :typeAddOns => {
      :ICE => [:ROCK],
    },
    :fieldCounterIncreases => {
      [1, 1] => [:SCALD, :STEAMERUPTION],
      [1, 2] => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE],
    },
    :moveEffects => {
      "@battle.iceSpikes" => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE],
    },
    :typeBoosts => {
      1.5 => [:ICE],
      0.5 => [:FIRE],
    },
    :typeMessages => {
      "The cold strengthened the attack!" => [:ICE],
      "The cold softened the attack..." => [:FIRE],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :INDOOR => "[:WATERSURFACE,:MURKWATERSURFACE].include?(@battle.field.backup)",
      :WATERSURFACE => "@battle.field.counter > 1",
    },
    :fieldChange => {
      :WATERSURFACE => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE, :SCALD, :STEAMERUPTION],
      :INDOOR => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The ice melted away!" => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE],
      "The quake broke up the ice and revealed the water beneath!" => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE],
      "The hot water melted the ice!" => [:SCALD, :STEAMERUPTION],
    },
    :statusMods => [:ACIDARMOR],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::SPEED => 2,
      },
    },
  },
  :ROCKY => {
    :name => "Rocky Field",
    :fieldAppSwitch => 613,
    :fieldMessage => [
      "The field is littered with rocks."
    ],
    :graphic => ["Rocky"],
    :secretPower => :ROCKTHROW,
    :naturePower => :ROCKSMASH,
    :mimicry => :ROCK,
    :damageMods => {
      1.5 => [:ROCKCLIMB, :STRENGTH, :MAGNITUDE, :EARTHQUAKE, :BULLDOZE, :ACCELEROCK],
      2.0 => [:ROCKSMASH],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The rocks strengthened the attack!" => [:ROCKCLIMB, :STRENGTH, :MAGNITUDE, :EARTHQUAKE, :BULLDOZE, :ACCELEROCK],
      "SMASH'D!" => [:ROCKSMASH],
    },
    :typeMods => {
      :ROCK => [:ROCKCLIMB, :EARTHQUAKE, :MAGNITUDE, :STRENGTH, :BULLDOZE],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:ROCK],
    },
    :typeMessages => {
      "The field strengthened the attack!" => [:ROCK],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusMods => [:ROCKPOLISH],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::DEFENSE => 1,
      },
    },
  },
  :FOREST => {
    :name => "Forest Field",
    :fieldAppSwitch => 614,
    :fieldMessage => [
      "The field is abound with trees."
    ],
    :graphic => ["Forest"],
    :secretPower => :WOODHAMMER,
    :naturePower => :WOODHAMMER,
    :mimicry => :GRASS,
    :damageMods => {
      0.5 => [:SURF, :MUDDYWATER],
      1.5 => [:ATTACKORDER, :ELECTROWEB, :CUT],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The forest softened the attack..." => [:SURF, :MUDDYWATER],
      "They're coming out of the woodwork!" => [:ATTACKORDER],
      "Gossamer and arbor strengthened the attack!" => [:ELECTROWEB],
      "The target was cut down to size!" => [:CUT],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:BUG, :GRASS],
    },
    :typeMessages => {
      "The field strengthened the attack!" => [:BUG],
      "The forestry strengthened the attack!" => [:GRASS],
    },
    :typeCondition => {
      :BUG => "self.pbIsSpecial?(type)",
    },
    :typeEffects => {},
    :changeCondition => {
      :BURNING => "ignitecheck",
    },
    :fieldChange => {
      :BURNING => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE],
    },
    :dontChangeBackup => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE],
    :changeMessage => {
      "The forest caught fire!" => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE],
    },
    :statusMods => [:STICKYWEB, :DEFENDORDER, :GROWTH, :STRENGTHSAP, :HEALORDER, :NATURESMADNESS, :FORESTSCURSE],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => :Protect,
      :duration => :SpikyShield,
      :message => "The Telluric Seed shielded {1} against damage!",
      :animation => :SPIKYSHIELD,
      :stats => {},
    },
  },
  :SUPERHEATED => {
    :name => "Super-Heated Field",
    :fieldAppSwitch => 615,
    :fieldMessage => [
      "The field is super-heated!"
    ],
    :graphic => ["Superheated"],
    :secretPower => :FLAMEBURST,
    :naturePower => :HEATWAVE,
    :mimicry => :FIRE,
    :damageMods => {
      0.5 => [:SURF, :MUDDYWATER, :WATERPLEDGE, :WATERSPOUT, :SPARKLINGARIA, :HYDROVORTEX, :OCEANICOPERETTA],
      1.5 => [:SCALD, :STEAMERUPTION],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The field super-heated the attack!" => [:SCALD, :STEAMERUPTION],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {
      "@battle.fieldAccuracyDrop" => [:SURF, :MUDDYWATER, :WATERPLEDGE, :WATERSPOUT, :SPARKLINGARIA, :OCEANICOPERETTA, :HYDROVORTEX],
    },
    :typeBoosts => {
      0.5 => [:ICE],
      0.9 => [:WATER],
      1.1 => [:FIRE],
    },
    :typeMessages => {
      "The extreme heat softened the attack..." => [:ICE, :WATER],
      "The attack was super-heated!" => [:FIRE],
    },
    :typeCondition => {
      :WATER => "self.move!=:SCALD && self.move!=:STEAMERUPTION",
    },
    :typeEffects => {},
    :changeCondition => {
      :BURNING => "ignitecheck",
    },
    :fieldChange => {
      :BURNING => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE, :SELFDESTRUCT, :EXPLOSION],
      :INDOOR => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
    },
    :dontChangeBackup => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE, :SELFDESTRUCT, :EXPLOSION],
    :changeMessage => {
      "The field combusted!" => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE, :SELFDESTRUCT, :EXPLOSION],
      "The field cooled off!" => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
    },
    :statusMods => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => :ShellTrap,
      :duration => true,
      :message => "{1} primed a trap!",
      :animation => "ShellTrap",
      :stats => {
        PBStats::DEFENSE => 1,
      },
    },
  },
  :FACTORY => {
    :name => "Factory Field",
    :fieldAppSwitch => 616,
    :fieldMessage => [
      "Machines whir in the background."
    ],
    :graphic => ["Factory"],
    :secretPower => :MAGNETBOMB,
    :naturePower => :GEARGRIND,
    :mimicry => :STEEL,
    :damageMods => {
      1.5 => [:STEAMROLLER, :TECHNOBLAST],
      2.0 => [:FLASHCANNON, :GYROBALL, :MAGNETBOMB, :GEARGRIND],
    },
    :accuracyMods => {},
    :moveMessages => {
      "ATTACK SEQUENCE UPDATE." => [:STEAMROLLER, :TECHNOBLAST],
      "ATTACK SEQUENCE INITIATE." => [:FLASHCANNON, :GYROBALL, :MAGNETBOMB, :GEARGRIND],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:ELECTRIC],
    },
    :typeMessages => {
      "The attack took energy from the field!" => [:ELECTRIC],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :SHORTCIRCUIT => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE, :SELFDESTRUCT, :EXPLOSION, :LIGHTTHATBURNSTHESKY, :DISCHARGE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The field was broken!" => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE, :SELFDESTRUCT, :EXPLOSION],
      "All the light was consumed!" => [:LIGHTTHATBURNSTHESKY],
      "The field shorted out!" => [:DISCHARGE],
    },
    :statusMods => [:AUTOTOMIZE, :IRONDEFENSE, :METALSOUND, :SHIFTGEAR, :MAGNETRISE, :GEARUP],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :LaserFocus,
      :duration => 2,
      :message => "{1} is focused!",
      :animation => :LASERFOCUS,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },
  :SHORTCIRCUIT => {
    :name => "Short-Circuit Field",
    :fieldAppSwitch => 617,
    :fieldMessage => [
      "Bzzt!"
    ],
    :graphic => ["Shortcircuit"],
    :secretPower => :ELECTROBALL,
    :naturePower => :DISCHARGE,
    :mimicry => :ELECTRIC,
    :damageMods => {
      1.5 => [:DAZZLINGGLEAM, :SURF, :MUDDYWATER, :MAGNETBOMB, :GYROBALL, :FLASHCANNON, :GEARGRIND, :HYDROVORTEX],
      1.3 => [:DARKPULSE, :NIGHTDAZE, :NIGHTSLASH, :SHADOWBALL, :SHADOWPUNCH, :SHADOWCLAW, :SHADOWSNEAK, :SHADOWFORCE, :SHADOWBONE],
      0.5 => [:LIGHTTHATBURNSTHESKY],
    },
    :accuracyMods => {
      80 => [:ZAPCANNON],
    },
    :moveMessages => {
      "Blinding!" => [:DAZZLINGGLEAM],
      "The attack picked up electricity!" => [:SURF, :MUDDYWATER, :MAGNETBOMB, :GYROBALL, :FLASHCANNON, :GEARGRIND, :HYDROVORTEX],
      "The darkness strengthened the attack!" => [:DARKPULSE, :NIGHTDAZE, :NIGHTSLASH, :SHADOWBALL, :SHADOWPUNCH, :SHADOWCLAW, :SHADOWSNEAK, :SHADOWFORCE, :SHADOWBONE],
      "{1} couldn't consume much light..." => [:LIGHTTHATBURNSTHESKY],
    },
    :typeMods => {
      :ELECTRIC => [:SURF, :MUDDYWATER, :MAGNETBOMB, :GYROBALL, :FLASHCANNON, :GEARGRIND],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :FACTORY => [:PARABOLICCHARGE, :WILDCHARGE, :CHARGEBEAM, :IONDELUGE, :GIGAVOLTHAVOC, :DISCHARGE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "SYSTEM ONLINE." => [:PARABOLICCHARGE, :WILDCHARGE, :CHARGEBEAM, :IONDELUGE, :GIGAVOLTHAVOC, :DISCHARGE],
    },
    :statusMods => [:FLASH, :METALSOUND, :MAGNETRISE],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :MagnetRise,
      :duration => 5,
      :message => "{1} levitated with electromagnetism!",
      :animation => :MAGNETRISE,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },
  :WASTELAND => {
    :name => "Wasteland",
    :fieldAppSwitch => 618,
    :fieldMessage => [
      "The waste is watching..."
    ],
    :graphic => ["Wasteland"],
    :secretPower => :GUNKSHOT,
    :naturePower => :GUNKSHOT,
    :mimicry => :POISON,
    :damageMods => {
      1.5 => [:VINEWHIP, :POWERWHIP, :MUDSLAP, :MUDBOMB, :MUDSHOT],
      0.25 => [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE],
      2.0 => [:SPITUP],
      1.2 => [:OCTAZOOKA, :SLUDGE, :GUNKSHOT, :SLUDGEWAVE, :SLUDGEBOMB],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The waste did it for the vine!" => [:VINEWHIP, :POWERWHIP],
      "The waste was added to the attack!" => [:MUDSLAP, :MUDBOMB, :MUDSHOT],
      "Wibble-wibble wobble-wobb..." => [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE],
      "BLEAAARGGGGH!" => [:SPITUP],
      "The waste joined the attack!" => [:OCTAZOOKA, :SLUDGE, :GUNKSHOT, :SLUDGEWAVE, :SLUDGEBOMB],
    },
    :typeMods => {
      :POISON => [:MUDBOMB, :MUDSLAP, :MUDSHOT],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusMods => [:SWALLOW, :STEALTHROCK, :SPIKES, :TOXICSPIKES, :STICKYWEB],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::ATTACK => 1,
        PBStats::SPATK => 1,
      },
    },
  },
  :ASHENBEACH => {
    :name => "Ashen Beach",
    :fieldAppSwitch => 619,
    :fieldMessage => [
      "Ash and sand line the field."
    ],
    :graphic => ["AshenBeach"],
    :secretPower => :MUDSHOT,
    :naturePower => :MEDITATE,
    :mimicry => :GROUND,
    :damageMods => {
      1.5 => [:HIDDENPOWER, :STRENGTH, :LANDSWRATH, :THOUSANDWAVES, :SURF, :MUDDYWATER, :CLANGOROUSSOULBLAZE],
      2.0 => [:MUDSLAP, :MUDSHOT, :MUDBOMB, :SANDTOMB],
      1.3 => [:STOREDPOWER, :ZENHEADBUTT, :FOCUSBLAST, :AURASPHERE],
      1.2 => [:PSYCHIC],
    },
    :accuracyMods => {
      90 => [:FOCUSBLAST],
    },
    :moveMessages => {
      "...And with pure focus!" => [:HIDDENPOWER, :STRENGTH, :CLANGOROUSSOULBLAZE],
      "The sand strengthened the atttack!" => [:LANDSWRATH, :THOUSANDWAVES],
      "Surf's up!" => [:SURF, :MUDDYWATER],
      "Ash mixed into the attack!" => [:MUDSLAP, :MUDSHOT, :MUDBOMB, :SANDTOMB],
      "...And with full focus...!" => [:STOREDPOWER, :ZENHEADBUTT, :FOCUSBLAST, :AURASPHERE],
      "...And with focus...!" => [:PSYCHIC],
    },
    :typeMods => {
      :PSYCHIC => [:STRENGTH],
    },
    :typeAddOns => {},
    :moveEffects => {
      "@battle.fieldAccuracyDrop" => [:LEAFTORNADO, :FIRESPIN, :TWISTER, :RAZORWIND, :WHIRLPOOL],
    },
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {
      :FLYING => "self.pbIsSpecial?(type)",
    },
    :typeEffects => {
      :FLYING => "@battle.fieldAccuracyDrop",
    },
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusMods => [:CALMMIND, :KINESIS, :MEDITATE, :SANDATTACK, :SANDSTORM, :FOCUSENERGY, :SHOREUP],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => :FocusEnergy,
      :duration => 3,
      :message => "{1}'s Telluric Seed is getting it pumped!",
      :animation => :FOCUSENERGY,
      :stats => {},
    },
  },
  :WATERSURFACE => {
    :name => "Water Surface",
    :fieldAppSwitch => 620,
    :fieldMessage => [
      "The water's surface is calm."
    ],
    :graphic => ["WaterSurface"],
    :secretPower => :AQUAJET,
    :naturePower => :WHIRLPOOL,
    :mimicry => :WATER,
    :damageMods => {
      1.5 => [:SURF, :MUDDYWATER, :WHIRLPOOL, :DIVE, :HYDROVORTEX],
      0 => [:SPIKES, :TOXICSPIKES],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The attack rode the current!" => [:SURF, :MUDDYWATER, :WHIRLPOOL, :DIVE, :HYDROVORTEX],
      "Poison spread through the water!" => [:SLUDGEWAVE],
      "...The spikes sank into the water and vanished!" => [:SPIKES, :TOXICSPIKES],
    },
    :typeMods => {},
    :typeAddOns => {},
    :fieldCounterIncreases => {
      [1, 1] => [:SLUDGEWAVE],
      [1, 2] => [:ACIDDOWNPOUR],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:WATER, :ELECTRIC],
      0.5 => [:FIRE],
      0 => [:GROUND],
    },
    :typeMessages => {
      "The water conducted the attack!" => [:ELECTRIC],
      "The water strengthened the attack!" => [:WATER],
      "The water deluged the attack..." => [:FIRE],
      "...But there was no solid ground to attack from!" => [:GROUND],
    },
    :typeCondition => {
      :FIRE => "!opponent.isAirborne?",
      :ELECTRIC => "!opponent.isAirborne?",
    },
    :typeEffects => {},
    :changeCondition => {
      :MURKWATERSURFACE => "@battle.field.counter > 1",
    },
    :fieldChange => {
      :UNDERWATER => [:GRAVITY, :DIVE],
      :ICY => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
      :MURKWATERSURFACE => [:SLUDGEWAVE, :ACIDDOWNPOUR],
    },
    :dontChangeBackup => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
    :changeMessage => {
      "The battle sank into the depths!" => [:GRAVITY],
      "The battle was pulled underwater!" => [:DIVE],
      "The water froze over!" => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
      "The water was polluted!" => [:SLUDGEWAVE, :ACIDDOWNPOUR],
    },
    :statusMods => [:SPLASH, :AQUARING],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => :AquaRing,
      :duration => true,
      :message => "{1} surrounded itself with a veil of water!",
      :animation => :AQUARING,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },
  :UNDERWATER => {
    :name => "Underwater",
    :fieldAppSwitch => 621,
    :fieldMessage => [
      "Blub blub..."
    ],
    :graphic => ["Underwater"],
    :secretPower => :AQUATAIL,
    :naturePower => :WATERPULSE,
    :mimicry => :WATER,
    :damageMods => {
      1.5 => [:WATERPULSE],
      2.0 => [:ANCHORSHOT],
      0 => [:SUNNYDAY, :HAIL, :SANDSTORM, :RAINDANCE],
    },
    :accuracyMods => {},
    :moveMessages => {
      "Jet-streamed!" => [:WATERPULSE],
      "From the depths!" => [:ANCHORSHOT],
      "Poison spread through the water!" => [:SLUDGEWAVE],
      "You're too deep to notice the weather!" => [:SUNNYDAY, :HAIL, :SANDSTORM, :RAINDANCE],
    },
    :typeMods => {},
    :typeAddOns => {
      :WATER => [:GROUND],
    },
    :fieldCounterIncreases => {
      [1, 1] => [:SLUDGEWAVE],
      [1, 2] => [:ACIDDOWNPOUR],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:WATER],
      2.0 => [:ELECTRIC],
      0 => [:FIRE],
    },
    :typeMessages => {
      "The water strengthened the attack!" => [:WATER],
      "The water super-conducted the attack!" => [:ELECTRIC],
      "...But the attack was doused instantly!" => [:FIRE],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :MURKWATERSURFACE => "@battle.field.counter > 1",
    },
    :fieldChange => {
      :WATERSURFACE => [:DIVE, :SKYDROP, :FLY, :BOUNCE],
      :MURKWATERSURFACE => [:SLUDGEWAVE, :ACIDDOWNPOUR],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The battle resurfaced!" => [:DIVE, :SKYDROP, :FLY, :BOUNCE],
      "The grime sank beneath the battlers!" => [:SLUDGEWAVE, :ACIDDOWNPOUR],
    },
    :statusMods => [:AQUARING],
    :changeEffects => {
      "@battle.waterPollution" => [:SLUDGEWAVE, :ACIDDOWNPOUR],
    },
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => nil,
      :duration => 0,
      :message => "{1} transformed into the Water type!",
      :animation => :SOAK,
      :stats => {
        PBStats::SPEED => 1,
      },
    },
  },
  :CAVE => {
    :name => "Cave",
    :fieldAppSwitch => 622,
    :fieldMessage => [
      "The cave echoes dully..."
    ],
    :graphic => ["Cave"],
    :secretPower => :ROCKWRECKER,
    :naturePower => :ROCKTOMB,
    :mimicry => :ROCK,
    :damageMods => {
      1.5 => [:ROCKTOMB],
      0 => [:SKYDROP],
    },
    :accuracyMods => {},
    :moveMessages => {
      "...Piled on!" => [:ROCKTOMB],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {
      "@battle.caveCollapse(basemove, user)" => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE, :CONTINENTALCRUSH],
    },
    :typeBoosts => {
      1.5 => [:ROCK],
      0.5 => [:FLYING],
    },
    :typeMessages => {
      "The cave choked out the air!" => [:FLYING],
      "The cavern strengthened the attack!" => [:ROCK],
    },
    :typeCondition => {
      :FLYING => "!self.contactMove?",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :CRYSTALCAVERN => [:POWERGEM, :DIAMONDSTORM],
    },
    :dontChangeBackup => [:POWERGEM, :DIAMONDSTORM],
    :changeMessage => {
      "The cave was littered with crystals!" => [:POWERGEM, :DIAMONDSTORM],
    },
    :statusMods => [:STEALTHROCK],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::DEFENSE => 2,
      },
    },
  },
  :GLITCH => {
    :name => "Glitch Field",
    :fieldAppSwitch => 623,
    :fieldMessage => [
      "1n!taliz3 .b//////attl3"
    ],
    :graphic => ["Glitch", "Glitch2"],
    :secretPower => :TECHNOBLAST,
    :naturePower => :METRONOME,
    :mimicry => :QMARKS,
    :damageMods => {
      # is rejuv thing
      # 0 => [:ROAR, :WHIRLWIND],
    },
    :accuracyMods => {
      90 => [:BLIZZARD],
    },
    :moveMessages => {
      # "ERROR! MOVE NOT FOUND!" => [:ROAR, :WHIRLWIND],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.2 => [:PSYCHIC],
    },
    :typeMessages => {
      ".0P pl$ nerf!-//" => [:PSYCHIC],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusMods => [:METRONOME],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => nil,
      :duration => 0,
      :message => "{1}.TYPE = :QMARKS",
      :animation => :AMNESIA,
      :stats => {
        PBStats::DEFENSE => 1,
      },
    },
  },
  :CRYSTALCAVERN => {
    :name => "Crystal Cavern",
    :fieldAppSwitch => 624,
    :fieldMessage => [
      "The cave is littered with crystals."
    ],
    :graphic => ["CrystalCavern"],
    :secretPower => :POWERGEM,
    :naturePower => :POWERGEM,
    :mimicry => :QMARKS,
    :damageMods => {
      1.3 => [:AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :LUSTERPURGE, :DAZZLINGGLEAM, :MIRRORSHOT, :TECHNOBLAST, :DOOMDUMMY, :MOONGEISTBEAM, :PHOTONGEYSER, :MENACINGMOONRAZEMAELSTROM],
      1.5 => [:POWERGEM, :DIAMONDSTORM, :ANCIENTPOWER, :JUDGMENT, :ROCKSMASH, :ROCKTOMB, :STRENGTH, :ROCKCLIMB, :MULTIATTACK],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The crystals' light strengthened the attack!" => [:AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :LUSTERPURGE, :DAZZLINGGLEAM, :MIRRORSHOT, :TECHNOBLAST, :DOOMDUMMY, :MOONGEISTBEAM, :PHOTONGEYSER, :MENACINGMOONRAZEMAELSTROM],
      "The crystals strengthened the attack!" => [:POWERGEM, :DIAMONDSTORM, :ANCIENTPOWER, :JUDGMENT, :ROCKSMASH, :ROCKTOMB, :STRENGTH, :ROCKCLIMB, :MULTIATTACK],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:ROCK, :DRAGON],
    },
    :typeMessages => {
      "The crystals charged the attack!" => [:ROCK],
      "The crystal energy strengthened the attack!" => [:DRAGON],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :CAVE => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE],
      :DARKCRYSTALCAVERN => [:DARKPULSE, :DARKVOID, :NIGHTDAZE, :LIGHTTHATBURNSTHESKY],
    },
    :dontChangeBackup => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE, :DARKPULSE, :DARKVOID, :NIGHTDAZE],
    :changeMessage => {
      "The crystals were broken up!" => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE],
      "The crystals' light was warped by the darkness!" => [:DARKPULSE, :DARKVOID, :NIGHTDAZE],
      "The crystals' light was consumed!" => [:LIGHTTHATBURNSTHESKY],
    },
    :statusMods => [:ROCKPOLISH, :STEALTHROCK],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => :MagicCoat,
      :duration => true,
      :message => "{1} shrouded itself with Magic Coat!",
      :animation => :MAGICCOAT,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },
  :MURKWATERSURFACE => {
    :name => "Murkwater Surface",
    :fieldAppSwitch => 625,
    :fieldMessage => [
      "The water is tainted..."
    ],
    :graphic => ["MurkwaterSurface"],
    :secretPower => :SLUDGEBOMB,
    :naturePower => :SLUDGEWAVE,
    :mimicry => :POISON,
    :damageMods => {
      1.5 => [:MUDBOMB, :MUDSLAP, :MUDSHOT, :SMACKDOWN, :ACID, :ACIDSPRAY, :BRINE, :THOUSANDWAVES],
      0 => [:SPIKES, :TOXICSPIKES],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The toxic water strengthened the attack!" => [:MUDBOMB, :MUDSLAP, :MUDSHOT, :SMACKDOWN, :ACID, :ACIDSPRAY, :THOUSANDWAVES],
      "Stinging!" => [:BRINE],
      "...The spikes sank into the water and vanished!" => [:SPIKES, :TOXICSPIKES],
    },
    :typeMods => {
      :POISON => [:MUDBOMB, :MUDSLAP, :MUDSHOT, :SMACKDOWN, :THOUSANDWAVES],
      :WATER => [:SLUDGEWAVE],
    },
    :typeAddOns => {
      :POISON => [:WATER],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:WATER, :POISON],
      1.3 => [:ELECTRIC],
      0 => [:GROUND],
    },
    :typeMessages => {
      "The toxic water strengthened the attack!" => [:WATER, :POISON],
      "The toxic water conducted the attack!" => [:ELECTRIC],
      "...But there was no solid ground to attack from!" => [:GROUND],
    },
    :typeCondition => {
      :ELECTRIC => "!opponent.isAirborne?",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :WATERSURFACE => [:WHIRLPOOL],
      :ICY => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
    },
    :dontChangeBackup => [:WHIRLPOOL, :BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
    :changeMessage => {
      "The maelstrom flushed out the poison!" => [:WHIRLPOOL],
      "The toxic water froze over!" => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
    },
    :statusMods => [:ACIDARMOR],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => :AquaRing,
      :duration => true,
      :message => "{1} surrounded itself with a veil of water!",
      :animation => :AQUARING,
      :stats => {
        PBStats::SPEED => 1,
      },
    },
  },
  :MOUNTAIN => {
    :name => "Mountain",
    :fieldAppSwitch => 626,
    :fieldMessage => [
      "Adieu to disappointment and spleen,",
      "What are men to rocks and mountains?",
    ],
    :graphic => ["Mountain"],
    :secretPower => :ROCKBLAST,
    :naturePower => :ROCKSLIDE,
    :mimicry => :ROCK,
    :damageMods => {
      1.5 => [:VITALTHROW, :CIRCLETHROW, :STORMTHROW, :OMINOUSWIND, :ICYWIND, :SILVERWIND, :TWISTER, :RAZORWIND,
              :FAIRYWIND, :THUNDER, :ERUPTION, :AVALANCHE, :HYPERVOICE],
    },
    :accuracyMods => {
      0 => [:THUNDER],
    },
    :moveMessages => {
      "{1} was thrown partway down the mountain!" => [:VITALTHROW, :CIRCLETHROW, :STORMTHROW],
      "The wind strengthened the attack!" => [:OMINOUSWIND, :ICYWIND, :SILVERWIND, :TWISTER, :RAZORWIND, :FAIRYWIND],
      "The mountain strengthened the attack!" => [:THUNDER, :ERUPTION, :AVALANCHE],
      "Yodelayheehoo~" => [:HYPERVOICE],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:ROCK, :FLYING],
    },
    :typeMessages => {
      "The mountain strengthened the attack!" => [:ROCK],
      "The open air strengthened the attack!" => [:FLYING],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :SNOWYMOUNTAIN => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
    },
    :dontChangeBackup => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
    :changeMessage => {
      "The mountain was covered in snow!" => [:BLIZZARD, :GLACIATE, :SUBZEROSLAMMER],
    },
    :statusMods => [:TAILWIND, :SUNNYDAY],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::ATTACK => 2,
        PBStats::ACCURACY => -1,
      },
    },
  },
  :SNOWYMOUNTAIN => {
    :name => "Snowy Mountain",
    :fieldAppSwitch => 627,
    :fieldMessage => [
      "The snow glows white on the mountain..."
    ],
    :graphic => ["SnowyMountain"],
    :secretPower => :ICEBALL,
    :naturePower => :AVALANCHE,
    :mimicry => :ICE,
    :damageMods => {
      1.5 => [:VITALTHROW, :CIRCLETHROW, :STORMTHROW, :OMINOUSWIND, :SILVERWIND, :TWISTER, :RAZORWIND, :FAIRYWIND,
              :AVALANCHE, :POWDERSNOW, :HYPERVOICE, :GLACIATE],
      0.5 => [:SCALD, :STEAMERUPTION],
      2.0 => [:ICYWIND],
    },
    :accuracyMods => {
      0 => [:THUNDER],
    },
    :moveMessages => {
      "{1} was thrown partway down the mountain!" => [:VITALTHROW, :CIRCLETHROW, :STORMTHROW],
      "The wind strengthened the attack!" => [:OMINOUSWIND, :SILVERWIND, :TWISTER, :RAZORWIND, :FAIRYWIND],
      "The snow strengthened the attack!" => [:AVALANCHE, :POWDERSNOW],
      "The cold softened the attack..." => [:SCALD, :STEAMERUPTION],
      "The frigid wind strengthened the attack!" => [:ICYWIND],
      "Yodelayheehoo~" => [:HYPERVOICE],
    },
    :typeMods => {},
    :typeAddOns => {
      :ICE => [:ROCK],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:ROCK, :ICE, :FLYING],
      0.5 => [:FIRE],
    },
    :typeMessages => {
      "The snowy mountain strengthened the attack!" => [:ROCK, :ICE],
      "The open air strengthened the attack!" => [:FLYING],
      "The cold softened the attack!" => [:FIRE],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :MOUNTAIN => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The snow melted away!" => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE],
    },
    :statusMods => [:TAILWIND, :SUNNYDAY, :HAIL],
    :changeEffects => {},
    :seed => {
      :seedtype => :TELLURICSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::SPATK => 2,
        PBStats::ACCURACY => -1,
      },
    },
  },
  :HOLY => {
    :name => "Holy Field",
    :fieldAppSwitch => 628,
    :fieldMessage => [
      "Benedictus Sanctus Spiritus..."
    ],
    :graphic => ["Holy"],
    :secretPower => :DAZZLINGGLEAM,
    :naturePower => :JUDGMENT,
    :mimicry => :NORMAL,
    :damageMods => {
      1.3 => [
        :PSYSTRIKE, :AEROBLAST, :ORIGINPULSE, :DOOMDUMMY, :MISTBALL, :CRUSHGRIP, :LUSTERPURGE, :SECRETSWORD,
        :PSYCHOBOOST, :RELICSONG, :SPACIALREND, :HYPERSPACEHOLE, :ROAROFTIME, :LANDSWRATH, :PRECIPICEBLADES,
        :DRAGONASCENT, :MOONGEISTBEAM, :SUNSTEELSTRIKE, :PRISMATICLASER, :FLEURCANNON, :DIAMONDSTORM, :GENESISSUPERNOVA,
        :SEARINGSUNRAZESMASH, :MENACINGMOONRAZEMAELSTROM, :VCREATE,
      ],
      1.5 => [:MYSTICALFIRE, :MAGICALLEAF, :ANCIENTPOWER, :JUDGMENT, :SACREDFIRE, :EXTREMESPEED, :SACREDSWORD, :RETURN],
    },
    :accuracyMods => {},
    :moveMessages => {
      "Legendary power accelerated the attack!" => [
        :PSYSTRIKE, :AEROBLAST, :SACREDFIRE, :ORIGINPULSE, :DOOMDUMMY, :JUDGMENT, :MISTBALL, :CRUSHGRIP,
        :LUSTERPURGE, :SECRETSWORD, :PSYCHOBOOST, :RELICSONG, :SPACIALREND, :HYPERSPACEHOLE, :ROAROFTIME,
        :LANDSWRATH, :PRECIPICEBLADES, :DRAGONASCENT, :MOONGEISTBEAM, :SUNSTEELSTRIKE, :PRISMATICLASER,
        :FLEURCANNON, :DIAMONDSTORM, :GENESISSUPERNOVA, :SEARINGSUNRAZESMASH, :MENACINGMOONRAZEMAELSTROM, :VCREATE,
      ],
      "The holy energy resonated with the attack!" => [:MYSTICALFIRE, :MAGICALLEAF, :ANCIENTPOWER, :SACREDSWORD, :RETURN],
      "Godspeed!" => [:EXTREMESPEED],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:FAIRY, :NORMAL],
      1.2 => [:PSYCHIC, :DRAGON],
      0.5 => [:GHOST, :DARK],
    },
    :typeMessages => {
      "The holy energy resonated with the attack!" => [:FAIRY, :NORMAL],
      "The legendary energy resonated with the attack!" => [:PSYCHIC, :DRAGON],
      "The attack was cleansed..." => [:GHOST, :DARK],
    },
    :typeCondition => {
      :FAIRY => "self.pbIsSpecial?(type)",
      :NORMAL => "self.pbIsSpecial?(type)",
      :DARK => "self.pbIsSpecial?(type)",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :INDOOR => [:LIGHTTHATBURNSTHESKY],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The holy light was consumed!" => [:LIGHTTHATBURNSTHESKY],
    },
    :statusMods => [:WISH, :MIRACLEEYE, :COSMICPOWER, :NATURESMADNESS],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => :MagicCoat,
      :duration => true,
      :message => "{1} shrouded itself with Magic Coat!",
      :animation => :MAGICCOAT,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },
  :MIRROR => {
    :name => "Mirror Arena",
    :fieldAppSwitch => 629,
    :fieldMessage => [
      "Mirror, mirror, on the field,",
      "Who shalt this fractured power wield?",
    ],
    :graphic => ["Mirror"],
    :secretPower => :MIRRORSHOT,
    :naturePower => :MIRRORSHOT,
    :mimicry => :STEEL,
    :damageMods => {
      1.5 => [:AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :LUSTERPURGE, :DAZZLINGGLEAM, :TECHNOBLAST, :DOOMDUMMY,
              :PRISMATICLASER, :PHOTONGEYSER, :LIGHTTHATBURNSTHESKY],
      2.0 => [:MIRRORSHOT],
    },
    :accuracyMods => {
      0 => [:AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :LUSTERPURGE, :DAZZLINGGLEAM, :TECHNOBLAST, :DOOMDUMMY,
            :PRISMATICLASER, :PHOTONGEYSER, :LIGHTTHATBURNSTHESKY, :MIRRORSHOT],
    },
    :moveMessages => {
      "The reflected light was blinding!" => [:AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :LUSTERPURGE, :DAZZLINGGLEAM, :TECHNOBLAST, :DOOMDUMMY, :PRISMATICLASER, :PHOTONGEYSER, :LIGHTTHATBURNSTHESKY],
      "The mirrors strengthened the attack!" => [:MIRRORSHOT],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :INDOOR => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE, :BOOMBURST, :HYPERVOICE, :SELFDESTRUCT, :EXPLOSION],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The mirror arena shattered!" => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE, :BOOMBURST, :HYPERVOICE, :SELFDESTRUCT, :EXPLOSION],
    },
    :statusMods => [:LIGHTSCREEN, :AURORAVEIL, :REFLECT, :MIRRORMOVE, :MIRRORCOAT, :DOUBLETEAM, :FLASH],
    :changeEffects => {
      "@battle.mirrorShatter(basemove, user)" => [:EARTHQUAKE, :BULLDOZE, :MAGNITUDE, :FISSURE, :TECTONICRAGE, :BOOMBURST, :HYPERVOICE, :SELFDESTRUCT, :EXPLOSION],
    },
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :MagicCoat,
      :duration => true,
      :message => "{1} shrouded itself with Magic Coat!",
      :animation => :MAGICCOAT,
      :stats => {
        PBStats::EVASION => 1,
      },
    },
  },
  :FAIRYTALE => {
    :name => "Fairy Tale Field",
    :fieldAppSwitch => 630,
    :fieldMessage => [
      "Once upon a time..."
    ],
    :graphic => ["FairyTale"],
    :secretPower => :SLASH,
    :naturePower => :SECRETSWORD,
    :mimicry => :FAIRY,
    :damageMods => {
      1.5 => [:NIGHTSLASH, :LEAFBLADE, :PSYCHOCUT, :SMARTSTRIKE, :AIRSLASH, :SOLARBLADE, :MAGICALLEAF, :MYSTICALFIRE,
              :ANCIENTPOWER, :RELICSONG, :SPARKLINGARIA, :MOONGEISTBEAM, :FLEURCANNON, :OCEANICOPERETTA, :MENACINGMOONRAZEMAELSTROM],
      2.0 => [:DRAININGKISS],
    },
    :accuracyMods => {},
    :moveMessages => {
      "The blade cuts true!" => [:NIGHTSLASH, :LEAFBLADE, :PSYCHOCUT, :SMARTSTRIKE, :AIRSLASH, :SOLARBLADE],
      "The magical energy strengthened the attack!" => [:MAGICALLEAF, :MYSTICALFIRE, :ANCIENTPOWER, :RELICSONG, :SPARKLINGARIA, :MOONGEISTBEAM, :FLEURCANNON, :OCEANICOPERETTA, :MENACINGMOONRAZEMAELSTROM],
      "True love never hurt so badly!" => [:DRAININGKISS],
    },
    :typeMods => {},
    :typeAddOns => {
      :DRAGON => [:FIRE],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:STEEL, :FAIRY],
      2.0 => [:DRAGON],
    },
    :typeMessages => {
      "For ever after!" => [:FAIRY],
      "For justice!" => [:STEEL],
      "The foul beast's attack gained strength!" => [:DRAGON],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusMods => [:KINGSSHIELD, :SPIKYSHIELD, :CRAFTYSHIELD, :FLOWERSHIELD, :ACIDARMOR, :NOBLEROAR, :SWORDSDANCE, :WISH, :HEALINGWISH, :MIRACLEEYE, :FORESTSCURSE, :FLORALHEALING],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => :Protect,
      :duration => :KingsShield,
      :message => "The Magical Seed shielded {1} against damage!",
      :animation => :KINGSSHIELD,
      :stats => {},
    },
  },
  :DRAGONSDEN => {
    :name => "Dragon's Den",
    :fieldAppSwitch => 631,
    :fieldMessage => [
      "If you wish to slay a dragon..."
    ],
    :graphic => ["DragonsDen"],
    :secretPower => :DRAGONPULSE,
    :naturePower => :DRAGONPULSE,
    :mimicry => :DRAGON,
    :damageMods => {
      1.5 => [:MEGAKICK, :MAGMASTORM, :LAVAPLUME],
      2.0 => [:SMACKDOWN, :THOUSANDARROWS, :DRAGONASCENT, :PAYDAY, :TECTONICRAGE, :CONTINENTALCRUSH],
    },
    :accuracyMods => {},
    :moveMessages => {
      "Trial of the Dragon!!!" => [:MEGAKICK],
      "The lava strengthened the attack!" => [:MAGMASTORM, :LAVAPLUME],
      "{1} was knocked into the lava!" => [:SMACKDOWN, :THOUSANDARROWS],
      "The draconic energy boosted the attack!" => [:DRAGONASCENT],
      "money money money money money mothafucka" => [:PAYDAY],
    },
    :typeMods => {
      :FIRE => [:SMACKDOWN, :THOUSANDARROWS, :TECTONICRAGE, :CONTINENTALCRUSH],
    },
    :typeAddOns => {},
    :fieldCounterIncreases => {
      [1, 1] => [:MUDDYWATER, :SURF, :SPARKLINGARIA],
      [1, 2] => [:GLACIATE, :SUBZEROSLAMMER, :OCEANICOPERETTA, :HYDROVORTEX],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:DRAGON, :FIRE],
      0.5 => [:ICE, :WATER],
    },
    :typeMessages => {
      "The lava's heat boosted the flame!" => [:FIRE],
      "The draconic energy boosted the attack!" => [:DRAGON],
      "The lava's heat softened the attack..." => [:ICE, :WATER],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :CAVE => "@battle.field.counter > 1",
    },
    :fieldChange => {
      :CAVE => [:MUDDYWATER, :SURF, :SPARKLINGARIA, :GLACIATE, :SUBZEROSLAMMER, :OCEANICOPERETTA, :HYDROVORTEX],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The lava was frozen solid!" => [:GLACIATE, :SUBZEROSLAMMER],
      "The lava solidified!" => [:MUDDYWATER, :SURF, :SPARKLINGARIA, :OCEANICOPERETTA, :HYDROVORTEX],
    },
    :statusMods => [:DRAGONDANCE, :NOBLEROAR],
    :changeEffects => {},
    :seed => {
      :seedtype => :ELEMENTALSEED,
      :effect => :FlashFire,
      :duration => true,
      :message => "{1} raised its Fire power!",
      :animation => nil,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },
  :FLOWERGARDEN1 => {
    :name => "Flower Garden Field",
    :fieldAppSwitch => 632,
    :fieldMessage => [
      "Seeds line the field."
    ],
    :graphic => ["FlowerGarden0"],
    :secretPower => :SWEETSCENT,
    :naturePower => :GROWTH,
    :mimicry => :GRASS,
    :damageMods => {},
    :accuracyMods => {},
    :moveMessages => {},
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :FLOWERGARDEN2 => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :WATERSPORT, :BLOOMDOOM],
    },
    :dontChangeBackup => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :WATERSPORT, :BLOOMDOOM],
    :changeMessage => {
      "The garden grew a little!" => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :WATERSPORT],
    },
    :statusMods => [:GROWTH, :ROTOTILLER, :RAINDANCE, :WATERSPORT, :SUNNYDAY, :FLOWERSHIELD, :SWEETSCENT, :INGRAIN, :FLORALHEALING],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :Ingrain,
      :duration => true,
      :message => "{1} planted its roots!",
      :animation => :INGRAIN,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },
  :FLOWERGARDEN2 => {
    :name => "Flower Garden Field",
    :fieldAppSwitch => 632,
    :fieldMessage => [
      "Seeds line the field."
    ],
    :graphic => ["FlowerGarden1"],
    :secretPower => :PETALBLIZZARD,
    :naturePower => :GROWTH,
    :mimicry => :GRASS,
    :damageMods => {
      1.5 => [:CUT],
    },
    :accuracyMods => {},
    :moveMessages => {
      "{1} was cut down to size!" => [:CUT],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.1 => [:GRASS],
    },
    :typeMessages => {
      "The garden's power boosted the attack!" => [:GRASS],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :FLOWERGARDEN3 => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :WATERSPORT, :BLOOMDOOM],
      :FLOWERGARDEN1 => [:CUT, :XSCISSOR, :ACIDDOWNPOUR],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The garden was cut down a bit!" => [:CUT, :XSCISSOR],
      "The garden grew a little!" => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :WATERSPORT],
      "The acid melted the bloom!" => [:ACIDDOWNPOUR],
    },
    :statusMods => [:GROWTH, :ROTOTILLER, :RAINDANCE, :WATERSPORT, :SUNNYDAY, :FLOWERSHIELD, :SWEETSCENT, :INGRAIN, :FLORALHEALING],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :Ingrain,
      :duration => true,
      :message => "{1} planted its roots!",
      :animation => :INGRAIN,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },
  :FLOWERGARDEN3 => {
    :name => "Flower Garden Field",
    :fieldAppSwitch => 632,
    :fieldMessage => [
      "Seeds line the field."
    ],
    :graphic => ["FlowerGarden2"],
    :secretPower => :PETALBLIZZARD,
    :naturePower => :GROWTH,
    :mimicry => :GRASS,
    :damageMods => {
      1.5 => [:CUT],
      1.2 => [:PETALBLIZZARD, :PETALDANCE, :FLEURCANNON],
    },
    # :accuracyMods => {
    # 85 => [:SLEEPPOWDER, :STUNSPORE, :POISONPOWDER],
    # },
    :accuracyMods => {},
    :moveMessages => {
      "{1} was cut down to size!" => [:CUT],
      "The fresh scent of flowers boosted the attack!" => [:PETALBLIZZARD, :PETALDANCE, :FLEURCANNON],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:FIRE, :BUG],
      1.3 => [:GRASS],
    },
    :typeMessages => {
      "The budding flowers boosted the attack!" => [:GRASS],
      "The attack infested the garden!" => [:BUG],
      "The nearby flowers caught flame!" => [:FIRE],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :BURNING => "ignitecheck",
    },
    :fieldChange => {
      :FLOWERGARDEN4 => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :WATERSPORT, :BLOOMDOOM],
      :FLOWERGARDEN2 => [:CUT, :XSCISSOR],
      :FLOWERGARDEN1 => [:ACIDDOWNPOUR],
      :BURNING => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The garden caught fire!" => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE],
      "The garden was cut down a bit!" => [:CUT, :XSCISSOR],
      "The garden grew a little!" => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :WATERSPORT],
      "The acid melted the bloom!" => [:ACIDDOWNPOUR],
    },
    :statusMods => [:GROWTH, :ROTOTILLER, :RAINDANCE, :WATERSPORT, :SUNNYDAY, :FLOWERSHIELD, :SWEETSCENT, :INGRAIN, :FLORALHEALING],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :Ingrain,
      :duration => true,
      :message => "{1} planted its roots!",
      :animation => :INGRAIN,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },
  :FLOWERGARDEN4 => {
    :name => "Flower Garden Field",
    :fieldAppSwitch => 632,
    :fieldMessage => [
      "Seeds line the field."
    ],
    :graphic => ["FlowerGarden3"],
    :secretPower => :PETALBLIZZARD,
    :naturePower => :GROWTH,
    :mimicry => :GRASS,
    :damageMods => {
      1.5 => [:CUT, :PETALBLIZZARD, :PETALDANCE, :FLEURCANNON],
    },
    # :accuracyMods => {
    # 85 => [:SLEEPPOWDER, :STUNSPORE, :POISONPOWDER],
    # },
    :accuracyMods => {},
    :moveMessages => {
      "{1} was cut down to size!" => [:CUT],
      "The vibrant aroma scent of flowers boosted the attack!" => [:PETALBLIZZARD, :PETALDANCE, :FLEURCANNON],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      2.0 => [:BUG],
      1.5 => [:FIRE, :GRASS],
    },
    :typeMessages => {
      "The blooming flowers boosted the attack!" => [:GRASS],
      "The attack infested the flowers!" => [:BUG],
      "The nearby flowers caught flame!" => [:FIRE],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :BURNING => "ignitecheck",
    },
    :fieldChange => {
      :FLOWERGARDEN5 => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :WATERSPORT, :BLOOMDOOM],
      :FLOWERGARDEN3 => [:CUT, :XSCISSOR],
      :FLOWERGARDEN1 => [:ACIDDOWNPOUR],
      :BURNING => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The garden caught fire!" => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE],
      "The garden was cut down a bit!" => [:CUT, :XSCISSOR],
      "The garden grew a little!" => [:GROWTH, :FLOWERSHIELD, :RAINDANCE, :SUNNYDAY, :ROTOTILLER, :INGRAIN, :WATERSPORT],
      "The acid melted the bloom!" => [:ACIDDOWNPOUR],
    },
    :statusMods => [:GROWTH, :ROTOTILLER, :RAINDANCE, :WATERSPORT, :SUNNYDAY, :FLOWERSHIELD, :SWEETSCENT, :INGRAIN, :FLORALHEALING],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :Ingrain,
      :duration => true,
      :message => "{1} planted its roots!",
      :animation => :INGRAIN,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },
  :FLOWERGARDEN5 => {
    :name => "Flower Garden Field",
    :fieldAppSwitch => 632,
    :fieldMessage => [
      "Seeds line the field."
    ],
    :graphic => ["FlowerGarden4"],
    :secretPower => :PETALDANCE,
    :naturePower => :PETALBLIZZARD,
    :mimicry => :GRASS,
    :damageMods => {
      1.5 => [:CUT, :PETALBLIZZARD, :PETALDANCE, :FLEURCANNON],
    },
    # :accuracyMods => {
    # 85 => [:SLEEPPOWDER, :STUNSPORE, :POISONPOWDER],
    # },
    :accuracyMods => {},
    :moveMessages => {
      "{1} was cut down to size!" => [:CUT],
      "The vibrant aroma scent of flowers boosted the attack!" => [:PETALBLIZZARD, :PETALDANCE, :FLEURCANNON],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      2.0 => [:GRASS, :BUG],
      1.5 => [:FIRE],
    },
    :typeMessages => {
      "The thriving flowers boosted the attack!" => [:GRASS],
      "The attack infested the flowers!" => [:BUG],
      "The nearby flowers caught flame!" => [:FIRE],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {
      :BURNING => "ignitecheck",
    },
    :fieldChange => {
      :FLOWERGARDEN4 => [:CUT, :XSCISSOR],
      :FLOWERGARDEN1 => [:ACIDDOWNPOUR],
      :BURNING => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The garden caught fire!" => [:HEATWAVE, :ERUPTION, :SEARINGSHOT, :FLAMEBURST, :LAVAPLUME, :FIREPLEDGE, :MINDBLOWN, :INCINERATE, :INFERNOOVERDRIVE],
      "The garden was cut down a bit!" => [:CUT, :XSCISSOR],
      "The acid melted the bloom!" => [:ACIDDOWNPOUR],
    },
    :statusMods => [:GROWTH, :ROTOTILLER, :RAINDANCE, :WATERSPORT, :SUNNYDAY, :FLOWERSHIELD, :SWEETSCENT, :INGRAIN, :FLORALHEALING],
    :changeEffects => {},
    :seed => {
      :seedtype => :SYNTHETICSEED,
      :effect => :Ingrain,
      :duration => true,
      :message => "{1} planted its roots!",
      :animation => :INGRAIN,
      :stats => {
        PBStats::SPDEF => 1,
      },
    },
  },
  :STARLIGHT => {
    :name => "Starlight Arena",
    :fieldAppSwitch => 633,
    :fieldMessage => [
      "Starlight fills the battlefield."
    ],
    :graphic => ["Starlight"],
    :secretPower => :SWIFT,
    :naturePower => :MOONBLAST,
    :mimicry => :DARK,
    :damageMods => {
      1.5 => [:AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :LUSTERPURGE, :DAZZLINGGLEAM, :MIRRORSHOT, :TECHNOBLAST, :SOLARBEAM,
              :PHOTONGEYSER, :MOONBLAST],
      2.0 => [:DRACOMETEOR, :METEORMASH, :COMETPUNCH, :SPACIALREND, :SWIFT, :HYPERSPACEHOLE, :HYPERSPACEFURY,
              :MOONGEISTBEAM, :SUNSTEELSTRIKE, :BLACKHOLEECLIPSE, :SEARINGSUNRAZESMASH, :MENACINGMOONRAZEMAELSTROM],
      4.0 => [:DOOMDUMMY],
    },
    :accuracyMods => {},
    :moveMessages => {
      "Starlight surged through the attack!" => [:AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :LUSTERPURGE, :DAZZLINGGLEAM, :MIRRORSHOT, :TECHNOBLAST, :SOLARBEAM, :PHOTONGEYSER],
      "Lunar energy surged through the attack!" => [:MOONBLAST],
      "The astral energy boosted the attack!" => [:DRACOMETEOR, :METEORMASH, :COMETPUNCH, :SPACIALREND, :SWIFT, :HYPERSPACEFURY, :MOONGEISTBEAM, :SUNSTEELSTRIKE, :BLACKHOLEECLIPSE, :SEARINGSUNRAZESMASH, :MENACINGMOONRAZEMAELSTROM],
      "The astral vortex accelerated the attack!" => [:HYPERSPACEHOLE],
      "A star came crashing down!" => [:DOOMDUMMY],
    },
    :typeMods => {
      :FIRE => [:DOOMDUMMY],
    },
    :typeAddOns => {
      :FAIRY => [:DARK],
    },
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:DARK, :PSYCHIC],
      1.3 => [:FAIRY],
    },
    :typeMessages => {
      "Starlight supercharged the attack!" => [:FAIRY],
      "The night sky boosted the attack!" => [:DARK],
      "The astral energy boosted the attack!" => [:PSYCHIC],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :INDOOR => [:LIGHTTHATBURNSTHESKY],
    },
    :dontChangeBackup => [],
    :changeMessage => {
      "The cosmic light was consumed!" => [:LIGHTTHATBURNSTHESKY],
    },
    :statusMods => [:COSMICPOWER, :FLASH, :WISH, :HEALINGWISH, :LUNARDANCE, :MOONLIGHT],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::SPATK => 1,
      },
    },
  },
  :NEWWORLD => {
    :name => "New World",
    :fieldAppSwitch => 634,
    :fieldMessage => [
      "From darkness, from stardust,",
      "From memories of eons past and visions yet to come...",
    ],
    :graphic => ["NewWorld"],
    :secretPower => :ROAROFTIME,
    :naturePower => :SPACIALREND,
    :mimicry => :QMARKS,
    :damageMods => {
      1.5 => [
        :AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :DAZZLINGGLEAM, :MIRRORSHOT, :PHOTONGEYSER, :PSYSTRIKE, :AEROBLAST,
        :SACREDFIRE, :MISTBALL, :LUSTERPURGE, :ORIGINPULSE, :PRECIPICEBLADES, :DRAGONASCENT, :PSYCHOBOOST, :ROAROFTIME, :MAGMASTORM, :CRUSHGRIP, :JUDGMENT, :SEEDFLARE, :SHADOWFORCE, :SEARINGSHOT, :VCREATE, :SECRETSWORD, :SACREDSWORD, :RELICSONG, :FUSIONBOLT, :FUSIONFLARE, :ICEBURN, :FREEZESHOCK, :BOLTSTRIKE, :BLUEFLARE, :GLACIATE, :TECHNOBLAST, :OBLIVIONWING, :LANDSWRATH, :THOUSANDARROWS, :THOUSANDWAVES, :DIAMONDSTORM, :STEAMERUPTION, :COREENFORCER, :FLEURCANNON, :PRISMATICLASER, :SUNSTEELSTRIKE, :SPECTRALTHIEF, :MOONGEISTBEAM, :MULTIATTACK, :MINDBLOWN, :PLASMAFISTS, :EARTHPOWER, :POWERGEM, :ERUPTION, :CONTINENTALCRUSH, :GENESISSUPERNOVA, :SOULSTEALING7STARSTRIKE, :SEARINGSUNRAZESMASH, :MENACINGMOONRAZEMAELSTROM, :LIGHTTHATBURNSTHESKY
      ],
      2.0 => [:VACUUMWAVE, :DRACOMETEOR, :METEORMASH, :MOONBLAST, :COMETPUNCH, :SWIFT, :HYPERSPACEHOLE, :SPACIALREND, :HYPERSPACEFURY, :ANCIENTPOWER, :FUTUREDUMMY, :BLACKHOLEECLIPSE],
      4.0 => [:DOOMDUMMY],
      0.25 => [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE],
      0 => [:HAIL, :SUNNYDAY, :SANDSTORM, :RAINDANCE, :SHADOWSKY, :GRASSYTERRAIN, :PSYCHICTERRAIN, :MISTYTERRAIN, :ELECTRICTERRAIN, :FISSURE],
    },
    :accuracyMods => {
      85 => [:DARKVOID],
    },
    :moveMessages => {
      "The light shone through the infinite darkness!" => [:AURORABEAM, :SIGNALBEAM, :FLASHCANNON, :DAZZLINGGLEAM, :MIRRORSHOT, :PHOTONGEYSER, :LIGHTTHATBURNSTHESKY],
      "The ethereal energy strengthened the attack!" => [
        :PSYSTRIKE, :AEROBLAST, :SACREDFIRE, :MISTBALL, :LUSTERPURGE,
        :ORIGINPULSE, :PRECIPICEBLADES, :DRAGONASCENT, :PSYCHOBOOST, :ROAROFTIME, :MAGMASTORM, :CRUSHGRIP, :JUDGMENT, :SEEDFLARE, :SHADOWFORCE, :SEARINGSHOT, :VCREATE, :SECRETSWORD, :SACREDSWORD, :RELICSONG, :FUSIONBOLT, :FUSIONFLARE, :ICEBURN, :FREEZESHOCK, :BOLTSTRIKE, :BLUEFLARE, :GLACIATE, :TECHNOBLAST, :OBLIVIONWING, :LANDSWRATH, :THOUSANDARROWS, :THOUSANDWAVES, :DIAMONDSTORM, :STEAMERUPTION, :COREENFORCER, :FLEURCANNON, :PRISMATICLASER, :SUNSTEELSTRIKE, :SPECTRALTHIEF, :MOONGEISTBEAM, :MULTIATTACK, :MINDBLOWN, :PLASMAFISTS, :GENESISSUPERNOVA, :SOULSTEALING7STARSTRIKE, :SEARINGSUNRAZESMASH, :MENACINGMOONRAZEMAELSTROM
      ],
      "The germinal matter amassed in the attack!" => [:EARTHPOWER, :POWERGEM, :ERUPTION, :CONTINENTALCRUSH],
      "The astral energy boosted the attack!" => [
        :VACUUMWAVE, :DRACOMETEOR, :METEORMASH, :MOONBLAST, :COMETPUNCH, :SWIFT,
        :HYPERSPACEHOLE, :SPACIALREND, :HYPERSPACEFURY, :ANCIENTPOWER, :FUTUREDUMMY
      ],
      "A star came crashing down on {1}!" => [:DOOMDUMMY],
      "{1} was swallowed up by the void!" => [:BLACKHOLEECLIPSE],
      "The unformed land diffused the attack..." => [:EARTHQUAKE, :MAGNITUDE, :BULLDOZE, :FISSURE],
      "The terrain had no solid ground to attach..." => [:GRASSYTERRAIN, :PSYCHICTERRAIN, :MISTYTERRAIN, :ELECTRICTERRAIN],
      "The weather drifted off into space..." => [:HAIL, :SUNNYDAY, :SANDSTORM, :RAINDANCE, :SHADOWSKY],
    },
    :typeMods => {
      :FIRE => [:DOOMDUMMY],
    },
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:DARK],
    },
    :typeMessages => {
      "Infinity boosted the attack!" => [:DARK],
    },
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {
      :STARLIGHT => [:GRAVITY, :GEOMANCY],
    },
    :dontChangeBackup => [:GRAVITY],
    :changeMessage => {
      "The world's matter reformed!" => [:GRAVITY],
      "The world was regenerated!" => [:GEOMANCY],
    },
    :statusMods => [:DARKVOID, :HEARTSWAP, :TRICKROOM, :MAGICROOM, :WONDERROOM, :COSMICPOWER, :FLASH, :MOONLIGHT, :NATURESMADNESS, :GUARDIANOFALOLA],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => :HyperBeam,
      :duration => 1,
      :message => "{1} must recharge!",
      :animation => nil,
      :stats => {
        PBStats::ATTACK => 1,
        PBStats::DEFENSE => 1,
        PBStats::SPEED => 1,
        PBStats::SPATK => 1,
        PBStats::SPDEF => 1,
      },
    },
  },
  :INVERSE => {
    :name => "Inverse Field",
    :fieldAppSwitch => 635,
    :fieldMessage => [
      "!trats elttaB"
    ],
    :graphic => ["Inverse"],
    :secretPower => :CONFUSION,
    :naturePower => :TRICKROOM,
    :mimicry => :NORMAL,
    :damageMods => {},
    :accuracyMods => {},
    :moveMessages => {},
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {},
    :typeMessages => {},
    :typeCondition => {},
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusMods => [],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => :HyperBeam,
      :duration => 1,
      :message => "{1} must recharge!",
      :animation => nil,
      :stats => {
        PBStats::ATTACK => 1,
        PBStats::DEFENSE => 1,
        PBStats::SPEED => 1,
        PBStats::SPATK => 1,
        PBStats::SPDEF => 1,
      },
    },
  },
  :PSYTERRAIN => {
    :name => "Psychic Terrain",
    :fieldAppSwitch => 636,
    :fieldMessage => [
      "The field became mysterious!"
    ],
    :graphic => ["Psychic"],
    :secretPower => :PSYCHIC,
    :naturePower => :PSYCHIC,
    :mimicry => :PSYCHIC,
    :damageMods => {
      1.5 => [:HEX, :MAGICALLEAF, :MYSTICALFIRE, :MOONBLAST, :AURASPHERE, :MINDBLOWN],
    },
    :accuracyMods => {
      90 => [:HYPNOSIS],
    },
    :moveMessages => {
      "The psychic energy strengthened the attack!" => [:HEX, :MAGICALLEAF, :MYSTICALFIRE, :MOONBLAST, :AURASPHERE, :MINDBLOWN],
    },
    :typeMods => {},
    :typeAddOns => {},
    :moveEffects => {},
    :typeBoosts => {
      1.5 => [:PSYCHIC],
    },
    :typeMessages => {
      "The Psychic Terrain strengthened the attack!" => [:PSYCHIC],
    },
    :typeCondition => {
      :PSYCHIC => "!attacker.isAirborne?",
    },
    :typeEffects => {},
    :changeCondition => {},
    :fieldChange => {},
    :dontChangeBackup => [],
    :changeMessage => {},
    :statusMods => [:CALMMIND, :COSMICPOWER, :KINESIS, :MEDITATE, :NASTYPLOT, :HYPNOSIS, :TELEKINESIS, :GRAVITY, :MAGICROOM, :TRICKROOM, :WONDERROOM],
    :changeEffects => {},
    :seed => {
      :seedtype => :MAGICALSEED,
      :effect => nil,
      :duration => 0,
      :message => nil,
      :animation => nil,
      :stats => {
        PBStats::SPATK => 2,
      },
    },
  },
}

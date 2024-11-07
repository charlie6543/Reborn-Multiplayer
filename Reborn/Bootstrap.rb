# DO NOT EDIT THESE VARIABLES.
# The values are changed automatically by our GitHub Actions workflows when preparing a new patch.
GAMEVERSION = '19.5.6'
VERSION_URL = 'https://www.rebornevo.com/downloads/rebornremote/Reborn_19.5/version.txt'
PATCH_URL = 'https://www.rebornevo.com/downloads/rebornremote/Reborn_19.5/patch.zip'
TILESETS_URL = 'https://www.rebornevo.com/downloads/rebornremote/Reborn_19.5/tilesets.zip'
PATCH_USER = ''

# List of scripts to be loaded by ScriptLoader.rb. Adjust as needed.
SCRIPTS = [
  'Reborn/Settings',
  'Reborn/SystemConstants',

  'RPG_Sprite',
  'SpriteResizer',
  'Game_Temp',
  'Game_Data',
  'Game_Screen',
  'Game_System',
  'Game_Picture',
  'Game_CommonEvent',
  'Game_Character',
  'Game_Event',
  'Game_Player',
  'Walk_Run',
  'Game_Map',
  'Map_Scroll',

  $joiplay ? 'TilemapXP' : nil,
  'Spriteset_Map',
  'AnimationSprite',
  'ReflectedSprite',

  'TileDrawingHelper',

  'RTP',
  'Interpreter',
  'Audio',
  'PBEvent',
  'PBIntl',
  'PBDebug',

  'BitmapCache',
  'Window',
  'SpriteWindow',
  'SW Subclasses',
  'LargePlane',
  'DrawText',
  'Messages',
  'TextEntry',
  'EventScene',

  'Scene_Intro',
  'Scene_Map',
  'Scene_Credits',

  'PBConstants',
  'PBStuff',
  'PBMove',
  'PBTypesExtra',
  'PBExperience',
  'PBAnimation',
  'PBScene',

  'Battle_ActiveSide',
  'Battle_DamageState',
  'Battler',
  'Battle_Effects',
  'Battle_Move',
  'Battle_ZMove',
  'Pokemon',
  'Battle_MoveEffects',
  'Battle',
  'Battle_Trainer',
  'Battle_Field',
  'Battle_AI',
  'Battle_Scene',
  'Battle_Inspect',

  'Field',
  'FieldWeather',
  'Map',
  'Encounters',
  'EncounterModifiers',
  'HiddenMoves',
  'BerryPlants',
  'DayCare',
  'DependentEvents',
  'Time',
  'TimeWeather',
  'Trainers',
  'Roaming',

  'Items',
  'ItemEffects',
  'Balls',
  'PokeRadar',
  'Bag',

  'Evolution',
  'Sprite',
  'Storage',

  'PauseMenu',
  'ReadyMenu',
  'Pokedex',
  'PokedexScene',
  'NestAndForm',
  'EggHatching',
  'Party',
  'Summary',
  'Pokegear',
  'RegionMap',
  'Jukebox',
  'PulseDex',
  'FieldNotes',
  'ItemTracker',
  'TrainerCard',
  'Trading',
  'MoveRelearner',
  'MovesetRestorer',
  'Mart',
  'HallOfFame',
  'MoveTutor',

  'MinigameSlotMachine',
  'MinigameVoltorbFlip',
  'MinigameLottery',
  'MinigameMining',
  'MinigameTilePuzzles',
  'Roulette Game',

  'OrgBattle',
  'OrgBattleRules',
  'OrgBattleGenerator',
  'BattleSwap',
  'Selection',

  'Options',
  'Save',
  'Load',
  'System',
  'Utilities',
  'Controls',
  'Debug',
  'Editor',
  'TilesetEditor',
  'AnimEditor',
  'DataObjects',
  'DataObjects - Compilers',
  'DataObjects - Yeeters',
  'Compiler',

  'Profiler',
  'Event YEET professional SP2',

  'Safari',
  'ShadowPokemon',
  'PurifyChamber',
  'Battle_SafariZone',
  'Battle_Peer',
  'Battle_Record',
  'Battle_Clauses',
  'FlyAnimation',

  'Reborn/RebornScripts',
  'Reborn/001_VASP',
  'Reborn/Map Connection Fix',
  'Reborn/InField Animation Fix',
  'Reborn/MapScrollerUpAndDown',
  'Reborn/FieldNoteCompiler',
  'Reborn/NewGamePlus',
  'Reborn/RebornPokegear',
  'Reborn/TrainerSelect',
  'Reborn/Blindstep',

  'Online/Connect&Register&Login&New',
  'Online/Unavailable Lists',
  'Online/Illegal Mon System',
  'Online/Network',
  'Online/Battle_Online',
  'Online/Trade',

  'cass shit',
  'haru stuff',
  'FL_SimpleHUD',

  'Cache',
  'DataConversion',
  'ClientData',
  'Randomizer/RandomizerUtils',
  'Randomizer/RandomizerHandler',
  'Randomizer/Randomizer',
  'Randomizer/RandomizerSettings',
  'Randomizer/RandomizerScene',
  'Randomizer/RandomizerCache',
  'Updater',

  GAMEVERSION == 'dev' ? 'Validator' : nil,
  !$joiplay ? 'Online/DiscordRichPresence' : nil,

  'Main',
]

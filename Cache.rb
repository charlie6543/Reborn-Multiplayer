class Cache_Game
  attr_reader :pkmn
  attr_reader :moves
  attr_reader :move2anim
  attr_reader :items
  attr_reader :trainers
  attr_reader :trainertypes
  attr_reader :FEData
  attr_reader :FENotes
  attr_reader :types
  attr_reader :abil
  attr_reader :mapinfos
  attr_reader :mapdata
  attr_reader :regions
  attr_reader :encounters
  attr_reader :metadata
  attr_reader :bosses
  # attr_reader :map_conns
  attr_reader :town_map
  attr_reader :animations
  attr_reader :RXsystem
  attr_reader :RXevents
  attr_reader :RXtilesets
  attr_reader :RXanimations
  attr_reader :cachedmaps
  attr_reader :natures
  attr_reader :shadows
  attr_reader :btmons
  attr_reader :bttrainers
  attr_reader :directory

  # Caching functions
  def cacheDex
    compileMons(@directory) if !fileExists?(@directory + "/mons.dat")
    @pkmn = load_data(@directory + "/mons.dat")
  end

  def cacheMoves
    compileMoves(@directory)      if !fileExists?(@directory + "/moves.dat")
    @moves     = load_data(@directory + "/moves.dat")
    @move2anim = load_data(@directory + "/move2anim.dat")
  end

  def cacheItems
    compileItems(@directory) if !fileExists?(@directory + "/items.dat")
    @items = load_data(@directory + "/items.dat")
  end

  def cacheTrainers
    compileTrainerTypes(@directory) if !fileExists?(@directory + "/ttypes.dat")
    @trainertypes       = load_data(@directory + "/ttypes.dat")
    compileTrainers(@directory)     if !fileExists?(@directory + "/trainers.dat")
    @trainers           = load_data(@directory + "/trainers.dat")
  end

  def cacheAbilities
    compileAbilities(@directory) if !fileExists?(@directory + "/abil.dat")
    @abil               = load_data(@directory + "/abil.dat")
  end

  def cacheBattleData
    compileFields(@directory) if !fileExists?(@directory + "/fields.dat")
    compileFieldNotes(@directory) if !fileExists?(@directory + "/fieldnotes.dat") && !Rejuv
    compileBosses(@directory) if Rejuv && !fileExists?(@directory + "/bossdata.dat")
    @FEData             = load_data(@directory + "/fields.dat")
    @FENotes            = load_data(@directory + "/fieldnotes.dat") if !Rejuv
    compileTypes(@directory) if !fileExists?(@directory + "/types.dat")
    cacheAbilities
    @types              = load_data(@directory + "/types.dat")
    @bosses             = load_data(@directory + "/bossdata.dat") if Rejuv
  end

  def cacheMapInfos
    @mapinfos           = load_data(@directory + "/MapInfos.rxdata")
  end

  def cacheMetadata
    # @regions            = load_data(@directory + "/regionals.dat") if !@regions
    @metadata           = load_data(@directory + "/meta.dat")
    @mapdata            = MapDataCache.new(load_data(@directory + "/maps.dat"))
    # @map_conns          = load_data(@directory + "/connections.dat") if !@map_conns
    @town_map           = load_data(@directory + "/townmap.dat")
    @natures            = load_data(@directory + "/natures.dat")
    # MessageTypes.loadMessageFile(@directory + "/Messages.dat")
  end

  def cacheBattleTower
    return if Desolation

    compileBTMons(@directory) if !fileExists?(@directory + "/btmons.dat")
    compileBTTrainers(@directory) if !fileExists?(@directory + "/bttrainers.dat")
    @btmons             = load_data(@directory + "/btmons.dat")
    @bttrainers         = load_data(@directory + "/bttrainers.dat")
  end

  def initialize(directory = "Data")
    @directory = directory
    cacheDex
    cacheMoves
    cacheItems
    cacheTrainers
    cacheBattleData
    cacheMetadata
    cacheMapInfos
    cacheAnims
    cacheTilesets
    cacheBattleTower
    @RXanimations       = load_data(@directory + "/Animations.rxdata") if !@RXanimations
    @RXevents           = load_data(@directory + "/CommonEvents.rxdata") if !@RXevents
    @RXsystem           = load_data(@directory + "/System.rxdata") if !@RXsystem
  end

  def cacheTilesets
    @RXtilesets         = load_data(@directory + "/Tilesets.rxdata")
  end

  def cacheAnims
    @animations         = load_data(@directory + "/battleanims.dat")
  end

  def animations=(value)
    @animations = value
  end

  def map_load(mapid)
    @cachedmaps = [] if !@cachedmaps
    if !@cachedmaps[mapid]
      puts "loading map " + mapid.to_s
      @cachedmaps[mapid] = load_data(sprintf(@directory + "/Map%03d.rxdata", mapid))
    end
    return @cachedmaps[mapid]
  end
end

# Little override to return blank metadata if the map doesn't have any.
class MapDataCache < Array
  def [](index)
    data = self.fetch(index) if index < self.length
    if data.nil?
      puts "Missing metadata for map " + index.to_s
      self[index] = MapMetadata.new(index, nil, [])
      data = self.fetch(index)
    end
    return data
  end
end

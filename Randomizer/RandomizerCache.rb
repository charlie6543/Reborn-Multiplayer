class Cache_Randomizer
  attr_reader :misc
  attr_reader :pkmn
  attr_reader :types
  attr_reader :statics
  attr_reader :moves
  attr_reader :trainers
  attr_reader :encounters
  attr_reader :encounterForms
  attr_reader :starters
  attr_reader :tms
  attr_reader :tutors
  attr_reader :items
  attr_reader :marts
  attr_reader :trainernames
  attr_reader :trainertypes

  def initialize
    @pkmn           = load_data("Randomizer Data/mons.dat")           if !@pkmn           && File.exist?("Randomizer Data/mons.dat")
    @moves          = load_data("Randomizer Data/moves.dat")          if !@moves          && File.exist?("Randomizer Data/moves.dat")
    @items          = load_data("Randomizer Data/items.dat")          if !@items          && File.exist?("Randomizer Data/items.dat")
    @marts          = load_data("Randomizer Data/marts.dat")          if !@marts          && File.exist?("Randomizer Data/marts.dat")
    @tutors         = load_data("Randomizer Data/tutors.dat")         if !@tutors         && File.exist?("Randomizer Data/tutors.dat")
    @encounters     = load_data("Randomizer Data/encounters.dat")     if !@encounters     && File.exist?("Randomizer Data/encounters.dat")
    @encounterForms = load_data("Randomizer Data/encounterForms.dat") if !@encounterForms && File.exist?("Randomizer Data/encounterForms.dat")
    @starters       = load_data("Randomizer Data/starters.dat")       if !@starters       && File.exist?("Randomizer Data/starters.dat")
    @trainers       = load_data("Randomizer Data/trainers.dat")       if !@trainers       && File.exist?("Randomizer Data/trainers.dat")
    @trainertypes   = load_data("Randomizer Data/trainertypes.dat")   if !@trainertypes   && File.exist?("Randomizer Data/trainertypes.dat")
    @trainernames   = load_data("Randomizer Data/trainernames.dat")   if !@trainernames   && File.exist?("Randomizer Data/trainernames.dat")
  end

  # def encounters
  #  @encounters[:encounters]
  # end

  # def gifts
  #  @encounters[:gifts]
  # end
end

class Skipper
  Match = Struct.new(:filename, :score)

  def initialize(search_key)
    @search_chars = search_key
    @basic_matcher = Regexp.new(search_key.chars.to_a.join(".*"), Regexp::IGNORECASE)
    @matching_files = []
  end

  def <<(filename)
    @matching_files << Match.new(filename, score(filename)) if filename =~ @basic_matcher
  end

  def take(count)
    @matching_files.sort_by(:score).take(count).map(&:filename)
  end

  def score(filename)
    1
  end
end

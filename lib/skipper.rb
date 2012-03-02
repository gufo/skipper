require File.expand_path(File.dirname(__FILE__) + '/scored_file')

class Skipper
  Match = Struct.new(:filename, :score)

  def initialize(search_key)
    @search = search_key
    @basic_matcher = build_regexp
    @matching_files = []
  end

  def <<(filename)
    @matching_files << ScoredFile.new(filename.strip, @search, @basic_matcher) if filename =~ @basic_matcher
  end

  def take(count)
    @matching_files.sort_by(&:score).reverse.take(count)
  end

  private
    def build_regexp
      chars = @search.chars.map do |char|
        char == '.' ? '\.' : char
      end
      Regexp.new(chars.to_a.join(".*"), Regexp::IGNORECASE)
    end

    def scoring_file_for(filename)
      FileDefinition.new(
        filename,
        File.dirname(filename),
        File.basename(filename)[/^(.*?)\./, 1] || '',
        File.basename(filename)[/\.(.*)$/, 1] || ''
      )
    end

end

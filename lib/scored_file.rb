require File.expand_path(File.dirname(__FILE__) + '/scored_string')

class ScoredFile
  attr_reader :score, :full_name, :path, :name, :extension

  SCORES = {
    :filename_only => 2000,
    :filename_boost => 3,
  }.freeze

  def initialize(filename, search, basic_matcher)
    @full_name = filename
    @basic_matcher = basic_matcher

    @path = File.dirname(filename)
    @name = File.basename(filename)[/^(.*?)\./, 1] || ''
    @extension = File.basename(filename)[/\.(.*)$/, 1] || ''

    if search =~ /\./
      search, divider, extension_search = search.split('.')
      @strings = [ScoredString.new(@name, search.chars), ScoredString.new(@extension, search.chars)]
    else
      @strings = [ScoredString.new(@name, search.chars)]
    end

    @score = calculate_score
  end

private
  def calculate_score
    score = 0
    score += SCORES[:filename_only] if matching_file_basename?
    score += string_scores
    score -= @path.size
    score
  end

  def matching_file_basename?
    @name =~ @basic_matcher
  end

  def string_scores
    @strings.inject(0) { |score, string| score += string.score }
  end
end

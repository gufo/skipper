require File.expand_path(File.dirname(__FILE__) + '/scored_string')

class ScoredFile
  attr_reader :score, :full_name, :path, :name, :extension

  SCORES = {
    :filename_only => 2000,
    :boost => {
      :path => 1, :extension => 1, :name => 5, :name_boost => 10, :remainder => 3
    }
  }.freeze

  def initialize(filename, search, basic_matcher)
    @full_name = filename
    @basic_matcher = basic_matcher

    @path = File.dirname(filename)
    @name = File.basename(filename)[/^(.*?)\./, 1] || ''
    @extension = File.basename(filename)[/\.(.*)$/, 1] || ''

    remaining_scope = @full_name
    remaining_search = search
    @strings = {}
    if remaining_search =~ /\//
      path_search, remaining_search = remaining_search.split('/')
      remaining_scope = remaining_scope.gsub("#{@path}/", '')
      @strings[:path] = ScoredString.new(@path, path_search)
    end
    if remaining_search =~ /\./
      remaining_search, extension_search = remaining_search.split(/\./)
      remaining_scope = remaining_scope.gsub(".#{extension}", '')
      @strings[:extension] = ScoredString.new(@extension, extension_search)
    end

    unless remaining_scope.empty?
      if @strings[:path] and @strings[:extension]
        @strings[:name] = ScoredString.new(remaining_search, remaining_scope) unless remaining_scope.empty?
      else
        @bonus_score = ScoredString.new(@name, remaining_search).bonus
        @strings[:remainder] = ScoredString.new(remaining_search, remaining_scope)
      end
    end

    @score = calculate_score
  end

private
  def calculate_score
    score = 0
    score += string_scores
    score -= @path.size
    score
  end

  def string_scores
    score = 0
    @strings.each_pair { |segment, string| score += string.score }
    score += @bonus_score.to_i
    score
  end
end

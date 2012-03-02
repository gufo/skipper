class ScoredFile
  attr_reader :score, :full_name, :path, :name, :extension

  SCORES = {
    :filename_only => 2000,
    :first_letter_in_name => 500,
    :first_letter_in_word => 100,
    :filename_boost => 3,
  }.freeze

  def initialize(filename, search_chars, basic_matcher)
    @full_name = filename
    @search_chars = search_chars
    @basic_matcher = basic_matcher

    @path = File.dirname(filename)
    @name = File.basename(filename)[/^(.*?)\./, 1] || ''
    @extension = File.basename(filename)[/\.(.*)$/, 1] || ''

    @score = calculate_score
  end

private
  def calculate_score
    @optimal_match = optimal_match
    score = 0
    score += SCORES[:filename_only] if matching_file_basename?
    score += score_on_first_letter_match
    score -= tightness * SCORES[:filename_boost]
    score -= overshoot * SCORES[:filename_boost]
    score -= @path.size
    score
  end

  def matching_file_basename?
    @name =~ @basic_matcher
  end

  def optimal_match
    candidate_match_positions.sort { |positions|
      score_on_first_letter_match
    }.first
  end

  def tightness
    return 100 unless @optimal_match
    @optimal_match.last - @optimal_match.first
  end

  def overshoot
    return 30 unless @optimal_match
    @name.size - @optimal_match.last
  end

  def score_on_first_letter_match
    return 0 unless @optimal_match
    @optimal_match.inject(0) { |current_score, position| current_score += first_letter_score(position) }
  end

  def first_letter_score(position)
    return SCORES[:first_letter_in_name] if position == 0
    return SCORES[:first_letter_in_word] if is_first_letter?(position)
    0
  end

  def is_first_letter?(position)
    str = @name
    [' ', '/', '-', '_'].include?(str[position - 1]) or
      (str[position] == str[position].upcase and str[position + 1] == str[position + 1].downcase)
  end

  def candidate_match_positions(letter_id = 0, base_position = -1)
    candidates_per_character_index = []
    @search_chars.each { candidates_per_character_index << [] }

    @search_chars.each_with_index do |char, index|
      next_match = @name.index(char)
      until next_match.nil?
        candidates_per_character_index[index] << next_match
        next_match = @name.index(char, next_match + 1)
      end
    end

    expand_match_candidates(candidates_per_character_index)
  end

  def expand_match_candidates(candidates, lowest_acceptable_value = -1)
    full_set = []

    candidates.first.each do |candidate_position|
      if candidate_position > lowest_acceptable_value
        if candidates.length == 1
          full_set << [candidate_position]
        else
          expand_match_candidates(candidates[1..-1], candidate_position).each do |expanded_candidates|
            full_set << [candidate_position] + expanded_candidates
          end
        end
      end
    end
    full_set
  end
end

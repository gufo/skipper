class Skipper
  Match = Struct.new(:filename, :score)
  FileDefinition = Struct.new(:raw, :path, :name, :extension)

  SCORES = {:filename_only => 2000, :first_letter_in_name => 500, :first_letter_in_word => 100}.freeze

  def initialize(search_key)
    @search_chars = search_key.chars
    @basic_matcher = Regexp.new(@search_chars.to_a.join(".*"), Regexp::IGNORECASE)
    @matching_files = []
  end

  def <<(filename)
    @matching_files << Match.new(filename.strip, score(filename)) if filename =~ @basic_matcher
  end

  def take(count)
    @matching_files.sort_by(&:score).reverse.take(count)
  end

  private
    def score(filename)
      @scoring_file = scoring_file_for(filename)

      score = 0
      score += SCORES[:filename_only] if matching_file_basename?
      score += first_letter_matches_count
      score
    end

    def scoring_file_for(filename)
      FileDefinition.new(
        filename,
        File.dirname(filename),
        File.basename(filename)[/^(.*?)\./, 1] || '',
        File.basename(filename)[/\.(.*)$/, 1] || ''
      )
    end

    def matching_file_basename?
      @scoring_file.name =~ @basic_matcher
    end

    def first_letter_matches_count
      candidate_match_positions.map do |positions|
        score_on_first_letter_match(positions)
      end.max.to_i
    end

    def score_on_first_letter_match(positions)
      positions.inject(0) { |current_score, position| current_score += first_letter_score(position) }
    end

    def first_letter_score(position)
      return SCORES[:first_letter_in_name] if position == 0
      return SCORES[:first_letter_in_word] if is_first_letter?(position)
      0
    end

    def is_first_letter?(position)
      str = @scoring_file.name
      position == 0 or
        [' ', '/', '-', '_'].include?(str[position - 1]) or
        (str[position] == str[position].upcase and str[position + 1] == str[position + 1].downcase)
    end

    def candidate_match_positions(letter_id = 0, base_position = -1)
      candidates_per_character_index = []
      @search_chars.each { candidates_per_character_index << [] }

      @search_chars.each_with_index do |char, index|
        next_match = @scoring_file.name.index(char)
        until next_match.nil?
          candidates_per_character_index[index] << next_match
          next_match = @scoring_file.name.index(char, next_match + 1)
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

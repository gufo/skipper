#!/usr/bin/env ruby

search_key = ARGV.first
hit_count = 10
if (ARGV[1] == '-n')
  hit_count = ARGV[2].to_i
end

search_regexp = Regexp.new(search_key.chars.to_a.join(".*"), Regexp::IGNORECASE)

hits = []
STDIN.each_line do |line|
  hits << line if line =~ search_regexp
end

puts hits.take(hit_count).join("\n")

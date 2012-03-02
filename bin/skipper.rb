#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../lib/skipper')
search_key = ARGV.first
hit_count = 10

if count_index = ARGV.index('-n')
  hit_count = ARGV[count_index + 1].to_i
end

skipper = Skipper.new(search_key)

hits = []
STDIN.each_line do |line|
  skipper << line
end

puts skipper.take(hit_count).map(&:full_name).join("\n")

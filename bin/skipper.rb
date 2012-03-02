#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../lib/skipper')
search_key = ARGV.first
hit_count = 10
if (ARGV[1] == '-n')
  hit_count = ARGV[2].to_i
end

skipper = Skipper.new(search_key)

hits = []
STDIN.each_line do |line|
  skipper << line
end

puts skipper.take(hit_count).map(&:filename).join("\n")

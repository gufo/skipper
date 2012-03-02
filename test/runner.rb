#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + '/assert_results')

require 'rubygems'
require 'colored'

unless ARGV.size == 1
  puts "Usage: test/runner.rb [system-under-test]"
  exit(-1)
end

assert_results(ARGV.first,
  'uc' => 'app/controllers/users_controller.rb',
  'ucs' => 'spec/controllers/users_controller_spec.rb',
)

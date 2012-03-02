def assert_results(command, hash)
  failures = 0
  successes = 0

  hash.each_pair do |search_key, expected_top_result|
    expected_top_result = [expected_top_result].flatten
    output = `cat test/fixtures/file_list.txt | bin/#{command} #{search_key} -n #{expected_top_result.size}`.strip.split("\n")

    if output != expected_top_result
      puts "FAIL for key: ".red + search_key.red.bold
      puts "    Actual: ".red + output.join("\n")
      puts "  Expected: ".red + expected_top_result.join("\n")
      puts ""
      failures += 1
    else
      successes += 1
    end
  end

  result = "#{hash.size} tests; #{failures} failures; #{successes} successes.".green
  puts (failures > 0) ? result.red : result.green
end

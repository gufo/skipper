def assert_results(command, hash)
  failures = []

  hash.each_pair do |search_key, expected_top_result|
    expected_top_result = [expected_top_result].flatten
    output = `cat test/fixtures/fenix.txt | bin/#{command} #{search_key} -n #{expected_top_result.size}`.strip.split("\n")

    if output != expected_top_result
      failures << {:key => search_key, :expected => expected_top_result, :actual => output}
      print "F".red; STDOUT.flush
    else
      print ".".green; STDOUT.flush
    end
  end

  puts ""

  failures.each do |failure|
    puts "FAIL for key: ".red + failure[:key].red.bold
    puts "    Actual: ".red + failure[:actual].join("\n")
    puts "  Expected: ".red + failure[:expected].join("\n")
    puts ""
  end

  result = "#{hash.size} tests; #{failures.size} failures; #{hash.size - failures.size} successes."
  puts (failures.to_i > 0) ? result.red : result.green
end

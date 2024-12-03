(1..25).each do |day|
  day_dir = "day_#{day.to_s.rjust(2, '0')}"
  Dir.mkdir(day_dir) unless Dir.exist?(day_dir)
  File.write("#{day_dir}/solution_1.rb", "# Solution for Day #{day} Part 1\n")
  File.write("#{day_dir}/solution_2.rb", "# Solution for Day #{day} Part 2\n")
  File.write("#{day_dir}/input.txt", "# Input for Day #{day}\n")
  File.write("#{day_dir}/test_input.txt", "# Test input for Day #{day}\n")
end
puts "Advent of Code setup complete!"

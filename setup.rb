(1..25).each do |day|
  day_dir = "day_#{day.to_s.rjust(2, '0')}"
  Dir.mkdir(day_dir) unless Dir.exist?(day_dir)

  solution_boilerplate = <<~RUBY
    # Solution for Day #{day}

    require_relative '../utils'

    # Read input lines
    lines = read_input_lines("#{day_dir}/input.txt")

    # Solution logic
    
  RUBY


  File.write("#{day_dir}/solution_1.rb", solution_boilerplate)
  File.write("#{day_dir}/solution_2.rb", solution_boilerplate)
  File.write("#{day_dir}/input.txt", "")
  File.write("#{day_dir}/test_input.txt", "")
end
puts "Advent of Code setup complete!"

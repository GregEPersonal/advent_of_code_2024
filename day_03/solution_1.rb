# Solution for Day 3

require_relative '../utils'
require 'pry' 

# Read input lines
lines = read_input_lines("day_03/input.txt")

def parse_line(line)
  # Find next index of "mul(" in the line
  next_index = line.index("mul(")
  result = 0
  while !next_index.nil? && next_index < line.length
    comma_index_after_next = line.index(",", next_index)
    end_paren_index = line.index(")", comma_index_after_next)

    numbers_string_array = (0..9).to_a.map(&:to_s)

    first_number_string = line[next_index + 4...comma_index_after_next]
    if first_number_string.length <= 3 && first_number_string.match?(/^[0-9]+$/)
        first_number = first_number_string.to_i
    else 
      first_number = 0
    end

    second_number_string = line[comma_index_after_next + 1...end_paren_index]
    if second_number_string.length <= 3 && second_number_string.match?(/^[0-9]+$/)
      second_number = second_number_string.to_i
    else 
      second_number = 0
    end

    if first_number != 0 && second_number != 0
      puts "First number: #{first_number}, Second number: #{second_number}, full_string = #{line[next_index...end_paren_index + 1]}, first_string = #{first_number_string}, second_string = #{second_number_string}, next_index = #{next_index}, end_paren_index = #{end_paren_index}"
    end

    result += first_number * second_number
    next_index = line.index("mul(", next_index + 1)
  end
  return result
end


# Solution logic
total_count = 0
lines.each do |line|
  total_count += parse_line(line)
end
puts total_count

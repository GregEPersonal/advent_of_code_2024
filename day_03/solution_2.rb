# Solution for Day 3

require_relative '../utils'
require 'pry' 


# Read input lines
lines = read_input_lines("day_03/input.txt")

# Solution logic

#Cuts down line to relevant parts
# Remove anything from don't() to do()
def parse_for_enabled(line)
 # Find the next instance of don't.
 current_index = 0
 return_line = ""
  while !current_index.nil? && current_index < line.length
    # Next instance of don't
    next_dont_index = line.index("don't()", current_index)
    if next_dont_index.nil? 
      return_line += line[current_index..line.length]
      current_index = line.length
      next
    end     
    following_do_index = line.index("do()", next_dont_index)

    if following_do_index.nil?
      return_line += line[current_index..next_dont_index-1]
      current_index = line.length
      next
    end

    # binding.pry

    return_line += line[current_index..next_dont_index-1]
    current_index = following_do_index 
  end

  return return_line

end

# Given a possible mul(x,y) string, parse it and return the two numbers and whether it's valid
def parse_mul_string(line, next_index, comma_index_after_next, end_paren_index)

  first_number_string = line[next_index + 4...comma_index_after_next]
  valid = true
  if first_number_string.length <= 3 && first_number_string.match?(/^[0-9]+$/)
      first_number = first_number_string.to_i
  else 
    valid = false
    first_number = 0
  end

  second_number_string = line[comma_index_after_next + 1...end_paren_index]
  if second_number_string.length <= 3 && second_number_string.match?(/^[0-9]+$/)
    second_number = second_number_string.to_i
  else 
    valid = false
    second_number = 0
  end

  return valid, first_number, second_number
end

# Parse a line for mul() and return the sum of all the multiplications
def parse_input(line)

  # First, we disable all the don'ts
  # We just remove those sections entirely.
  line = parse_for_enabled(line)

  # Find next index of "mul(" in the line
  next_index = line.index("mul(")
  result = 0
  
  # Iterate through with a while loop. 
  while !next_index.nil? && next_index < line.length
    comma_index_after_next = line.index(",", next_index)
    end_paren_index = line.index(")", comma_index_after_next)

    valid, first_number, second_number = parse_mul_string(line, next_index, comma_index_after_next, end_paren_index)

    if valid
      puts "First number: #{first_number}, Second number: #{second_number} full_string = #{line[next_index...end_paren_index + 1]}, next_index = #{next_index}, end_paren_index = #{end_paren_index}"
    end

    result += first_number * second_number if valid
    next_index = line.index("mul(", next_index + 1)
  end
  return result
end


# Solution logic
total_count = 0
# Treated them separately at first, but the do() and don't() carry thorugh and that messed them up
total_count += parse_input(lines.join(" "))
# lines.each do |line|
#   total_count += parse_line(line)
# end
puts total_count


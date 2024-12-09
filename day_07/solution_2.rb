# Solution for Day 7

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_07/input.txt")

# Solution logic
correct_sum = 0

def solve_line(goal_value, numbers, current_total)
  if numbers.length == 0
    return current_total == goal_value
  end

  current_number = numbers[0].to_i
  remaining_numbers = numbers[1..-1]

  return solve_line(goal_value, remaining_numbers, current_total + current_number) || solve_line(goal_value, remaining_numbers, current_total * current_number)
end

def evaluate_line(line)
  line_parts = line.split(":")
  goal_value = line_parts[0].strip.to_i
  numbers = line_parts[1].strip.split(" ")

  current_number = numbers[0].to_i
  remaining_numbers = numbers[1..-1]

  if solve_line(goal_value, remaining_numbers, current_number)
    return goal_value
  else
    return 0
  end
end

lines.each do |line|
  correct_sum += evaluate_line(line)
end

puts correct_sum

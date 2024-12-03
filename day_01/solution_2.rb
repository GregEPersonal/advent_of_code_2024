# Solution for Day 1

require_relative '../utils'

# Read input lines
lines = read_input_lines("day_01/input.txt")

# Solution logic
left_array = []
right_array = []

lines.each do |line|
  # Split line into two numbers based on spaces in middle
  left, right = line.split(' ')
  left_array.push(left.to_i)
  right_array.push(right.to_i)
end

left_array.sort!
right_array.sort!

total_sum = 0
left_array.each do |num|
  # Count the number of times num appears in right_array
  count = right_array.count(num)
  total_sum += num*count
end

p total_sum

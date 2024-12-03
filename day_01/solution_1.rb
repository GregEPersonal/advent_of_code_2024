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
for i in 0..left_array.length-1
  diff = (right_array[i] - left_array[i]).abs
  total_sum += diff 

  if i %100 == 0
    puts " #{i} #{left_array[i]} #{right_array[i]} #{diff} #{total_sum}"
  end
end

p total_sum

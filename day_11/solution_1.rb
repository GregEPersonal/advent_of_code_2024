# Solution for Day 11

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_11/input.txt")

# Solution logic
stone_array = []

lines.each do |line|
  stone_array += line.split(" ").map(&:to_i)
end

def processStone(stone)
  if stone == 0
    return 1, nil
  end
  stone_string = stone.to_s
  stone_length = stone_string.length
  if stone_length % 2 == 0
    return stone_string[0..stone_length / 2 - 1].to_i, stone_string[stone_length / 2..stone_length - 1].to_i
  end

  return stone * 2024, nil
end

def full_array_step(stone_array)
  old_array = stone_array.map(&:clone)

  adjusted_index = 0

  (0..old_array.length - 1).each do |i|
    replacement, new_number = processStone(old_array[i])
    stone_array[adjusted_index] = replacement
    adjusted_index += 1
    if new_number
      stone_array.insert(adjusted_index, new_number)
      adjusted_index += 1
    end
  end

  return stone_array
end

def stone_array_loop(stone_array, iterations)
  iterations.times do
    stone_array = full_array_step(stone_array)
    puts "Completed iteration"
  end
  return stone_array
end

# test_array = [773]

result_array = stone_array_loop(stone_array, 25)
# puts result_array
puts "Final Length: #{result_array.length}"

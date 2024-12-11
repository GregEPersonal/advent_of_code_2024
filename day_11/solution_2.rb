# Solution for Day 11

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_11/input.txt")

# Solution logic
stone_array = []

lines.each do |line|
  stone_array += line.split(" ").map(&:to_i)
end

# -----------------------------------
# # -----------------------------------
# -------- Recursion-------------
#  Faster than the loop, but harder to optimize.
# -----------------------------------
# -----------------------------------

# Recursively solve.
# Trades array memory for function memory, so not certain this is better.
def stone_iteration(stone, iterations)
  if iterations == 0
    return 1
  end
  replacement, new_number = processStone(stone)

  new_count = new_number ? stone_iteration(new_number, iterations - 1) : 0
  return stone_iteration(replacement, iterations - 1) + new_count
end

#Okay, we could either:
# Chop up the array into 2 parts, and handle each separately
# OR, we could try to be smart about the expected length of given numbers, not calculating the 2 for example.
def stone_array_loop(stone_array, iterations)
  stone_array_count = 0
  stone_array.each do |stone|
    stone_array_count += stone_iteration(stone, iterations)
  end
  return stone_array_count
end

# -----------------------------------
# -----------------------------------
# -------- Actual code-------------
#  De-duping the stones
# -----------------------------------
# -----------------------------------

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

# We take the stone_array, and group each number int eh array, counting it.
# We then iterate through the unique numbers, and return the next itreation, multiplied by the count.
# Ok, thinking through. I start with grouped array. I transform all the keys.
# I then add to a new array, all of the new keys, and their associated coutns (same)
# I then group the new array, and repeat.
def stone_array_iteration(grouped_numbers, iterations)
  puts "Iterations remaining: #{iterations}"
  if iterations == 0
    return grouped_numbers.values.sum
  end
  new_grouped_numbers = {}

  grouped_numbers.each do |stone, count|
    replacement, new_number = processStone(stone)

    # Add to new grouped numbers
    if new_grouped_numbers.key?(replacement)
      new_grouped_numbers[replacement] += count
    else
      new_grouped_numbers[replacement] = count
    end
    # Add the new number if it exists
    if new_number
      if new_grouped_numbers.key?(new_number)
        new_grouped_numbers[new_number] += count
      else
        new_grouped_numbers[new_number] = count
      end
    end
  end

  return stone_array_iteration(new_grouped_numbers, iterations - 1)
end

# Start the loop, grouping into new numbers
def stone_array_loop(stone_array, iterations)
  stone_array_count = 0
  # Get the numbers into a hash, with the number as the key, the count as the value.
  grouped_numbers = stone_array.group_by(&:itself).transform_values(&:count)

  stone_array_count += stone_array_iteration(grouped_numbers, iterations)

  return stone_array_count
end

final_count = stone_array_loop(stone_array, 75)
# puts result_array
puts "Final Count: #{final_count}"

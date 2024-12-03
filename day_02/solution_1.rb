# Solution for Day 2

require_relative '../utils'

# Read input lines
lines = read_input_lines("day_02/input.txt")

# Solution logic
safe_count = 0

def vet_line(int_array)
  change_type = nil
  first_value = int_array[0]
  second_value = int_array[1]

  if second_value == first_value
    return false
  end
  second_value > first_value ? change_type = "increase" : change_type = "decrease"

  prior_num = first_value
  
  # Iterate through each number in the array with the index of it.
  int_array.each_with_index do |num, index|
    # Skip the first number in the array
    next if index == 0

    # If the number is the same as the prior number, return false
    if num == prior_num
      return false
    end

    # If the number is greater than the prior number 
    # and the change type is decrease, return false
    if num > prior_num 
      if change_type == "decrease"
        return false
      end
    end

    # If the number is less than the prior number
    # and the change type is increase, return false
    if num < prior_num
      if change_type == "increase"
        return false
      end
    end

    diff = (num - prior_num).abs
    if diff < 1 || diff > 3
      return false
    end

    prior_num = num
  end

  return true
end

lines.each do |line|
  int_array = line.split(" ").map(&:to_i)
  if vet_line(int_array)
    safe_count += 1
  end
end

puts safe_count
  

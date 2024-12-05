# Solution for Day 5

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_05/input.txt")

# Solution logic
rule_count = 0
update_count = 0
done_with_rules = false
update_lines = []

# Count what we're dealing with first
lines.each_with_index do |line, index|
  if line.empty?
    done_with_rules = true
    next
  end

  if !done_with_rules
    rule_count += 1
  else
    update_count += 1
    update_lines << line
  end
end

rules = Array.new(2) { Array.new(rule_count) }
done_with_rules = false

lines.each_with_index do |line, index|
  if line.empty?
    done_with_rules = true
    next
  end

  if !done_with_rules
    numbers = line.strip.split("|").map(&:to_i)
    rules[0][index] = numbers[0]
    rules[1][index] = numbers[1]
  end
end

def check_rules(number_1, number_2, rules)
  # Check if the numbers are in the same rule
  # If they are, check if they are in the correct order
  for i in 0..rules[0].length - 1
    # If number_1 is in the first position, and number_2 is in the second position, return true
    if rules[0][i] == number_1 && rules[1][i] == number_2
      return true
      # If number_2 is in the first position, and number_1 is in the second position, return false
    elsif rules[0][i] == number_2 && rules[1][i] == number_1
      return false
    end
  end
  return true # No rules apply.
end

# Okay, so basic plan. For each line, for each number, see if it's correctly placed.
# We make an array out of the line, and then we check if the number is in the right place.
def validate_line(rules, line)
  line_array = line.strip.split(",").map(&:to_i)

  # Iterate through each number in the line
  # Check if it is in the same rule as any other number later in the array.
  # IF so, check if it's correct
  line_array.each_with_index do |number, index|
    for i in index + 1..line_array.length - 1
      correct_pair = check_rules(number, line_array[i], rules)
      if !correct_pair
        return false, -1
      end
    end
  end
  # Just divide by two, as index starts at 0
  middle_number = line_array[line_array.length / 2]
  return true, middle_number
end

def reorder_operation(rules, line_array)
  # Iterate through char by char
  line_array.each_with_index do |number, index|
    # For each char after, find where it's wrong.
    for i in index + 1..line_array.length - 1
      correct_pair = check_rules(number, line_array[i], rules)
      if !correct_pair
        # Swap the two numbers - Sure, we'll try it. Might be more efficient to just move the first after the second.
        line_array[index], line_array[i] = line_array[i], line_array[index]
        return reorder_operation(rules, line_array)
      end
    end
  end
  return line_array
end

# Reorder an incorrect line based on the rules
def reorder_line(rules, line)
  line_array = line.strip.split(",").map(&:to_i)

  return reorder_operation(rules, line_array).join(",")
end

# Validate lines, adjust incorrects, and sum up middles
# Woof, a little slow. Just re-used all the old components, doubleing up a lot. But it works.
sum_of_middles = 0
update_lines.each do |line|
  correct_line, mid = validate_line(rules, line)
  if !correct_line
    new_line = reorder_line(rules, line)
    new_line_correct, new_mid = validate_line(rules, new_line)
    p "ERROR: line #{line} is incorrect, AND SO IS NEW LINE" if !new_line_correct
    sum_of_middles += new_mid
  end
end

p sum_of_middles

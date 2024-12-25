# Solution for Day 25

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_25/input.txt")

locks = []
keys = []

# Solution logic
# The lines come in groups of 7 lines with a blank line between groups
lines.each_slice(8) do |group|
  # Drop the last line from group
  group.pop if group.size == 8
  schematic = Array.new(7) { Array.new(5) { "." } }
  column_length = [0, 0, 0, 0, 0]
  if group[0][0] == "#"
    schematic_type = "lock"
  else
    schematic_type = "key"
    group = group.reverse
  end

  group.each_with_index do |line, row|
    line.each_char.with_index do |char, index|
      schematic[row][index] = char
      next if row == 0
      column_length[index] += 1 if char == "#"
    end
  end

  if schematic_type == "lock"
    locks << { lengths: column_length, total_length: column_length.sum }
  else
    keys << { lengths: column_length, total_length: column_length.sum }
  end
end

locks.sort_by! { |lock| lock[:total_length] }
keys.sort_by! { |key| key[:total_length] }

# Then test each key against each lock
acceptable_pairs = 0
keys.each do |key|
  locks.each do |lock|
    if key[:total_length] + lock[:total_length] > 25
      break
    end
    acceptable = true
    key[:lengths].each_with_index do |key_length, index|
      if key_length + lock[:lengths][index] > 5
        acceptable = false
        break
      end
    end
    acceptable_pairs += 1 if acceptable
  end
end

puts "Acceptable pairs: #{acceptable_pairs}"

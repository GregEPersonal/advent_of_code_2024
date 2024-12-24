# Solution for Day 24

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_24/input.txt")

# Solution logic
# It'd be nice to use a class for this, but perhaps not that much simpler.
# I guess the quick way is to use a hash, as always.

# Split the lines into two, based on the empty line
default_values, logic_group_lines = lines.join("\n").split("\n\n")

# Parse the default values
value_hash = {}
default_values.split("\n").map do |line|
  key, value = line.split(": ")
  value_hash[key] = value.to_i
end

def parse_logic_line(line)
  input, output_gate = line.split(" -> ")
  input_gate_1, logic_string, input_gate_2 = input.split(" ")

  {
    gate_1: input_gate_1,
    logic_string: logic_string,
    gate_2: input_gate_2,
    output_gate: output_gate,
  }
end

logic_groups = logic_group_lines.split("\n").map { |line| parse_logic_line(line) }

# Parse the logic groups
# While logic_gourps is not empty
while !logic_groups.empty?
  logic_groups.each do |lg|
    if value_hash[lg[:gate_1]] && value_hash[lg[:gate_2]]
      value_hash[lg[:output_gate]] = case lg[:logic_string]
        when "AND"
          value_hash[lg[:gate_1]] & value_hash[lg[:gate_2]]
        when "OR"
          value_hash[lg[:gate_1]] | value_hash[lg[:gate_2]]
        when "XOR"
          value_hash[lg[:gate_1]] ^ value_hash[lg[:gate_2]]
        else
          puts "ERROR - Unknown logic string: #{lg[:logic_string]}"
        end
      logic_groups.delete(lg)
    end
  end
end

# Output the result
puts "Completed the logic groups"
puts value_hash

# Get all gates that start with a "z", sort them, and convert to binary.
end_value = []
value_hash.keys.select { |key| key.start_with?("z") }.sort.each do |key|
  value = value_hash[key]
  puts "#{key}: #{value}"
  end_value += [value]
end

# Okay, we have a string that is a basically a long binary number. Let's convert it.
end_decimal = 0
end_value.each_with_index do |value, index|
  end_decimal += value * (2 ** index)
end

puts "The end value is: #{end_decimal}"

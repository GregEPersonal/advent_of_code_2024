# Solution for Day 24

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_24/input.txt")

# Solution logic
#
# This is going to be pretty easy. Just a basic addition gates.
# So each input gate X## will have two logics gates it's connected too:
# X## AND Y## -> CCC The carry over for this number
# X## XOR Y## -> XXX The "ones digit" for this number
# Then we use the output to determine Z##  based on the carry over from the prior index.
#
# example:
# y07 XOR x07 -> shj # Get the 1s sigit for this index, (need to handle carry still)
# y07 AND x07 -> sdq # Get the carry for this index
#
# pbk OR sdq -> ggp # pbk is the output from a prior index

# jjg XOR shj -> z07 jjg represents the carry from a prior index, so we xor it to get the 1s digit here
# # shj AND jjg -> pbk #jjg is hte carry from a prior index, so we AND it to see what the ultimate carry is from 07

# wgp OR ncj -> jjg # So, if there is either carry over from 06 summing directly, OR from 06 + 05 carry, then we have carry to 07
#
# hdt AND gwg -> ncj # ncj is the ultimate carry over from z06
# hdt XOR gwg -> z06
# y06 XOR x06 -> gwg
# tsw XOR wwm -> hdt
# hdt XOR gwg -> z06
#
# y06 AND x06 -> wgp #wgp is the initial carry over from index 06
#

# So, the easiest thing to do would be build a visualization I guess?
# Basically, starting at 00, show each gate in order.

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

def print_logic_group(group)
  "#{group[:gate_1]} #{group[:logic_string]} #{group[:gate_2]} -> #{group[:output_gate]}"
end

def convert_binary_array_to_decimal(array) # Okay, we have a string that is a basically a long binary number. Let's convert it.
  end_decimal = 0
  array.each_with_index do |value, index|
    end_decimal += value * (2 ** index)
  end
  end_decimal
end

def get_added_value(value_hash, logic_groups)
  binary_array = get_added_binary_value(value_hash, logic_groups)
  end_decimal = convert_binary_array_to_decimal(binary_array)

  end_decimal
end

def get_added_binary_value(value_hash, logic_groups)
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

  # Get all gates that start with a "z", sort them, and convert to binary.
  end_value = []
  value_hash.keys.select { |key| key.start_with?("z") }.sort.each do |key|
    value = value_hash[key]
    puts "#{key}: #{value}"
    end_value += [value]
  end
  return end_value
end

# NEW CODE
logic_groups = logic_group_lines.split("\n").map { |line| parse_logic_line(line) }
second_logic_groups = logic_groups.dup

# Get all keys that start with x, sort them, and convert to binary.
x_values = value_hash.keys.select { |key| key.start_with?("x") }.sort.map { |key| value_hash[key] }
y_values = value_hash.keys.select { |key| key.start_with?("y") }.sort.map { |key| value_hash[key] }
z_array = get_added_binary_value(value_hash, logic_groups)

puts "X Values:  #{x_values.reverse.join("")}"
puts "Y Values:  #{y_values.reverse.join("")}"
puts "Z Values: #{z_array.reverse.join("")}"
puts "X Decimal: #{convert_binary_array_to_decimal(x_values)}"
puts "Y Decimal: #{convert_binary_array_to_decimal(y_values)}"
puts "Z Decimal: #{convert_binary_array_to_decimal(z_array)}"

# Okay, so for logic groups. We start with the x00 y00 gates. We print them.
# We then take both of the output gates, and find all logic groups that involve them.
# For all ones that are complete, we output them, and add the output gate to the list of gates to check.
# For all that are missing input gates, we handle the input gates first.
# We then remove the logic group from the list.

logic_groups = second_logic_groups
logic_to_print = logic_groups.select { |lg| lg[:gate_1] == "x00" || lg[:gate_2] == "y00" || lg[:gate_1] == "y00" || lg[:gate_2] == "x00" }.to_a
printed_gates = value_hash.keys.select { |key| key.start_with?("x") || key.start_with?("y") }.to_a

while !logic_to_print.empty?
  group = logic_to_print.first

  # binding.pry
  if !printed_gates.include?(group[:gate_1])
    logic_to_print += logic_groups.select { |lg| lg[:output_gate] == group[:gate_1] }
  end

  if !printed_gates.include?(group[:gate_2])
    logic_to_print += logic_groups.select { |lg| lg[:output_gate] == group[:gate_2] }
  end

  if printed_gates.include?(group[:gate_1]) && printed_gates.include?(group[:gate_2])
    puts print_logic_group(group)
    logic_to_print.delete(group)
    printed_gates << group[:output_gate]
    logic_to_print += logic_groups.select { |lg| lg[:gate_1] == group[:output_gate] || lg[:gate_2] == group[:output_gate] }
  else
    # move it to the end
    logic_to_print.delete(group)
    logic_to_print << group
  end
end

# Final Result - solved manually based on trying numbers and seeing if they broke.
# Swap hdt and z05
# Swap gbf and z09
# Swap jgt and mht
# Swap hbf and z30

array = ["hdt", "z05", "gbf", "z09", "jgt", "mht", "nbf", "z30"]
puts array.sort.join(",")

# Can we solve this purely programatically?
# A few things to check:
# 1. The XOR result of x## and y## should be USED to XOR with the carry from the prior index.
# 2. The XOR result of x## and y## should be USED to AND with the carry from the prior index.
# 3. The AND result of x## and y## should be USED to OR with the result above, to create the carry for the next index.

# So, what if we start at x1. We set the carry to "jfb" manually. Then, for each number,
# we get the XOR and and resutls of the xnumbers and ynumber. We then check it each of the above happens. If not, we print the gate.
puts
puts
last_carry = "jfb"
(1..44).each do |i|
  puts "Testing #{i}"
  x_key = "x#{i.to_s.rjust(2, "0")}"
  y_key = "y#{i.to_s.rjust(2, "0")}"
  z_key = "z#{i.to_s.rjust(2, "0")}"

  # Next, get the two logic groups for the x# and y#
  xor_logic = logic_groups.select { |lg| (lg[:gate_1] == x_key || lg[:gate_2] == x_key) && lg[:logic_string] == "XOR" }.first
  and_logic = logic_groups.select { |lg| (lg[:gate_1] == x_key || lg[:gate_2] == x_key) && lg[:logic_string] == "AND" }.first

  xor_output = xor_logic[:output_gate]
  and_output = and_logic[:output_gate]

  begin

    # Get xor output for carry and x## xor
    z_xor_output = logic_groups.select { |lg| (lg[:gate_1] == xor_output || lg[:gate_2] == xor_output) && (lg[:gate_1] == last_carry || lg[:gate_2] == last_carry) && lg[:logic_string] == "XOR" }.first

    # Get and output for carry and x## and
    carry_and_output_gate = logic_groups.select { |lg| (lg[:gate_1] == xor_output || lg[:gate_2] == xor_output) && (lg[:gate_1] == last_carry || lg[:gate_2] == last_carry) && lg[:logic_string] == "AND" }.first[:output_gate]
    z_or_output = logic_groups.select { |lg| (lg[:gate_1] == carry_and_output_gate || lg[:gate_2] == carry_and_output_gate) && (lg[:gate_1] == and_output || lg[:gate_2] == and_output) && lg[:logic_string] == "OR" }.first

    if z_xor_output.empty? || z_xor_output[:output_gate] != z_key
      puts "Found Error at #{i} for z-result"
      break
    end
    if !carry_and_output_gate || carry_and_output_gate.empty?
      puts "Found Error at #{i} for carry and"
      break
    end
    if z_or_output.empty?
      puts "Found Error at #{i} for z-or"
      break
    end
  rescue
    puts "Hit an error at #{i}"
    break
  end

  carry_gate = z_or_output[:output_gate]
  last_carry = carry_gate
  # x_value = value_hash[x_key]
  # y_value = value_hash[y_key]
  # z_value = value_hash[z_key]

  # xor_result = x_value ^ y_value
  # and_result = x_value & y_value
  # or_result = and_result | xor_result

  # if xor_result != value_hash[last_carry]
  #   puts "XOR Mismatch: #{x_key} #{y_key} -> #{z_key}"
  # end

  # if and_result != value_hash[z_key]
  #   puts "AND Mismatch: #{x_key} #{y_key} -> #{z_key}"
  # end

  # if or_result != value_hash[z_key]
  #   puts "OR Mismatch: #{x_key} #{y_key} -> #{z_key}"
  # end

  # last_carry = z_key
  # current_number += 1
end

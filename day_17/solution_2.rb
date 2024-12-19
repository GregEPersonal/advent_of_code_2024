# Solution for Day 17

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_17/test_input_4.txt")

# Solution logic
# Okay, create the registers
registers = { a: 0, b: 0, c: 0 }

# Create the program
program = []

# Get the number at the end of the line
# Format: Register A: 729
def parse_register_line(line)
  start = line.index(":") + 2
  line[start..].to_i
end

# Get the instruction and argument
# Program: 0,1,5,4,3,0
def parse_program_lines(line)
  start = line.index(":") + 2
  line[start..].split(",").map(&:to_i)
end

def combo_argument(unparsed_argument, registers)
  case unparsed_argument
  when 0..3
    unparsed_argument
  when 4
    registers[:a]
  when 5
    registers[:b]
  when 6
    registers[:c]
  when 7
    puts "ERROR: Invalid argument"
    7
  end
end

def instruction_string(argument_id)
  case argument_id
  when 0
    "adv"
  when 1
    "bxl"
  when 2
    "bst"
  when 3
    "jnz"
  when 4
    "bxc"
  when 5
    "out"
  when 6
    "bdv"
  when 7
    "cdv"
  end
end

#The adv instruction (opcode 0) performs division.
#The numerator is the value in the A register.
#The denominator is found by raising 2 to the power of the instruction's combo operand.
#(So, an operand of 2 would divide A by 4 (2^2); an operand of 5 would divide A by 2^B.)
#The result of the division operation is truncated to an integer and then written to the A register.
def process_adv(unparsed_argument, registers)
  argument = combo_argument(unparsed_argument, registers)
  new_arg = (2 ** argument)
  registers[:a] = registers[:a] / new_arg
end

# The bxl instruction (opcode 1) calculates the bitwise XOR of register B
# and the instruction's literal operand,
# then stores the result in register B.
def process_bxl(unparsed_argument, registers)
  argument = unparsed_argument # Literal value
  registers[:b] = registers[:b] ^ argument
end

# The bst instruction (opcode 2) calculates the value of its combo operand modulo 8
# (thereby keeping only its lowest 3 bits), then writes that value to the B register.
def process_bst(unparsed_argument, registers)
  argument = combo_argument(unparsed_argument, registers)
  registers[:b] = argument % 8
end

# The jnz instruction (opcode 3) does nothing if the A register is 0.
# However, if the A register is not zero, it jumps by setting the instruction
# pointer to the value of its literal operand; if this instruction jumps,
# the instruction pointer is not increased by 2 after this instruction.
def process_jnz(unparsed_argument, registers)
  argument = unparsed_argument # Literal value
  return argument if registers[:a] != 0
  return nil
end

# The bxc instruction (opcode 4) calculates the bitwise XOR of register B and register C,
# then stores the result in register B. (For legacy reasons,
# this instruction reads an operand but ignores it.)
def process_bxc(unparsed_argument, registers)
  registers[:b] = registers[:b] ^ registers[:c]
end

# The out instruction (opcode 5) calculates the value of its combo operand modulo 8,
# then outputs that value.
# (If a program outputs multiple values, they are separated by commas.)
def process_out(unparsed_argument, registers)
  argument = combo_argument(unparsed_argument, registers)
  # print (argument % 8).to_s + ","
  return (argument % 8).to_s
end

# The bdv instruction (opcode 6) works exactly like the adv instruction
# except that the result is stored in the B register.
# (The numerator is still read from the A register.)
def process_bdv(unparsed_argument, registers)
  argument = combo_argument(unparsed_argument, registers)
  new_arg = (2 ** argument)
  registers[:b] = registers[:a] / new_arg
end

# The cdv instruction (opcode 7) works exactly like the adv instruction
# except that the result is stored in the C register.
# (The numerator is still read from the A register.)
def process_cdv(unparsed_argument, registers)
  argument = combo_argument(unparsed_argument, registers)
  new_arg = (2 ** argument)
  registers[:c] = registers[:a] / new_arg
end

# Parse through the lines and store the program
registers[:a] = parse_register_line(lines[0])
registers[:b] = parse_register_line(lines[1])
registers[:c] = parse_register_line(lines[2])

program = parse_program_lines(lines[4])

def process_instruction(instruction, argument, registers, instruction_pointer)
  output = nil
  case instruction
  when 0
    process_adv(argument, registers)
  when 1
    process_bxl(argument, registers)
  when 2
    process_bst(argument, registers)
  when 3
    result = process_jnz(argument, registers)
    # Just always let it always go to 16.
  when 4
    process_bxc(argument, registers)
  when 5
    output = process_out(argument, registers)
  when 6
    process_bdv(argument, registers)
  when 7
    process_cdv(argument, registers)
  end

  return instruction_pointer + 2, output
end

# Basic loop here.
# Process an instruction, update the registers, then move to the next instruction
# i = 0
# while i < program.length
#   # puts "Processing instruction #{i}"
#   # puts "Registers: #{registers}"
#   instruction = program[i]
#   argument = program[i + 1]

#   i = process_instruction(instruction, argument, registers, i)
# end

# puts
# puts "Completed program"

# OKay, so I think we effectively want to work backwards from the end point.
# Hmm, no, the jump not zero ruins that...
# Program: 2,4,1,5,7,5,0,3,4,1,1,6,5,5,3,0
# Registers: {:a=>47719761, :b=>0, :c=>0}
#
# Okay, so this is:
# bst 4 # b = A % 8 (Final round: A is between 1 and 7, C is 0 or 1, b is between 1 and 8)
# bxl 5 # b = b XOR 5 (101) (B is still between 1 and 8)
# cdv 5 # c = a / 2^B (C is now 0) same as shifting over 5?
# adv 3 # a = a / 2^3 ( A is now 0)
# bxc 1 # b = b XOR c (b is still b)
# bxl 6 # b = b XOR 6 (110)  (b is now b & 110)
# out 5 # puts b register % 8
# jnz 0 # jnz a register
#
#
#So we can work backwards on each loop?
# So each round, a gets divided by 8.
# So it's between 8^14 and 8^15?
# Let's see, 8 to 63 in A would get you 2 rounds.
#
# So on the final round, a is between 1 and 8. C is 0.
# On the second last round, a is between 8 and 63. C is 0 or 1.
# On the third last round, a is between 64 and 511. C is between 2 and 15.

# So at one step before the final round, it.s {a: 3, b: 3, c: 0}

# ADV - only called with literal, so this is okay
def process_reverse_adv(unparsed_argument, registers)
  argument = combo_argument(unparsed_argument, registers)
  # registers[:a] = registers[:a] * (2 ** argument)
end

# BXL
def process_reverse_bxl(unparsed_argument, registers)
  argument = unparsed_argument # Literal value
  registers[:b] = registers[:b] ^ argument
end

# bst - INCOMPLETE. THIS COULD BE anywhere from * 8 to * 8 + 7
def process_reverse_bst(unparsed_argument, registers)
  argument = combo_argument(unparsed_argument, registers)
  # Let's go ahead and do nothing here. - we'll do it manually
end

# jnx - basically ignore this
def process_reverse_jnz(unparsed_argument, registers)
  return nil
end

# bxc
def process_reverse_bxc(unparsed_argument, registers)
  registers[:b] = registers[:b] ^ registers[:c]
end

# out
# # The out instruction (opcode 5) calculates the value of its combo operand modulo 8,
# then outputs that value.
# (If a program outputs multiple values, they are separated by commas.)
def process_reverse_out(unparsed_argument, registers)
  argument = combo_argument(unparsed_argument, registers)
  print (argument % 8).to_s + ","
end

# bdv
def process_reverse_bdv(unparsed_argument, registers)
  argument = combo_argument(unparsed_argument, registers)
  new_arg = (2 ** argument)
  registers[:a] = registers[:b] * new_arg
end

# cdv
def process_reverse_cdv(unparsed_argument, registers)
  argument = combo_argument(unparsed_argument, registers)
  # new_arg = (2 ** argument)
  # registers[:c] = registers[:a] * new_arg
end

def process_reverse_instruction(instruction, argument, registers, instruction_pointer)
  case instruction
  when 0
    process_reverse_adv(argument, registers)
  when 1
    process_reverse_bxl(argument, registers)
  when 2
    process_reverse_bst(argument, registers)
  when 3
    result = process_reverse_jnz(argument, registers)
    return result if result
  when 4
    process_reverse_bxc(argument, registers)
  when 5
    process_reverse_out(argument, registers)
  when 6
    process_reverse_bdv(argument, registers)
  when 7
    process_reverse_cdv(argument, registers)
  end

  return instruction_pointer - 2
end

# So, work backwards, one round at at time.
# Ending inputs is that c is 0,

#end state of the registers:

# Last instruction is 14 (for jnz 0)
# registers[:a] = 0
# registers[:b] = 0
# registers[:c] = 0

# program.reverse.each_with_index do |output_number, round_count|
#   registers[:b] = output_number
#   registers[:c] = registers[:a] * 8 / 32

#   puts "Round #{round_count + 1}"
#   puts "Starting with a: #{registers[:a]}, b: #{registers[:b]}, c: #{registers[:c]}"

#   i = 14
#   while (i >= 0)
#     # puts "Processing instruction #{i}"
#     # puts "Registers: #{registers}"
#     instruction = program[i]
#     argument = program[i + 1]
#     # puts "Instruction: #{instruction_string(instruction)}, Argument: #{argument}"
#     # puts
#     i = process_reverse_instruction(instruction, argument, registers, i)
#   end

#   registers[:a] = registers[:a] * 8 + (registers[:b] % 8)
#   puts "Ending with a: #{registers[:a]}, b: #{registers[:b]}, c: #{registers[:c]}"
#   puts
# end

# After Round 16  {a: 0, b: 0, c: 0}
# After Round 15  {a: 3, b: 3, c: 0}

def attempt_number(program, reverse_goal_index, starting_a = 0)
  if reverse_goal_index == program.length
    return starting_a
  end

  registers = { a: starting_a, b: 0, c: 0 }

  successful_results = []
  goal = program.reverse[reverse_goal_index]

  (0..7).each do |output_number|
    a_test = starting_a + output_number
    next if a_test == 0
    registers[:a] = a_test
    registers[:b] = 0
    registers[:c] = 0

    i = 0
    output = ""

    # puts "Round #{output_number + 1}"
    while i < program.length
      # puts "Processing instruction #{i}"
      # puts "Registers: #{registers}"
      instruction = program[i]
      argument = program[i + 1]

      i, partial_output = process_instruction(instruction, argument, registers, i)
      output += partial_output if partial_output
    end
    # puts "Testing #{a_test}"
    # puts "Goal: #{instruction}"
    # puts "Output: #{output}"

    if output == goal.to_s
      puts "Found it!"
      puts "Number: #{a_test}"
      puts "Output: #{output}"
      puts "Testing array of: #{program.reverse[..reverse_goal_index]}"
      puts
      successful_results << a_test
    end
  end

  return nil if successful_results.empty?

  successful_results.each do |result|
    next_attempt = attempt_number(program, reverse_goal_index + 1, result * 8)
    return next_attempt if next_attempt
  end
  # binding.pry

  return nil
end

# Totally new attempt.
#
# Basic loop here.
# Process an instruction, update the registers, then move to the next instruction

# Okay, we're going to loop backwards, and try each of the possible values for the last output.

result = attempt_number(program, 0, 0)

# program.reverse.each_with_index do |goal_instruction, instruction_index|
#   # Default a value for this next round

#   successful_numbers = attempt_number(registers, program, goal_instruction, instruction_index)
# end

puts "Result: #{result}"
puts "Completed program"

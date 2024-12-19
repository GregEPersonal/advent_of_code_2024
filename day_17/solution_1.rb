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
  print (argument % 8).to_s + ","
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
  case instruction
  when 0
    process_adv(argument, registers)
  when 1
    process_bxl(argument, registers)
  when 2
    process_bst(argument, registers)
  when 3
    result = process_jnz(argument, registers)
    return result if result
  when 4
    process_bxc(argument, registers)
  when 5
    process_out(argument, registers)
  when 6
    process_bdv(argument, registers)
  when 7
    process_cdv(argument, registers)
  end

  return instruction_pointer + 2
end

# Basic loop here.
# Process an instruction, update the registers, then move to the next instruction
i = 0
while i < program.length
  # puts "Processing instruction #{i}"
  # puts "Registers: #{registers}"
  instruction = program[i]
  argument = program[i + 1]

  i = process_instruction(instruction, argument, registers, i)

  if i == 14
    # puts
  end
end

puts
puts "Completed program"

# Solution for Day 13

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_13/input.txt")

# Partse the button line int othe x and y
# Button A: X+94, Y+34
# Button B: X+22, Y+67
def parse_button_line(line)
  x_start = line.index("X+") + 2
  x_end = line.index(",", x_start)
  x = line[x_start, x_end].to_i

  y_start = line.index("Y+") + 2
  y_end = line.length
  y = line[y_start, y_end].to_i
  return x, y
end

# Parse the prize line
# Prize: X=8400, Y=5400
def parse_prize_line(line)
  x_start = line.index("X=") + 2
  x_end = line.index(",", x_start)
  x = line[x_start, x_end].to_i

  y_start = line.index("Y=") + 2
  y_end = line.length
  y = line[y_start, y_end].to_i
  return x, y
end

# Solution logic
line_count = 0
claw_machines = []
claw_machines_index = 0

# Read it in.
lines.each do |line|
  if line_count == 0
    x, y = parse_button_line(line)
    claw_machines[claw_machines_index] = {}
    claw_machines[claw_machines_index][:a] = [x, y]
  elsif line_count == 1
    x, y = parse_button_line(line)
    claw_machines[claw_machines_index][:b] = [x, y]
  elsif line_count == 2
    x, y = parse_prize_line(line)
    x += 10000000000000
    y += 10000000000000
    claw_machines[claw_machines_index][:prize] = [x, y]
  else
    claw_machines_index += 1
  end
  line_count = (line_count + 1) % 4
end

# puts claw_machines

a_total = 0
b_total = 0

# Do the math. Solved by hand.
claw_machines.each do |claw_machine|
  ax, ay = claw_machine[:a]
  bx, by = claw_machine[:b]
  px, py = claw_machine[:prize]
  b2 = (py * ax - ay * px) * 1.0 / (by * ax - ay * bx)
  b1 = (px - bx * b2) * 1.0 / ax
  # puts "For claw_machine #{claw_machine}"
  # puts b1, b2

  # Check if b1 and b2 are actually integers
  if b1 % 1 == 0 && b2 % 1 == 0
    # puts "Found a solution: #{b1}, #{b2}"
    a_total += b1
    b_total += b2
  end
end

# puts a_total, b_total
puts a_total * 3 + b_total

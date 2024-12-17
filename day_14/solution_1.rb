# Solution for Day 14

require_relative "../utils"
require "pry"

test = false

# Read input lines
file = test ? "day_14/test_input.txt" : "day_14/input.txt"
lines = read_input_lines(file)

width = test ? 11 : 101
height = test ? 7 : 103

# Parsing
# p=0,4 v=3,-3
def parse_robot_line(line)
  x_mid_point = line.index(",")
  px = line[2, x_mid_point - 2].to_i
  py = line[x_mid_point + 1, line.index(" ") - x_mid_point - 1].to_i

  v_start = line.index("v=")
  v_mid_point = line.index(",", v_start)
  vx = line[v_start + 2, v_mid_point - v_start - 2].to_i
  vy = line[v_mid_point + 1, line.length - v_mid_point - 1].to_i

  # puts line
  # puts px, py, vx, vy

  return [px, py, vx, vy]
end

def quadrant_count(robot_future_locations, min_x, max_x, min_y, max_y)
  total = 0
  (min_y..max_y).each do |y|
    (min_x..max_x).each do |x|
      total += robot_future_locations[y][x]
    end
  end
  total
end

def print_robots(grid)
  grid.each do |row|
    row.each do |cell|
      print cell
    end
    puts
  end
end

robot_count = lines.length

robots = Array.new(robot_count) { [] }

# Solution logic
lines.each_with_index do |line, index|
  robots[index] = parse_robot_line(line)
end

# print robots
# puts

# Iterate through robots, and calculate where they will be at 100 seconds.
# Then, put them on a grid
robot_future_locations = Array.new(height) { Array.new(width) { 0 } }
number_seconds = 100

robots.each do |x, y, vx, vy|
  new_x = (x + 100 * vx) % width
  new_y = (y + 100 * vy) % height

  robot_future_locations[new_y][new_x] += 1
end

print_robots(robot_future_locations)

quadrant_1 = quadrant_count(robot_future_locations, 0, width / 2 - 1, 0, height / 2 - 1) # Top left
quadrant_2 = quadrant_count(robot_future_locations, width / 2 + 1, width - 1, 0, height / 2 - 1) #Top right
quadrant_3 = quadrant_count(robot_future_locations, 0, width / 2 - 1, height / 2 + 1, height - 1) #bottom left
quadrant_4 = quadrant_count(robot_future_locations, width / 2 + 1, width - 1, height / 2 + 1, height - 1) # Bottom right

puts quadrant_1 * quadrant_2 * quadrant_3 * quadrant_4

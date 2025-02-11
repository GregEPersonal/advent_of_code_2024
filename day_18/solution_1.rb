# Solution for Day 18

require_relative "../utils"
require "pry"

# Read input lines
is_test = false
file = is_test ? "day_18/test_input.txt" : "day_18/input.txt"
lines = read_input_lines(file)

# Solution logic

# Okay, it's a map. Write the width and height
# Then parse through char by char

width = is_test ? 7 : 71
height = width

# Create a 2D array to store the map
map = Array.new(height) { Array.new(width) { "." } }

# Store the start and end points
start_point = [0, 0]
end_point = is_test ? [6, 6] : [70, 70]

byte_limit = is_test ? 12 : 1024

# Parse through the lines and store the map
lines.each_with_index do |line, y|
  break if y >= byte_limit
  x, y = line.split(",").map(&:to_i)
  map[y][x] = "#"
end

def print_map(map)
  map.each do |row|
    puts row.join("")
  end
end

print_map(map)
# A* again I guess!

# We'll start by creating the open and closed sets
open_set = []
closed_set = {}

open_set << { x: start_point[0], y: start_point[1], cost: 0 }

# We'll create a helper function to calculate the cost of a point
# The cost of a point is the cost of the previous point plus 1
def cost_of_point(point, previous_point)
  return previous_point[:cost] + 1
end

# We'll create a helper function to check if a point is valid
# A point is valid if it's within the bounds of the map and not a wall
# We'll also check if the point is in the closed set
# If it is, we'll only consider it if the new cost is lower
def valid_point?(point, previous_point, map, closed_set)
  width = map[0].length
  height = map.length
  return false if point[:x] < 0 || point[:x] >= width || point[:y] < 0 || point[:y] >= height
  return false if map[point[:y]][point[:x]] == "#"
  return false if closed_set.key?([point[:x], point[:y]]) && closed_set[[point[:x], point[:y]]] <= point[:cost]
  return true
end

# We'll create a helper function to check if a point is the end point
def end_point?(point, end_point)
  return point[:x] == end_point[0] && point[:y] == end_point[1]
end

# Okay, let's start the main loop
# The real issue with this code is that it's directionless.
# It should really be calculating how close it is to the end point, and then moving in that direction.
success = false
while open_set.length > 0
  if open_set.length % 10 == 0
    puts open_set.length
    # puts "Current open set:"
    # open_set.each do |point|
    #   puts "#{point[:x]}, #{point[:y]}: #{point[:cost]}"
    # end
    # binding.pry
  end
  # We'll get the point with the lowest cost from the open set
  current_point = open_set.min_by { |point| point[:cost] }

  # We'll check if this is the end point
  if end_point?(current_point, end_point)
    puts current_point[:cost]
    success = true
    break
  end

  # We'll remove the current point from the open set
  open_set.delete(current_point)

  # We'll add the current point to the closed set
  closed_set[[current_point[:x], current_point[:y]]] = current_point[:cost]

  # We'll check the options for moving in each direction
  # We'll add the new points to the open set
  # We'll only consider points that are valid
  # We'll only consider points that are not in the closed set, or have a lower cost
  # We'll add the new points to the open set
  # We'll also keep track of the previous point
  previous_point = current_point

  # Straight path
  x = previous_point[:x]
  y = previous_point[:y]

  point_left = { x: x - 1, y: y, cost: previous_point[:cost] + 1 }
  point_right = { x: x + 1, y: y, cost: previous_point[:cost] + 1 }
  point_up = { x: x, y: y - 1, cost: previous_point[:cost] + 1 }
  point_down = { x: x, y: y + 1, cost: previous_point[:cost] + 1 }

  open_set << point_left if valid_point?(point_left, previous_point, map, closed_set)
  open_set << point_right if valid_point?(point_right, previous_point, map, closed_set)
  open_set << point_up if valid_point?(point_up, previous_point, map, closed_set)
  open_set << point_down if valid_point?(point_down, previous_point, map, closed_set)
end

puts "No path found" unless success

# Solution for Day 20

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_20/input.txt")

# Solution logic

# FROM DAY 16
# Okay, it's a map. Write the width and height
# Then parse through char by char

width = lines[0].length
height = lines.length

# Create a 2D array to store the map
map = Array.new(height) { Array.new(width) }

# Store the start and end points
start_point = nil
end_point = nil

# Parse through the lines and store the map
lines.each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    map[y][x] = char
    if char == "S"
      start_point = [x, y]
    elsif char == "E"
      end_point = [x, y]
    end
  end
end

def print_map(map)
  map.each do |row|
    puts row.join("")
  end
end

# FROM DAY 18
# A* again I guess!

# We'll create a helper function to calculate the cost of a point
# The cost of a point is the cost of the previous point plus 1
def cost_of_point(point, previous_point)
  return previous_point[:cost] + 1
end

# Heuristic function to estimate the cost from the current point to the end point
def heuristic(point, end_point)
  return (point[:x] - end_point[0]).abs + (point[:y] - end_point[1]).abs
end

# We'll create a helper function to check if a point is valid
# A point is valid if it's within the bounds of the map and not a wall
# We'll also check if the point is in the closed set
# If it is, we'll only consider it if the new cost is lower
def valid_point?(point, previous_point, map, closed_set, open_set)
  width = map[0].length
  height = map.length
  return false if point[:x] < 0 || point[:x] >= width || point[:y] < 0 || point[:y] >= height
  return false if map[point[:y]][point[:x]] == "#"
  return false if closed_set.key?([point[:x], point[:y]]) && closed_set[[point[:x], point[:y]]] <= point[:cost]
  return false if open_set.any? { |open_point| open_point[:x] == point[:x] && open_point[:y] == point[:y] && open_point[:cost] <= point[:cost] }
  return true
end

# We'll create a helper function to check if a point is the end point
def end_point?(point, end_point)
  return point[:x] == end_point[0] && point[:y] == end_point[1]
end

def print_map_with_path(map, path)
  path_map = map.map(&:clone)
  path.each do |point|
    path_map[point[1]][point[0]] = "O"
  end
  print_map(path_map)
end

# Okay, let's start the main loop
# The real issue with this code is that it's directionless.
# It should really be calculating how close it is to the end point, and then moving in that direction.
def solve_maze(map, width, height, start_point, end_point)

  # We'll start by creating the open and closed sets
  open_set = []
  closed_set = {}

  open_set << { x: start_point[0], y: start_point[1], cost: 0, path: [[start_point[0], start_point[1]]] }

  success = false
  final_path = nil
  while open_set.length > 0
    if open_set.length % 40 == 0
      puts open_set.length
    end
    # We'll get the point with the lowest cost + heuristic from the open set
    current_point = open_set.min_by { |point| point[:cost] }

    # We'll check if this is the end point
    if end_point?(current_point, end_point)
      puts current_point[:cost]
      success = true
      final_path = current_point[:path]
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

    # point_left = { x: x - 1, y: y, cost: previous_point[:cost] + 1 }
    # point_right = { x: x + 1, y: y, cost: previous_point[:cost] + 1 }
    # point_up = { x: x, y: y - 1, cost: previous_point[:cost] + 1 }
    # point_down = { x: x, y: y + 1, cost: previous_point[:cost] + 1 }
    point_left = { x: x - 1, y: y, cost: previous_point[:cost] + 1, path: previous_point[:path] + [[x - 1, y]] }
    point_right = { x: x + 1, y: y, cost: previous_point[:cost] + 1, path: previous_point[:path] + [[x + 1, y]] }
    point_up = { x: x, y: y - 1, cost: previous_point[:cost] + 1, path: previous_point[:path] + [[x, y - 1]] }
    point_down = { x: x, y: y + 1, cost: previous_point[:cost] + 1, path: previous_point[:path] + [[x, y + 1]] }

    open_set << point_left if valid_point?(point_left, previous_point, map, closed_set, open_set)
    open_set << point_right if valid_point?(point_right, previous_point, map, closed_set, open_set)
    open_set << point_up if valid_point?(point_up, previous_point, map, closed_set, open_set)
    open_set << point_down if valid_point?(point_down, previous_point, map, closed_set, open_set)
  end

  if success
    # print_map_with_path(map, final_path)
  else
    puts "No path found"
  end

  return success, final_path
end

success, final_path = solve_maze(map, width, height, start_point, end_point)
puts "Final Path length: #{final_path.length}"

print_map(map)

# OKay, so we want to measure the shortcuts.
# We're going to iterate through the final_path.
# For each one, we're going to see if there is a wall in each of the four directions
# IF there is, we're going to then check if the space beyond is a wall.
# If it is NOT, then we'll look it up in the final path, and get the index.
# The shortcut length is the difference in index between the two.
# We then track all of the shortcut lengths, and return the count over 100.

shortcuts = []

#Create faster lookup for final path. Transform it to a hash with the value as the index
final_path_hash = {}
final_path.each_with_index do |point, index|
  final_path_hash[point] = index
end

# Check for shortcuts
final_path.each_with_index do |point, index|
  x = point[0]
  y = point[1]

  # Check left
  if x > 1 && map[y][x - 1] == "#"
    if map[y][x - 2] == "." || map[y][x - 2] == "E"
      shortcut_index = final_path_hash[[x - 2, y]]
      shortcut_length = (shortcut_index - index) - 2

      shortcuts << shortcut_length if shortcut_length > 0
    end
  end

  # Check right
  if x < width - 2 && map[y][x + 1] == "#"
    if map[y][x + 2] == "."
      shortcut_index = final_path_hash[[x + 2, y]]
      shortcut_length = (shortcut_index - index) - 2
      shortcuts << shortcut_length if shortcut_length > 0
    end
  end

  # Check up
  if y > 1 && map[y - 1][x] == "#"
    if map[y - 2][x] == "."
      shortcut_index = final_path_hash[[x, y - 2]]
      shortcut_length = (shortcut_index - index) - 2
      shortcuts << shortcut_length if shortcut_length > 0
    end
  end

  # Check down
  if y < height - 2 && map[y + 1][x] == "#"
    if map[y + 2][x] == "."
      shortcut_index = final_path_hash[[x, y + 2]]
      shortcut_length = (shortcut_index - index) - 2
      shortcuts << shortcut_length if shortcut_length > 0
    end
  end
end

goal_shortcut_length = 100
puts "Shortcuts over #{goal_shortcut_length}: #{shortcuts.count { |shortcut| shortcut >= goal_shortcut_length }}"

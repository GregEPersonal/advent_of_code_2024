# Solution for Day 16

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_16/input.txt")

# Solution logic

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

# Starting Direction is always east
initial_direction = "east"

def print_map(map)
  map.each do |row|
    puts row.join("")
  end
end

# We're going to basically use a standard A* algorithm

# AI Suggestion:
# We'll keep track of the current position, the path taken, and the cost
# We'll also keep track of the open and closed sets
# The open set will be a priority queue, with the lowest cost path at the front
# The closed set will be a hash, with the key being the position and the value being the cost

# We'll start by adding the start point to the open set
# We'll then iterate through the open set, and for each point,
# we'll check the options of go forward, turn clockwise, or turn counterclockwise
# We'll add the new points to the open set, and remove the current point from the open set
# We'll add the current point to the closed set
# We'll continue until we reach the end point
# We'll then return the cost of the end point

# We'll start by creating the open and closed sets
open_set = []
closed_set = {}

# We'll start by adding the start point to the open set
open_set << { x: start_point[0], y: start_point[1], direction: initial_direction, cost: 0, paths: [[[start_point[0], start_point[1], initial_direction]]] }

# We'll create a helper function to calculate the cost of a point
# The cost of a point is the cost of the previous point plus 1 if it's a straight path, or 1000 if it's a turn
def cost_of_point(point, previous_point)
  return previous_point[:cost] + 1 if point[:direction] == previous_point[:direction]
  return previous_point[:cost] + 1000
end

# We'll create a helper function to check if a point is valid
# A point is valid if it's within the bounds of the map and not a wall
# We'll also check if the point is in the closed set
# If it is, we'll only consider it if the new cost is lower
def valid_point?(point, previous_point, map, closed_set, open_set)
  width = map[0].length
  height = map.length
  return -1 if point[:x] < 0 || point[:x] >= width || point[:y] < 0 || point[:y] >= height
  return -1 if map[point[:y]][point[:x]] == "#"
  return -1 if closed_set.key?([point[:x], point[:y], point[:direction]]) && closed_set[[point[:x], point[:y], point[:direction]]] <= point[:cost]
  # return 0 if closed_set.key?([point[:x], point[:y], point[:direction]]) && closed_set[[point[:x], point[:y], point[:direction]]] == point[:cost]
  return -1 if open_set.any? { |open_point| open_point[:x] == point[:x] && open_point[:y] == point[:y] && open_point[:direction] == point[:direction] && open_point[:cost] < point[:cost] }
  return 0 if open_set.any? { |open_point| open_point[:x] == point[:x] && open_point[:y] == point[:y] && open_point[:direction] == point[:direction] && open_point[:cost] == point[:cost] }

  return 1
end

# We'll create a helper function to check if a point is the end point
def end_point?(point, end_point)
  return point[:x] == end_point[0] && point[:y] == end_point[1]
end

# We'll create a helper function to update the paths
def update_paths(current_paths, new_point)
  new_paths = []
  current_paths.each do |path|
    new_paths << path + [new_point]
  end
  return new_paths
end

# We'll create a helper function to update the paths of an equivalent point in the open or closed sets
def update_equivalent_point_paths(new_point, new_paths, open_set)
  # Check in the open set
  if open_set.any? { |open_point| open_point[:x] == new_point[:x] && open_point[:y] == new_point[:y] && open_point[:direction] == new_point[:direction] && open_point[:cost] == new_point[:cost] }
    equivalent_point = open_set.find { |open_point| open_point[:x] == new_point[:x] && open_point[:y] == new_point[:y] && open_point[:direction] == new_point[:direction] && open_point[:cost] == new_point[:cost] }
    if equivalent_point
      equivalent_point[:paths] += new_paths
    end
  end
end

# Okay, let's start the main loop
# The real issue with this code is that it's directionless.
# It should really be calculating how close it is to the end point, and then moving in that direction.
#
# This is now an array of arrays. We'll keep track of all paths that could be used to get there.
final_paths = nil

while open_set.length > 0
  if open_set.length % 10 == 0
    puts open_set.length
  end
  # We'll get the point with the lowest cost from the open set
  current_point = open_set.min_by { |point| point[:cost] }

  # We'll check if this is the end point
  if end_point?(current_point, end_point)
    puts current_point[:cost]
    final_paths = current_point[:paths]
    break
  end

  # We'll remove the current point from the open set
  open_set.delete(current_point)

  # We'll add the current point to the closed set
  closed_set[[current_point[:x], current_point[:y], current_point[:direction]]] = current_point[:cost]

  # We'll check the options of go forward, turn clockwise, or turn counterclockwise
  # We'll add the new points to the open set
  # We'll only consider points that are valid
  # We'll only consider points that are not in the closed set, or have a lower cost
  # We'll add the new points to the open set
  # We'll also keep track of the previous point
  previous_point = current_point

  # Straight path
  coord_change = { "north" => [0, -1], "south" => [0, 1], "east" => [1, 0], "west" => [-1, 0] }
  new_x = previous_point[:x] + coord_change[previous_point[:direction]][0]
  new_y = previous_point[:y] + coord_change[previous_point[:direction]][1]
  new_paths = update_paths(previous_point[:paths], [new_x, new_y, previous_point[:direction]])
  new_point = { x: new_x, y: new_y, direction: previous_point[:direction], cost: cost_of_point({ x: new_x, y: new_y, direction: previous_point[:direction] }, previous_point), paths: new_paths }
  straight_result = valid_point?(new_point, previous_point, map, closed_set, open_set)
  if straight_result == 1
    open_set << new_point
  elsif straight_result == 0
    update_equivalent_point_paths(new_point, new_paths, open_set)
  end

  # Clockwise path
  clockwise_direction = { "north" => "east", "east" => "south", "south" => "west", "west" => "north" }
  new_paths = update_paths(previous_point[:paths], [previous_point[:x], previous_point[:y], clockwise_direction[previous_point[:direction]]])
  new_point = { x: previous_point[:x], y: previous_point[:y], direction: clockwise_direction[previous_point[:direction]], cost: cost_of_point({ x: previous_point[:x], y: previous_point[:y], direction: clockwise_direction[previous_point[:direction]] }, previous_point), paths: new_paths }
  cw_result = valid_point?(new_point, previous_point, map, closed_set, open_set)
  if cw_result == 1
    open_set << new_point
  elsif cw_result == 0
    update_equivalent_point_paths(new_point, new_paths, open_set)
  end

  # Counter-clockwise path
  counter_clockwise_direction = { "north" => "west", "west" => "south", "south" => "east", "east" => "north" }
  new_paths = update_paths(previous_point[:paths], [previous_point[:x], previous_point[:y], counter_clockwise_direction[previous_point[:direction]]])
  new_point = { x: previous_point[:x], y: previous_point[:y], direction: counter_clockwise_direction[previous_point[:direction]], cost: cost_of_point({ x: previous_point[:x], y: previous_point[:y], direction: counter_clockwise_direction[previous_point[:direction]] }, previous_point), paths: new_paths }
  ccw_result = valid_point?(new_point, previous_point, map, closed_set, open_set)
  if ccw_result == 1
    open_set << new_point
  elsif ccw_result == 0
    update_equivalent_point_paths(new_point, new_paths, open_set)
  end
end

path_map = map.map(&:clone)
final_paths.each do |path|
  path.each do |point|
    path_map[point[1]][point[0]] = "O"
  end
end
print_map(path_map)

final_count = 0
path_map.each do |row|
  final_count += row.count("O")
end

puts "Final Count: #{final_count}"

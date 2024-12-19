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
open_set << { x: start_point[0], y: start_point[1], direction: initial_direction, cost: 0 }

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
def valid_point?(point, previous_point, map, closed_set)
  width = map[0].length
  height = map.length
  return false if point[:x] < 0 || point[:x] >= width || point[:y] < 0 || point[:y] >= height
  return false if map[point[:y]][point[:x]] == "#"
  return false if closed_set.key?([point[:x], point[:y], point[:direction]]) && closed_set[[point[:x], point[:y], point[:direction]]] <= point[:cost]
  return true
end

# We'll create a helper function to check if a point is the end point
def end_point?(point, end_point)
  return point[:x] == end_point[0] && point[:y] == end_point[1]
end

# Okay, let's start the main loop
# The real issue with this code is that it's directionless.
# It should really be calculating how close it is to the end point, and then moving in that direction.
while open_set.length > 0
  if open_set.length % 10 == 0
    puts open_set.length
  end
  # We'll get the point with the lowest cost from the open set
  current_point = open_set.min_by { |point| point[:cost] }

  # We'll check if this is the end point
  if end_point?(current_point, end_point)
    puts current_point[:cost]
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
  new_point = { x: new_x, y: new_y, direction: previous_point[:direction], cost: cost_of_point({ x: new_x, y: new_y, direction: previous_point[:direction] }, previous_point) }
  if valid_point?(new_point, previous_point, map, closed_set)
    open_set << new_point
  end

  # Clockwise path
  clockwise_direction = { "north" => "east", "east" => "south", "south" => "west", "west" => "north" }
  new_point = { x: previous_point[:x], y: previous_point[:y], direction: clockwise_direction[previous_point[:direction]], cost: cost_of_point({ x: previous_point[:x], y: previous_point[:y], direction: clockwise_direction[previous_point[:direction]] }, previous_point) }
  if valid_point?(new_point, previous_point, map, closed_set)
    open_set << new_point
  end

  # Counter-clockwise path
  counter_clockwise_direction = { "north" => "west", "west" => "south", "south" => "east", "east" => "north" }
  new_point = { x: previous_point[:x], y: previous_point[:y], direction: counter_clockwise_direction[previous_point[:direction]], cost: cost_of_point({ x: previous_point[:x], y: previous_point[:y], direction: counter_clockwise_direction[previous_point[:direction]] }, previous_point) }
  if valid_point?(new_point, previous_point, map, closed_set)
    open_set << new_point
  end
end

# ----------------- OLD CODE -----------------
# # Track score array for each point and direction.
# score_array = Array.new(height) { Array.new(width) { { east: Float::INFINITY, west: Float::INFINITY, north: Float::INFINITY, south: Float::INFINITY } } }
# score_array[start_point[1]][start_point[0]]["east"] = 0

# def valid?(x, y, width, height)
#   x >= 0 && x < width && y >= 0 && y < height
# end

# def coord_change_from_direction(direction)
#   case direction
#   when "north"
#     return [0, -1]
#   when "south"
#     return [0, 1]
#   when "east"
#     return [1, 0]
#   when "west"
#     return [-1, 0]
#   end
# end

# def clockwise_direction(direction)
#   case direction
#   when "north"
#     return "east"
#   when "east"
#     return "south"
#   when "south"
#     return "west"
#   when "west"
#     return "north"
#   end
# end

# def counter_clockwise_direction(direction)
#   case direction
#   when "north"
#     return "west"
#   when "west"
#     return "south"
#   when "south"
#     return "east"
#   when "east"
#     return "north"
#   end
# end

# # Inefficient, but it works!
# def check_next_path(map, x, y, direction, score, score_map)
#   return unless valid?(x, y, map[0].length, map.length)
#   puts "Checking: #{x}, #{y}, #{direction}, #{score}"
#   if score < score_map[y][x][direction.to_sym]
#     score_map[y][x][direction.to_sym] = score
#   else
#     return
#   end

#   # Straight path:
#   coord_change = coord_change_from_direction(direction)
#   new_x = x + coord_change[0]
#   new_y = y + coord_change[1]
#   next_char = map[new_y][new_x]
#   if next_char != "#"
#     check_next_path(map, new_x, new_y, direction, score + 1, score_map)
#   end

#   # Clockwise path:
#   new_direction = clockwise_direction(direction)
#   check_next_path(map, x, y, new_direction, score + 1000, score_map)

#   # Counter-clockwise path:
#   new_direction = counter_clockwise_direction(direction)
#   check_next_path(map, x, y, new_direction, score + 1000, score_map)
# end

# #Iterate throught the entire map. Finds minimum to all points
# check_next_path(map, start_point[0], start_point[1], initial_direction, 0, score_array)

# # Get minimum score at end point (regardless of direction)
# min_score = Float::INFINITY
# score_array[end_point[1]][end_point[0]].each do |direction, score|
#   min_score = score if score < min_score
# end

# puts min_score

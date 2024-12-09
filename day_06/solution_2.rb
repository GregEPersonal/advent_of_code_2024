# Solution for Day 6

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_06/input.txt")

# Solution logic
height = lines.count
width = lines[0].strip.length

# Create a 2D array to store the grid

grid = Array.new(height) { Array.new(width, ".") }

guard_x = nil
guard_y = nil
guard_direction = nil

# Fill the grid with the input data
lines.each_with_index do |line, y|
  line.strip.each_char.with_index do |char, x|
    grid[y][x] = char

    if char == "^"
      guard_x = x
      guard_y = y
      guard_direction = "up"
      grid[y][x] = "^"
    end
  end
end

def turn_guard(direction)
  if direction == "up"
    return "right"
  elsif direction == "right"
    return "down"
  elsif direction == "down"
    return "left"
  elsif direction == "left"
    return "up"
  end
end

def print_grid(grid)
  grid.each do |row|
    row.each do |cell|
      print cell
    end
    puts
  end
end

def get_character(guard_direction)
  case guard_direction
  when "up"
    return "^"
  when "down"
    return "v"
  when "right"
    return ">"
  when "left"
    return "<"
  end
end

def change_in_coordinates_based_on_direction(direction)
  case direction
  when "up"
    return [0, -1]
  when "down"
    return [0, 1]
  when "right"
    return [1, 0]
  when "left"
    return [-1, 0]
  end
end

def update_explanatory_grid(grid, guard_x, guard_y, next_guard_x, next_guard_y, guard_direction, width, height)
  if grid[next_guard_y][next_guard_x] == "."
    # Update it to be clear on the guard's path
    grid[next_guard_y][next_guard_x] = get_character(guard_direction)
  elsif ["<", ">", "^", "v", "+"].include? grid[next_guard_y][next_guard_x]
    # Okay, we have been in this space before.
    # Fine, let's just update it.
    if ([">", "<"].include? grid[next_guard_y][next_guard_x]) && (["up", "down"].include?(guard_direction))
      grid[next_guard_y][next_guard_x] = "+"
    elsif (["^", "v"].include? grid[next_guard_y][next_guard_x]) && (["left", "right"].include?(guard_direction))
      grid[next_guard_y][next_guard_x] = "+"
    end
  elsif grid[next_guard_y][next_guard_x] == "#"
    # Okay, we found a wall. Let's turn the guard, and don't add a new spacee
    # guard_direction = turn_guard(guard_direction)
    grid[guard_y][guard_x] = "+"
  end
end

def walk_loop_test(grid, guard_x, guard_y, guard_direction, width, height)
  # Create a 2D array of the same size as the grid.
  # At each node, we store a hash with each direction as a key.
  # This is whether the gaurd has been in that location and direction before.
  existing_guard_locations = Array.new(height) { Array.new(width) { { up: false, right: false, down: false, left: false } } }

  # puts "Testing loop"
  # print_grid(grid)

  while true
    # Adjust the guard's direction
    change_in_guard_x, change_in_guard_y = change_in_coordinates_based_on_direction(guard_direction)
    next_guard_x = guard_x + change_in_guard_x
    next_guard_y = guard_y + change_in_guard_y

    # Check if the guard is out of bounds
    return false if next_guard_x < 0 || next_guard_x >= width || next_guard_y < 0 || next_guard_y >= height

    # Check for infinite loop.
    return true if existing_guard_locations[next_guard_y][next_guard_x][guard_direction.to_sym]

    # Update the guard's location history
    existing_guard_locations[guard_y][guard_x][guard_direction.to_sym] = true

    # update_explanatory_grid(explanatory_grid, guard_x, guard_y, next_guard_x, next_guard_y, guard_direction, width, height)
    # Okay, has no one been there before?
    if grid[next_guard_y][next_guard_x] == "." || grid[next_guard_y][next_guard_x] == "^"

      # Update movement
      guard_x = next_guard_x
      guard_y = next_guard_y
    elsif grid[next_guard_y][next_guard_x] == "#"
      # Okay, we found a wall. Let's turn the guard, and don't add a new spacee
      guard_direction = turn_guard(guard_direction)
    end
  end
end

# print_grid(grid)
# Create a list of potential areas where we could put obstacles.
# We'll store them as [x, y] coordinates
obstacles = []
existing_guard_locations = []
existing_guard_locations.push([guard_x, guard_y]) # Can't be at starting location
explanatory_grid = grid.map(&:clone)
explanatory_grid[guard_y][guard_x] = get_character(guard_direction)
total_step_count = 0

starting_x = guard_x
starting_y = guard_y

# Iterate through
while true
  # Adjust the guard's direction
  change_in_guard_x, change_in_guard_y = change_in_coordinates_based_on_direction(guard_direction)
  next_guard_x = guard_x + change_in_guard_x
  next_guard_y = guard_y + change_in_guard_y

  # Check if the guard is out of bounds
  break if next_guard_x < 0 || next_guard_x >= width || next_guard_y < 0 || next_guard_y >= height

  # update_explanatory_grid(explanatory_grid, guard_x, guard_y, next_guard_x, next_guard_y, guard_direction, width, height)
  # Okay, has no one been there before?
  if grid[next_guard_y][next_guard_x] == "." || grid[next_guard_y][next_guard_x] == "^"

    # Check if you could put an obstacle ahead.
    # We check against CURRENT guard location, as that's where the guard would turn
    if !existing_guard_locations.include?([next_guard_x, next_guard_y])
      if !obstacles.include?([next_guard_x, next_guard_y])
        # New plan. We're going to just run a new guard walk with the map changed.
        new_grid = grid.map(&:clone)
        new_grid[next_guard_y][next_guard_x] = "#"
        if walk_loop_test(new_grid, starting_x, starting_y, "up", width, height)
          # OKay, it's an infinite loop. Let's count hte obstacle.
          obstacles.push([next_guard_x, next_guard_y])
        end
      end
    end

    # Update movement
    guard_x = next_guard_x
    guard_y = next_guard_y
    total_step_count += 1
    existing_guard_locations.push([guard_x, guard_y])
  elsif grid[next_guard_y][next_guard_x] == "#"
    # Okay, we found a wall. Let's turn the guard, and don't add a new spacee
    guard_direction = turn_guard(guard_direction)
  end

  if total_step_count % 100 == 0
    puts "Total step count: #{total_step_count}"
  end
end

puts obstacles.count

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
direction_history = {
  up: Array.new(height) { Array.new(width, ".") },
  down: Array.new(height) { Array.new(width, ".") },
  left: Array.new(height) { Array.new(width, ".") },
  right: Array.new(height) { Array.new(width, ".") },
}

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
      grid[y][x] = "."
      direction_history[:up][y][x] = "x"
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

# OKay, we are evaluating whether a specific point in the grid could have an obstacle.
# We are going to take a point in the grid, and the current guard_direction.
# We then see if the guard turned, if they would run into their prior path
# In the same direction as they have already walked. This must take place
# Before they hit an existing obstacle.
# The obstacle itself is before the guard's path
def evaluate_obstacle(grid, direction_history, x, y, guard_direction, width, height, explanatory_grid = nil)
  # We already know that the space is NOT an obstacle.
  direction_to_evaluate = turn_guard(guard_direction)
  change_in_guard_x, change_in_guard_y = change_in_coordinates_based_on_direction(direction_to_evaluate)

  # puts "Evaluating obstacle at #{x}, #{y} with direction #{guard_direction}"
  # Now, we iterate through the grid and the direction history
  # to see if the guard would run into their own path or an obstacle
  next_x = x
  next_y = y

  # Track where we've checked, in case of infinite loops
  obstacle_path_list = []

  while true
    next_x = next_x + change_in_guard_x
    next_y = next_y + change_in_guard_y
    step_count += 1

    # Check if the guard is out of bounds
    break if next_x < 0 || next_x >= width || next_y < 0 || next_y >= height

    # Check if we've been here before
    # In case loops work weird, let's count if we've been here at least 10 times.
    if obstacle_path_list.include? [next_x, next_y, direction_to_evaluate]
      puts "Aborting due to infinite loop"
      return false
    end

    # Check if the guard would run into an obstacle
    if grid[next_y][next_x] == "#"
      # Just walk back the change. Could do this the same as the main loop, but it's already written.
      next_x = next_x - change_in_guard_x
      next_y = next_y - change_in_guard_y

      direction_to_evaluate = turn_guard(direction_to_evaluate)
      change_in_guard_x, change_in_guard_y = change_in_coordinates_based_on_direction(direction_to_evaluate)
    end

    obstacle_path_list.push([next_x, next_y, direction_to_evaluate])

    # Check if the guard would run into their own path
    if direction_history[direction_to_evaluate.to_sym][next_y][next_x] == "x"
      return true
    end
  end

  # puts "Step Count:" + step_count.to_s
  return false
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

# print_grid(grid)
# Create a list of potential areas where we could put obstacles.
# We'll store them as [x, y] coordinates
obstacles = []
existing_guard_locations = []
existing_guard_locations.push([guard_x, guard_y]) # Can't be at starting location
explanatory_grid = grid.map(&:clone)
explanatory_grid[guard_y][guard_x] = get_character(guard_direction)
total_step_count = 0

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
  if grid[next_guard_y][next_guard_x] == "."

    # Check if you could put an obstacle ahead.
    # We check against CURRENT guard location, as that's where the guard would turn
    if !existing_guard_locations.include?([next_guard_x, next_guard_y])
      if !obstacles.include?([next_guard_x, next_guard_y])
        if evaluate_obstacle(grid, direction_history, guard_x, guard_y, guard_direction, width, height)
          # We can put an obstacle here - check to make sure there isn't already one in the obstacles array
          obstacles.push([next_guard_x, next_guard_y])
          # obstacle_grid = explanatory_grid.map(&:clone)
          # obstacle_grid[next_guard_y][next_guard_x] = "O"
          # puts
          # puts
          # puts "Found a potential obstacle location at #{next_guard_x}, #{next_guard_y}"
          # print_grid(obstacle_grid)
        end
      end
    end

    # Update movement
    direction_history[guard_direction.to_sym][next_guard_y][next_guard_x] = "x"
    guard_x = next_guard_x
    guard_y = next_guard_y
    total_step_count += 1
    existing_guard_locations.push([guard_x, guard_y])
  elsif grid[next_guard_y][next_guard_x] == "#"
    # Okay, we found a wall. Let's turn the guard, and don't add a new spacee
    guard_direction = turn_guard(guard_direction)
  end

  if total_step_count % 20 == 0
    puts "Total step count: #{total_step_count}"
  end
end

print_grid(grid)
puts obstacles.count

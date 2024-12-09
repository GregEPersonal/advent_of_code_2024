# Solution for Day 6

require_relative "../utils"

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
      grid[y][x] = "X"
    elsif char == "v"
      guard_x = x
      guard_y = y
      guard_direction = "down"
      grid[y][x] = "X"
    elsif char == ">"
      guard_x = x
      guard_y = y
      guard_direction = "right"
      grid[y][x] = "X"
    elsif char == "<"
      guard_x = x
      guard_y = y
      guard_direction = "left"
      grid[y][x] = "X"
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

# Move the guard, count the spaces. If the guard is on a space, increment the counter
total_spaces = 1

while true
  # Adjust the guard's direction
  if guard_direction == "up"
    next_guard_y = guard_y - 1
    next_guard_x = guard_x
  elsif guard_direction == "down"
    next_guard_y = guard_y + 1
    next_guard_x = guard_x
  elsif guard_direction == "right"
    next_guard_x = guard_x + 1
    next_guard_y = guard_y
  elsif guard_direction == "left"
    next_guard_x = guard_x - 1
    next_guard_y = guard_y
  end

  # Check if the guard is out of bounds
  break if next_guard_x < 0 || next_guard_x >= width || next_guard_y < 0 || next_guard_y >= height

  if grid[next_guard_y][next_guard_x] == "."
    total_spaces += 1
    grid[next_guard_y][next_guard_x] = "X"
    guard_x = next_guard_x
    guard_y = next_guard_y
  elsif grid[next_guard_y][next_guard_x] == "X"
    # Nothing, just continue
    guard_x = next_guard_x
    guard_y = next_guard_y
  elsif grid[next_guard_y][next_guard_x] == "#"
    # Okay, we found a wall. Let's turn the guard, and don't add a new spacee
    guard_direction = turn_guard(guard_direction)
    # print_grid(grid)
  end
end

puts total_spaces

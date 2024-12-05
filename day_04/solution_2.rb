# Solution for Day 4

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_04/input.txt")
width = lines[0].strip.length
height = lines.length

# Create a 2D array to store the puzzle
puzzle = Array.new(height) { Array.new(width) }

# Solution logic
lines.each_with_index do |line, index|
  x = 0
  line.strip.each_char do |char|
    puzzle[index][x] = char
    x += 1
  end
end

# Given a location in puzzle, count number of X's
def count_Xs_from_initial_char(puzzle, x, y, width, height)
  x_count = 0
  left_diag = false
  right_diag = false

  if x <= 0 || x >= width - 1 || y <= 0 || y >= height - 1
    return 0
  end

  top_left = puzzle[y - 1][x - 1]
  top_right = puzzle[y - 1][x + 1]
  bottom_left = puzzle[y + 1][x - 1]
  bottom_right = puzzle[y + 1][x + 1]

  if top_left == "M" || top_left == "S"
    if (bottom_right == "M" || bottom_right == "S") && bottom_right != top_left
      left_diag = true
    end
  end

  if top_right == "M" || top_right == "S"
    if (bottom_left == "M" || bottom_left == "S") && bottom_left != top_right
      right_diag = true
    end
  end

  if left_diag && right_diag
    puts "Found X-MAS at #{x}, #{y}. Top-Left: #{top_left}, Bottom-Right: #{bottom_right}, Top-Right: #{top_right}, Bottom-Left: #{bottom_left}, "
    x_count += 1
  end

  return x_count
end

total_word_count = 0
puts width, height
# binding.pry
puzzle.each_with_index do |row, y|
  row.each_with_index do |char, x|
    if char == "A"
      total_word_count += count_Xs_from_initial_char(puzzle, x, y, width, height)
    end
  end
end

puts total_word_count

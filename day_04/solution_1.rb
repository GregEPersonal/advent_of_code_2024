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

def evaluate_word_for_direction(puzzle, word, x, y, change_in_x, change_in_y, width, height)
  if word == ""
    return true
  end
  new_x = x + change_in_x
  new_y = y + change_in_y
  if new_x < 0 || new_x >= width || new_y < 0 || new_y >= height
    return false
  end
  char = puzzle[new_y][new_x]
  if char == word[0]
    return evaluate_word_for_direction(puzzle, word[1..-1], new_x, new_y, change_in_x, change_in_y, width, height)
  else
    return false
  end
end

# Given a location in puzzle, count how many "word"s are there in the puzzle
def count_words_from_initial_char(puzzle, word, x, y, width, height)
  word_count = 0
  # Try each direction
  # Left
  word_count += evaluate_word_for_direction(puzzle, word, x, y, -1, 0, width, height) ? 1 : 0
  # Diagonal left up
  word_count += evaluate_word_for_direction(puzzle, word, x, y, -1, 1, width, height) ? 1 : 0
  # Up
  word_count += evaluate_word_for_direction(puzzle, word, x, y, 0, 1, width, height) ? 1 : 0
  # Diagonal right up
  word_count += evaluate_word_for_direction(puzzle, word, x, y, 1, 1, width, height) ? 1 : 0
  # Right
  word_count += evaluate_word_for_direction(puzzle, word, x, y, 1, 0, width, height) ? 1 : 0
  # Diagonal right down
  word_count += evaluate_word_for_direction(puzzle, word, x, y, 1, -1, width, height) ? 1 : 0
  # Down
  word_count += evaluate_word_for_direction(puzzle, word, x, y, 0, -1, width, height) ? 1 : 0
  # Diagonal left down
  word_count += evaluate_word_for_direction(puzzle, word, x, y, -1, -1, width, height) ? 1 : 0

  return word_count
end

total_word_count = 0
puzzle.each_with_index do |row, y|
  row.each_with_index do |char, x|
    if char == "X"
      total_word_count += count_words_from_initial_char(puzzle, "MAS", x, y, width, height)
    end
  end
end

puts total_word_count

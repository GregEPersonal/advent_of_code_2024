# Solution for Day 21

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_21/input.txt")

# Just use the lines directly. NO processing needed.
codes = lines

# Numpad
# +---+---+---+
# | 7 | 8 | 9 |
# +---+---+---+
# | 4 | 5 | 6 |
# +---+---+---+
# | 1 | 2 | 3 |
# +---+---+---+
#     | 0 | A |
#     +---+---+
numpad = [
  ["7", "8", "9"],
  ["4", "5", "6"],
  ["1", "2", "3"],
  [nil, "0", "A"],
]

# Directional Keypad
#     +---+---+
#     | ^ | A |
# +---+---+---+
# | < | v | > |
# +---+---+---+
directional_keypad = [
  [nil, "^", "A"],
  ["<", "v", ">"],
]

# In x, y coordinates
number_robot_position = [2, 3]
dir_robot_1 = [2, 0]
dir_robot_2 = [2, 0]

# Rough outline.
# We work backwards for each letter.
# So, givne a letter of the code, we determine what the number_robot needs to do.
# Then we determine what the dir_robot_1 needs to do.
# Then we determine what the dir_robot_2 needs to do.
# Then we determine what the dir_human_3 needs to do.
# We avoid the nil spaces at all costs.

def get_numpad_index_from_char(char, numpad)
  numpad.each_with_index do |row, row_index|
    row.each_with_index do |cell, col_index|
      if cell == char
        return [col_index, row_index]
      end
    end
  end
end

def get_directional_index_from_char(char, numpad)
  numpad.each_with_index do |row, row_index|
    row.each_with_index do |cell, col_index|
      if cell == char
        return [col_index, row_index]
      end
    end
  end
end

def get_directional_moves_from_x_coordinates(x_move_amount)
  if x_move_amount > 0
    return Array.new(x_move_amount, ">")
  elsif x_move_amount < 0
    return Array.new(x_move_amount.abs, "<")
  else
    return []
  end
end

def get_directional_moves_from_y_coordinates(y_move_amount)
  if y_move_amount > 0
    return Array.new(y_move_amount, "v")
  elsif y_move_amount < 0
    return Array.new(y_move_amount.abs, "^")
  else
    return []
  end
end

def calculate_keypad_movement(numpad, start_point, end_point)
  start_x, start_y = start_point
  end_x, end_y = end_point

  # We need to move from start to end
  x_move_amount = end_x - start_x
  y_move_amount = end_y - start_y

  # Let's translate that into movements (^, <, v, >, A)
  x_moves = get_directional_moves_from_x_coordinates(x_move_amount)
  y_moves = get_directional_moves_from_y_coordinates(y_move_amount)

  # New algorithm. Left always comes first, if it can.
  # Then vertical.
  # Then right.
  if x_move_amount < 0
    if x_move_amount == -2 && start_y == 3 # IF we're in the bottom right and moving all the way left.
      moves = y_moves + x_moves
    elsif x_move_amount == -1 && start_y == 3 && start_x == 1 # If we're in the bottom middle and moving left one.
      moves = y_moves + x_moves
    else
      moves = x_moves + y_moves
    end
  elsif x_move_amount > 0 # Moving right. Vertical first, unless it breaks.
    if start_x == 0 && start_y == 2 && y_move_amount == 1
      moves = x_moves + y_moves
    elsif start_x == 0 && start_y == 1 && y_move_amount == 2
      moves = x_moves + y_moves
    elsif start_x == 0 && start_y == 0 && y_move_amount == 3
      moves = x_moves + y_moves
    else
      moves = y_moves + x_moves
    end
  elsif x_move_amount == 0
    moves = y_moves + x_moves
  end

  # Combine the moves
  # If we're in the x column 0, move x first. If we're in the y row 3, move y first.
  # if start_x == 0
  #   moves = x_moves + y_moves
  # elsif start_y == 3
  #   if x_move_amount == -1
  #     moves = x_moves + y_moves
  #   else
  #     moves = y_moves + x_moves
  #   end
  # else # If we're in the middle, move the x first.
  #   moves = x_moves + y_moves
  # end

  moves = moves + ["A"]
  return moves
end

def calculate_dir_pad_movement(dirpad, start_point, end_point)
  start_x, start_y = start_point
  end_x, end_y = end_point

  # We need to move from start to end
  x_move_amount = end_x - start_x
  y_move_amount = end_y - start_y

  # Let's translate that into movements (^, <, v, >, A)
  x_moves = get_directional_moves_from_x_coordinates(x_move_amount)
  y_moves = get_directional_moves_from_y_coordinates(y_move_amount)

  # Okay, this is the new one-shot solve algorihm
  if start_x == 2 # IF we're in the right column
    if start_y == 1
      moves = x_moves + y_moves
    elsif x_move_amount != -2
      moves = x_moves + y_moves
    else
      moves = y_moves + x_moves
    end
  end

  if start_x == 0 # If we're in the left column, the only option is to move right first.
    moves = x_moves + y_moves
  end

  if start_x == 1 # If we're in the middle column, we want to move left first.
    if x_move_amount == 1
      moves = y_moves + x_moves
    elsif x_move_amount == -1
      if start_y == 0
        moves = y_moves + x_moves
      else
        moves = x_moves + y_moves
      end
    else #
      moves = x_moves + y_moves
    end
  end

  # Combine the moves
  # This was the original algorithm
  # If we're in the x column 0, move x first. If we're in the y row 3, move y first.
  # if start_x == 0
  #   moves = x_moves + y_moves
  # elsif start_y == 3
  #   if x_move_amount == -1
  #     moves = x_moves + y_moves
  #   else
  #     moves = y_moves + x_moves
  #   end
  # else # If we're in the middle, move the x first.
  #   moves = x_moves + y_moves
  # end

  moves = moves + ["A"]
  return moves
end

def calc_complexity_score(move_list, code)
  # Get all but the last character
  code_number = code[0..-2].to_i
  move_length = move_list.length

  return code_number * move_length
end

def calculate_dir_pad_movements(numpad_moves, dir_robot, directional_keypad)
  dir_moves = []
  numpad_moves.each do |move|
    end_point = get_directional_index_from_char(move, directional_keypad)
    dir_moves += calculate_dir_pad_movement(directional_keypad, dir_robot, end_point)
    dir_robot = end_point
  end

  return dir_moves
end

# Okay, so given a list of char moves like "^^<<A", we need to calculate all possible options
# For the most part, this is just permuting the moves before the A.
# However, we also need to make sure it doesn't hit the blank space.
def calculate_possible_char_moves(numpad, number_robot_position, end_point, char_moves)
  non_a_char_moves = char_moves[0..-2]

  # Get all possible permutations of the non-A moves
  non_a_char_moves_permutations = non_a_char_moves.permutation.to_a

  # For each permutation, check if it hits the blank space
  # First, we check based on starting positions
  if number_robot_position == [0, 0]
    # Remove any that have v v v as the first three.
    non_a_char_moves_permutations = non_a_char_moves_permutations.select do |perm|
      perm[0..2] != ["v", "v", "v"]
    end
  elsif number_robot_position == [0, 1]
    # Remove any that have v v as the first two.
    non_a_char_moves_permutations = non_a_char_moves_permutations.select do |perm|
      perm[0..1] != ["v", "v"]
    end
  elsif number_robot_position == [0, 2]
    # Remove any that have v as the first one.
    non_a_char_moves_permutations = non_a_char_moves_permutations.select do |perm|
      perm[0] != "v"
    end
  elsif number_robot_position == [1, 3]
    # Remove any that have < as the first one.
    non_a_char_moves_permutations = non_a_char_moves_permutations.select do |perm|
      perm[0] != "<"
    end
  elsif number_robot_position == [2, 3]
    # Remove any that have < < as the first two.
    non_a_char_moves_permutations = non_a_char_moves_permutations.select do |perm|
      perm[0..1] != ["<", "<"]
    end
  end

  # Then, we check based on ending positions
  if end_point == [0, 0]
    # Remove any that have ^ ^ ^ as the last three.
    non_a_char_moves_permutations = non_a_char_moves_permutations.select do |perm|
      perm[-3..-1] != ["^", "^", "^"]
    end
  elsif end_point == [0, 1]
    # Remove any that have ^ ^ as the last two.
    non_a_char_moves_permutations = non_a_char_moves_permutations.select do |perm|
      perm[-2..-1] != ["^", "^"]
    end
  elsif end_point == [0, 2]
    # Remove any that have ^ as the last one.
    non_a_char_moves_permutations = non_a_char_moves_permutations.select do |perm|
      perm[-1] != "^"
    end
  elsif end_point == [1, 3]
    # Remove any that have > as the last one.
    non_a_char_moves_permutations = non_a_char_moves_permutations.select do |perm|
      perm[-1] != ">"
    end
  elsif end_point == [2, 3]
    # Remove any that have > > as the last two.
    non_a_char_moves_permutations = non_a_char_moves_permutations.select do |perm|
      perm[-2..-1] != [">", ">"]
    end
  end

  # Then, add back the A
  non_a_char_moves_permutations.map! do |perm|
    perm + ["A"]
  end

  return non_a_char_moves_permutations
end

def get_all_possible_movements(code, numpad, number_robot_position)
  numpad_moves = [[]]

  # OKay, so for each char, get the array of moves.
  # Then, find all possible combinations that work.
  code.each_char do |char|
    end_point = get_numpad_index_from_char(char, numpad)
    char_moves = calculate_keypad_movement(numpad, number_robot_position, end_point)
    possible_char_moves = calculate_possible_char_moves(numpad, number_robot_position, end_point, char_moves)

    # Then update numpad_moves with the new possible_char_moves
    new_numpad_moves = []

    if numpad_moves.empty?
      numpad_moves = possible_char_moves
    else
      numpad_moves.each do |numpad_move|
        possible_char_moves.each do |possible_char_move|
          new_numpad_moves << numpad_move + possible_char_move
        end
      end
      numpad_moves = new_numpad_moves
    end
    number_robot_position = end_point
  end

  return numpad_moves
end

def get_movements_for_code(code, numpad, number_robot_position)
  numpad_moves = []

  # OKay, so for each char, get the array of moves.
  code.each_char do |char|
    end_point = get_numpad_index_from_char(char, numpad)
    char_moves = calculate_keypad_movement(numpad, number_robot_position, end_point)
    numpad_moves += char_moves
    number_robot_position = end_point
  end

  return numpad_moves
end

def brute_force_code(code, numpad, number_robot_position, dir_robot_1, dir_robot_2, directional_keypad)
  puts "Solving #{code}"
  lowest_complexity_score = nil
  lowest_move_list = nil
  # numpad_moves = [[]]

  # Returns an array of arrays of all possible movements
  numpad_moves = get_all_possible_movements(code, numpad, number_robot_position)

  # For each possible array, calculate the dir movements
  numpad_moves.each do |numpad_move|
    dir_moves_1 = calculate_dir_pad_movements(numpad_move, dir_robot_1, directional_keypad)

    dir_moves_2 = calculate_dir_pad_movements(dir_moves_1, dir_robot_2, directional_keypad)

    code_score = calc_complexity_score(dir_moves_2, code)

    puts "Moves: #{numpad_move.join}"
    puts "Moves length: #{dir_moves_2.length}"
    puts "Code number: #{code[0..-2].to_i}"
    puts "Complexity Score: #{code_score}"
    puts

    if lowest_complexity_score.nil? || code_score < lowest_complexity_score
      lowest_complexity_score = code_score
      lowest_move_list = numpad_move
    end
  end

  puts "Lowest Moves: #{lowest_move_list.join}"
  puts "Lowest Complexity Score: #{lowest_complexity_score}"
  puts
  puts
  puts

  return lowest_complexity_score
end

def one_shot_solve(code, numpad, number_robot_position, dir_robot_1, dir_robot_2, directional_keypad)
  puts "Solving #{code}"
  lowest_complexity_score = nil
  lowest_move_list = nil

  numpad_moves = get_movements_for_code(code, numpad, number_robot_position)

  dir_moves_1 = calculate_dir_pad_movements(numpad_moves, dir_robot_1, directional_keypad)

  dir_moves_2 = calculate_dir_pad_movements(dir_moves_1, dir_robot_2, directional_keypad)

  code_score = calc_complexity_score(dir_moves_2, code)

  puts "Moves: #{numpad_moves.join}"
  puts "Moves length: #{dir_moves_2.length}"
  puts "Code number: #{code[0..-2].to_i}"
  puts "Final Moves: #{dir_moves_2.join}"
  puts "Complexity Score: #{code_score}"
  puts

  return code_score
end

# Alright, no idea how to optimze exactly.
# Let's brute force this.
# Basically, for each numpad code, let's get every code option
# that does NOT go through the blank space.
# So we just need a function that takes a code and returns all the possible
# code options that do not go through the blank space.
# Then the rest of it follows for the most part

total_complexity_score = 0
brute_force = false

lines.each do |code|
  if brute_force
    total_complexity_score += brute_force_code(code, numpad, number_robot_position, dir_robot_1, dir_robot_2, directional_keypad)
  else
    total_complexity_score += one_shot_solve(code, numpad, number_robot_position, dir_robot_1, dir_robot_2, directional_keypad)
  end
end

puts "Total Complexity Score: #{total_complexity_score}"

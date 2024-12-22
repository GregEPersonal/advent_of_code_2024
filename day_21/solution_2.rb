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

def get_directional_index_from_char(char)
  dir_hash = {
    "^" => [1, 0],
    "<" => [0, 1],
    "v" => [1, 1],
    ">" => [2, 1],
    "A" => [2, 0],
  }

  return dir_hash[char]
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

  moves = moves + ["A"]
  return moves
end

def calculate_dir_pad_movement(start_point, end_point)
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

  moves = moves + ["A"]
  return moves
end

def calc_complexity_score(move_list, code)
  # Get all but the last character
  code_number = code[0..-2].to_i
  move_length = move_list.length

  return code_number * move_length
end

def calculate_dir_pad_movements(numpad_moves, dir_robot, memo)
  dir_moves = []
  numpad_moves.each do |move|
    end_point = get_directional_index_from_char(move)
    dir_moves += calculate_dir_pad_movement(dir_robot, end_point)
    dir_robot = end_point
  end
  # memo[numpad_moves] = dir_moves

  return dir_moves
end

def return_memoized_moves(numpad_moves, dir_robot, memo)
  return memo[numpad_moves] if memo[numpad_moves]
  dir_moves = []
  numpad_moves.each do |move|
    end_point = get_directional_index_from_char(move)
    dir_moves += calculate_dir_pad_movement(dir_robot, end_point)
    dir_robot = end_point
  end
  memo[numpad_moves] = dir_moves
  return dir_moves
end

def split_dir_moves_into_pieces(numpad_moves, dir_robot, memo)

  # Divide the numpad_moves array to get each section of moves that ends in "A" as a separate array
  array_of_moves = []
  current_array = []
  numpad_moves.each do |move|
    current_array << move
    if move == "A"
      array_of_moves << current_array
      current_array = []
    end
  end

  # For each array of moves, calculate the movement and memoize
  result_moves = []
  array_of_moves.each do |moves|
    result_moves += return_memoized_moves(moves, dir_robot, memo)
  end

  return result_moves
end

def translate_code_to_directions(code, numpad, number_robot_position)
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

def loop_robots(move_array, robot_start, num_times, memo = {})
  puts "Remaining loops: #{num_times}"
  puts "Current Move Array Length: #{move_array.length}"
  # puts "Current move array: #{move_array.join}"
  if num_times == 0
    return move_array
  end
  new_move_array = split_dir_moves_into_pieces(move_array, robot_start, memo) # memoe-ized slightly.
  # new_move_array = calculate_dir_pad_movements(move_array, robot_start, memo)
  loop_robots(new_move_array, robot_start, num_times - 1, memo)
end

def one_shot_solve(code, numpad, number_robot_position, dir_robot_1, dir_robot_2, robot_count)
  puts "Solving #{code}"

  numpad_moves = translate_code_to_directions(code, numpad, number_robot_position)
  human_moves = loop_robots(numpad_moves, dir_robot_1, robot_count)
  code_score = calc_complexity_score(human_moves, code)

  puts "Moves: #{numpad_moves.join}"
  puts "Moves length: #{human_moves.length}"
  puts "Code number: #{code[0..-2].to_i}"
  # puts "Final Moves: #{human_moves.join}"
  puts "Complexity Score: #{code_score}"
  puts

  return code_score
end

#We're goint to split the numpad moves into pieces.
# Then we're goign to recursively solve each piece, and memoize as we go.
# The memoizaiton did the trick. It's now super fast.
def loop_robots_recursive_memo(move_array, robot_start, num_times, memo = {})
  # puts "Remaining loops: #{num_times}" if num_times % 5 == 0
  joined_array = num_times.to_s + move_array.join("")

  if num_times == 0
    memo[joined_array] = move_array.length
    return move_array.length
  end

  return memo[joined_array] if memo[joined_array]

  # Divide the numpad_moves array to get each section of moves that ends in "A" as a separate array
  array_of_moves = []
  current_array = []
  move_array.each do |move|
    current_array << move
    if move == "A"
      array_of_moves << current_array
      current_array = []
    end
  end

  # Then, process each array recursively. Get the total count of moves.
  # So we basically want to ask the recursive function to return the total count of moves for that array.
  total_count = array_of_moves.map do |moves|
    new_times = num_times - 1
    if memo[new_times.to_s + moves.join]
      memo[new_times.to_s + moves.join]
    else
      new_moves = calculate_dir_pad_movements(moves, robot_start, memo)
      loop_robots_recursive_memo(new_moves, robot_start, num_times - 1, memo)
    end
  end.sum

  memo[joined_array] = total_count
  return total_count
end

# Wrapper for the recursively memo-ized version.
def recursive_memo_solve(code, numpad, number_robot_position, robot_start, robot_count)
  puts "Solving #{code}"

  numpad_moves = translate_code_to_directions(code, numpad, number_robot_position)
  human_move_count = loop_robots_recursive_memo(numpad_moves, robot_start, robot_count)
  code_score = code[0..-2].to_i * human_move_count

  puts "Moves: #{numpad_moves.join}"
  puts "Moves length: #{human_move_count}"
  puts "Code number: #{code[0..-2].to_i}"
  # puts "Final Moves: #{human_moves.join}"
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
robot_count = 25

lines.each do |code|
  total_complexity_score += recursive_memo_solve(code, numpad, number_robot_position, dir_robot_1, robot_count)
  # total_complexity_score += one_shot_solve(code, numpad, number_robot_position, dir_robot_1, dir_robot_2, robot_count)
end

puts "Total Complexity Score: #{total_complexity_score}"

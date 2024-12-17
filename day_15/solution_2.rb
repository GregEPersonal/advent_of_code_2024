# Solution for Day 15

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_15/input.txt")

# Solution logic

#Alright, let's read it in. First, how tall is the map? Let's find the second line that starts with
# "####". That's the end of the map. Let's split lines into two arrays, one for the map and one for
# the rest of the instructions.
map_lines = []
instructions = []

lines.each_with_index do |line, index|
  if index > 0 && line.start_with?("####")
    map_lines = lines[0..index]
    instructions = lines[index + 2..lines.length]
    break
  end
end

width = map_lines[0].length
height = map_lines.length
robot_location = [0, 0]

map = Array.new(height) { Array.new(width * 2) }
instruction_list = []

# Now, let's fill in the map.
map_lines.each_with_index do |line, y|
  line.each_char.with_index do |char, x|
    case char
    when "O"
      map[y][2 * x] = "["
      map[y][2 * x + 1] = "]"
    when "@"
      map[y][2 * x] = "@"
      map[y][2 * x + 1] = "."
      robot_location = [y, 2 * x]
    when "."
      map[y][2 * x] = "."
      map[y][2 * x + 1] = "."
    when "#"
      map[y][2 * x] = "#"
      map[y][2 * x + 1] = "#"
    end
  end
end

#fill out the instruction list.
instructions.each do |instruction_line|
  instruction_line.each_char do |char|
    instruction_list << char
  end
end

def print_map(grid)
  grid.each do |row|
    row.each do |cell|
      print cell
    end
    puts
  end
end

# Recursive function to check if can move.
def check_move_horizontal(map, coord_change, location, character_to_replace, width, height)
  y, x = location
  # puts "Corod check"
  # puts y, x
  # puts coord_change[0]
  # puts coord_change[1]
  new_y, new_x = y + coord_change[0], x + coord_change[1]
  # binding.pry
  new_location = [new_y, new_x]

  # binding.pry

  location_occupant = map[new_y][new_x]

  case location_occupant
  when "."
    map[new_y][new_x] = character_to_replace
    return true
  when "[", "]", "@"
    successful_move = check_move_horizontal(map, coord_change, new_location, location_occupant, width, height)
    if successful_move
      map[new_y][new_x] = character_to_replace
      return true
    else
      return false
    end
  when "#"
    return false
  end
end

# Recursive function to check if can move.
def check_move_vertical(map, coord_change, location, character_to_replace, width, height)
  y, x = location
  # puts "Corod check"
  # puts y, x
  # puts coord_change[0]
  # puts coord_change[1]
  new_y, new_x = y + coord_change[0], x + coord_change[1]
  # binding.pry
  new_location = [new_y, new_x]

  # binding.pry

  location_occupant = map[new_y][new_x]

  case location_occupant
  when "."
    return true
  when "["
    additional_location = [new_y, new_x + 1]
    return check_move_vertical(map, coord_change, new_location, location_occupant, width, height) &&
             check_move_vertical(map, coord_change, additional_location, "]", width, height)
  when "]"
    additional_location = [new_y, new_x - 1]
    return check_move_vertical(map, coord_change, new_location, location_occupant, width, height) &&
             check_move_vertical(map, coord_change, additional_location, "[", width, height)
  when "@"
    return check_move_vertical(map, coord_change, new_location, location_occupant, width, height)
  when "#"
    return false
  end
end

# Actually executing the move.
# Honestly a bit hacky. In reality, I think it'd be better to collect all the locations that need to be updated
# Then update them all, furthest to closets. But this works. And was quicker to update.
def execute_move_vertical(map, coord_change, location, character_to_replace, width, height)
  y, x = location
  # puts "Corod check"
  # puts y, x
  # puts coord_change[0]
  # puts coord_change[1]
  new_y, new_x = y + coord_change[0], x + coord_change[1]
  # binding.pry
  new_location = [new_y, new_x]
  # EXECUTING
  # binding.pry

  location_occupant = map[new_y][new_x]

  case location_occupant
  when "."
    map[new_y][new_x] = character_to_replace
    return true
  when "["
    map[new_y][new_x] = character_to_replace
    additional_location = [new_y, new_x + 1]
    execute_move_vertical(map, coord_change, new_location, location_occupant, width, height)
    if character_to_replace != "["
      execute_move_vertical(map, coord_change, additional_location, "]", width, height)
      map[new_y][new_x + 1] = "." if character_to_replace != "["
    end
    return true
  when "]"
    additional_location = [new_y, new_x - 1]
    map[new_y][new_x] = character_to_replace
    execute_move_vertical(map, coord_change, new_location, location_occupant, width, height)
    if character_to_replace != "]"
      execute_move_vertical(map, coord_change, additional_location, "[", width, height)
      map[new_y][new_x - 1] = "." if character_to_replace != "]"
    end
    return true
  when "@"
    map[new_y][new_x] = character_to_replace
    return execute_move_vertical(map, coord_change, new_location, location_occupant, width, height)
  when "#"
    return false
  end
end

def get_coord_change_from_direction(direction_char)
  coord_change = [0, 0]
  case direction_char
  when "<"
    coord_change = [0, -1]
  when ">"
    coord_change = [0, 1]
  when "^"
    coord_change = [-1, 0]
  when "v"
    coord_change = [1, 0]
  end
  return coord_change
end

def update_map(map, robot_location, instruction, width, height)
  # Okay, so, given a direction, we're going to:
  # Check what's in the space above us.
  # If it's free space, move.
  # If it's a box, note it, and check the space beyond.
  # If it's a wall, do nothing.
  # This is kind of recursive.
  coord_change = get_coord_change_from_direction(instruction)

  if ["<", ">"].include?(instruction)
    #Moving horizontally, can do the same as in part 1
    # Roughly, move returns whether you can move in that direction,
    # And if the answer is yes, then we update our current location on the map
    if check_move_horizontal(map, coord_change, robot_location, "@", width, height)
      #Check move handles all but the robot's current location, so we need to update that.
      map[robot_location[0]][robot_location[1]] = "."

      return [robot_location[0] + coord_change[0], robot_location[1] + coord_change[1]]
    else
      return robot_location
    end
  elsif ["^", "v"].include?(instruction)
    #Moving vertically, need to check if we can move in the direction we want to go, and then
    # check if we can move in the direction we want to go in the horizontal direction.
    if check_move_vertical(map, coord_change, robot_location, "@", width, height)
      execute_move_vertical(map, coord_change, robot_location, "@", width, height)
      map[robot_location[0]][robot_location[1]] = "."
      return [robot_location[0] + coord_change[0], robot_location[1] + coord_change[1]]
    else
      return robot_location
    end
  end
end

#Okay, now we're going to read all of the instructions
instruction_list.each_with_index do |instruction, index|
  # puts "Attempting move #{index}"
  robot_location = update_map(map, robot_location, instruction, width, height)
  # puts "robot loc: #{robot_location}"
  # print_map(map)
end

def calculate_box_gps(map)
  gps_total = 0

  map.each_with_index do |row, y|
    row.each_with_index do |char, x|
      if char == "["
        gps_total += y * 100 + x
      end
    end
  end

  return gps_total
end

print_map(map)

gps = calculate_box_gps(map)
puts "Gps: #{gps}"

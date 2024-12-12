# Solution for Day 12

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_12/input.txt")

# Solution logic

#Okay, rough plan.
#Store a a 3D array - y coord, x coord, and then an array of [Letter, index of group]
# Iterate through the array, and on each step, expand out to find the region.

width = lines[0].length
height = lines.length
map = Array.new(height) { Array.new(width) { [nil, nil] } }

# Fill map with input
lines.each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    map[y][x] = [char, nil]
  end
end

# Given a coordinate without a region, find the list of all x, y coordinates that have
# the same plant type and are adjacent to us
def create_region(region_plant_type, x, y, region_index, map, width, height)
  if x < 0 || x >= width || y < 0 || y >= height
    return nil
  end

  current_plant = map[y][x]
  current_plant_type = current_plant[0]

  if !current_plant[1].nil?
    return nil
  end

  if current_plant_type == region_plant_type
    map[y][x][1] = region_index
    return_array = [[x, y]]

    a = create_region(region_plant_type, x + 1, y, region_index, map, width, height)
    b = create_region(region_plant_type, x - 1, y, region_index, map, width, height)
    c = create_region(region_plant_type, x, y + 1, region_index, map, width, height)
    d = create_region(region_plant_type, x, y - 1, region_index, map, width, height)

    return_array += a if !a.nil?
    return_array += b if !b.nil?
    return_array += c if !c.nil?
    return_array += d if !d.nil?

    return return_array
  end
  return nil
end

def check_boundary(map, y, x, region_index, width, height)
  if x < 0 || x >= width || y < 0 || y >= height
    return 1
  end

  if map[y][x][1] == region_index
    return 0
  else
    return 1
  end
end

def horizontal_or_vertical_boundary(boundary_array)
  if boundary_array[0] == boundary_array[2]
    return "horizontal"
  else
    return "vertical"
  end
end

# IF vertical, then we check the two boundaries above and below
# IF horizontal, then we check the two boundaries to the left and right
# A Boundary array is in the format of the two cells forming the boundary. [x1, y1, x2, y2]
# So the adjacent boundaries to a vertical boundary are [x1, y1 - 1, x2, y2 - 1] and [x1, y1 + 1, x2, y2 + 1]
# And the adjacent boundaries to a horizontal boundary are [x1 - 1, y1, x2 - 1, y2] and [x1 + 1, y1, x2 + 1, y2]
def adjacent_boundaries(boundary_array, direction)
  if direction == "vertical"
    x1, y1, x2, y2 = boundary_array
    return [[x1, y1 - 1, x2, y2 - 1], [x1, y1 + 1, x2, y2 + 1]]
  else
    x1, y1, x2, y2 = boundary_array
    return [[x1 - 1, y1, x2 - 1, y2], [x1 + 1, y1, x2 + 1, y2]]
  end
end

def down_boundary(boundary_array, direction)
  x1, y1, x2, y2 = boundary_array
  if direction == "vertical"
    return [x1, y1 - 1, x2, y2 - 1]
  else
    return [x1 - 1, y1, x2 - 1, y2]
  end
end

def up_boundary(boundary_array, direction)
  x1, y1, x2, y2 = boundary_array
  if direction == "vertical"
    return [x1, y1 + 1, x2, y2 + 1]
  else
    return [x1 + 1, y1, x2 + 1, y2]
  end
end

def calculate_boundary(region_list, map, width, height)
  boundary_list = []
  region_list.each do |region|
    x1, y1 = region
    index = map[y1][x1][1]

    # Check each direction to see if it has the same region_index
    if check_boundary(map, y1 + 1, x1, index, width, height) == 1
      boundary_list << [x1, y1, x1, y1 + 1]
    end
    if check_boundary(map, y1 - 1, x1, index, width, height) == 1
      boundary_list << [x1, y1, x1, y1 - 1]
    end
    if check_boundary(map, y1, x1 + 1, index, width, height) == 1
      boundary_list << [x1, y1, x1 + 1, y1]
    end
    if check_boundary(map, y1, x1 - 1, index, width, height) == 1
      boundary_list << [x1, y1, x1 - 1, y1]
    end
  end

  # And thennn we calculate the boundaries somehow.
  # Check if it's horizontal or vertical.
  # Then iterate up one cell and down one cell, and check if those are in
  boundary_counter = {}
  boundary_list.each do |bound_array|
    # For each boundary_array, we map it so that the array is the key, and the value is a 1
    boundary_counter[bound_array] = 1
  end

  boundary_list.each do |bound_array|
    # Everything starts as counting as 1.
    # If we find it is adjacent to another boundary, then we set it to 0.
    if boundary_counter[bound_array] == 1
      boundary_direction = horizontal_or_vertical_boundary(bound_array)

      down_boundary = down_boundary(bound_array, boundary_direction)
      up_boundary = up_boundary(bound_array, boundary_direction)

      # While the down_boundary is in the boundary_list, we set it to 0 in the counter
      # And continue moving down.
      while boundary_counter[down_boundary] == 1
        boundary_counter[down_boundary] = 0
        down_boundary = down_boundary(down_boundary, boundary_direction)
      end

      # While the up_boundary is in the boundary_list, we set it to 0 in the counter
      # And continue moving up.
      # puts "Up boundary is #{up_boundary}"
      while boundary_counter[up_boundary] == 1
        boundary_counter[up_boundary] = 0
        up_boundary = up_boundary(up_boundary, boundary_direction)
      end
    end
  end

  # Return the sum of teh boundary_counter values
  return boundary_counter.values.sum
end

def calculate_boundary_with_discount(region_list, map, width, height)
  sides = 0
end

def print_plants(grid)
  grid.each do |row|
    row.each do |cell|
      print cell[0]
    end
    puts
  end
end

def print_regions(grid)
  grid.each do |row|
    row.each do |cell|
      print cell[1]
    end
    puts
  end
end

# OKay, now we want to calc the price, which is area * boundary.
next_region_index = 0
region_area = []
region_boundary = []

map.each_with_index do |row, y|
  row.each_with_index do |plant_array, x|
    plant_type = plant_array[0]
    region_index = plant_array[1]

    if region_index.nil?
      # First, find and create the region.
      # puts "Creating region at #{x}, #{y} - plant is #{plant_type}"
      region_list = create_region(plant_type, x, y, next_region_index, map, width, height)
      puts "Region list is #{region_list}"

      # Update each plant's region index.
      region_list.each do |region|
        map[region[1]][region[0]][1] = next_region_index
      end

      # Save the area
      region_area[next_region_index] = region_list.count

      # Calculate teh boundary
      region_boundary[next_region_index] = calculate_boundary(region_list, map, width, height)

      next_region_index += 1
    end
  end
end

total_sum = 0
puts region_area.length
puts region_boundary.length

(0...region_area.length).each do |i|
  puts "Region is #{region_area[i]}, #{region_boundary[i]}"
  total_sum += region_area[i] * region_boundary[i]
end

# print_plants(map)
# print_regions(map)
puts "Total sum: #{total_sum}"

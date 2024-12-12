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

def calculate_boundary(region_list, map, width, height)
  boundary = 0
  region_list.each do |region|
    x1, y1 = region
    index = map[y1][x1][1]
    # puts "Checking #{x1}, #{y1} - boundary at #{boundary}"
    #   #Check each direction to see if it has the same region_index
    boundary += check_boundary(map, y1 + 1, x1, index, width, height)
    boundary += check_boundary(map, y1 - 1, x1, index, width, height)
    boundary += check_boundary(map, y1, x1 + 1, index, width, height)
    boundary += check_boundary(map, y1, x1 - 1, index, width, height)
    # puts "End boundary at #{boundary}"
  end
  return boundary
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
  # puts "Region is #{region_area[i]}, #{region_boundary[i]}"
  total_sum += region_area[i] * region_boundary[i]
end

# print_plants(map)
# print_regions(map)
puts "Total sum: #{total_sum}"

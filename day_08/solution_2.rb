# Solution for Day 8

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_08/input.txt")

# Solution logic

width = lines[0].length
height = lines.length

map = Array.new(height) { Array.new(width) }
antenna_type_list = []

lines.each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    map[y][x] = char
    antenna_type_list << char if char != "." && !antenna_type_list.include?(char)
  end
end

def find_antipodes(antenna1, antenna2, width, height)
  x1, y1 = antenna1
  x2, y2 = antenna2

  dx = (x2 - x1)
  dy = (y2 - y1)

  antipode_1 = [x2 + dx, y2 + dy]
  antipode_2 = [x1 - dx, y1 - dy]

  antipode_list = []
  antipode_list << antenna1
  antipode_list << antenna2

  while antipode_1[0] >= 0 && antipode_1[0] < width && antipode_1[1] >= 0 && antipode_1[1] < height
    antipode_list << antipode_1
    antipode_1 = [antipode_1[0] + dx, antipode_1[1] + dy]
  end

  while antipode_2[0] >= 0 && antipode_2[0] < width && antipode_2[1] >= 0 && antipode_2[1] < height
    antipode_list << antipode_2
    antipode_2 = [antipode_2[0] - dx, antipode_2[1] - dy]
  end

  antipode_list
end

#Okay, rough plan is:
# For each antenna type, find all other antennas of the same type
# Then, for each pair of antennas, calculate the distance between them
# Then, find the antipodes, and save them in a list
# Then we just count the unique antipodes.
antipode_list = []

antenna_type_list.each do |antenna_type|
  antennas = []
  map.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      antennas << [x, y] if cell == antenna_type
    end
  end

  antennas.each_with_index do |antenna, i|
    #loop from i until antennas.length
    (i + 1...antennas.length).each do |j|
      antenna2 = antennas[j]

      antipodes = find_antipodes(antenna, antenna2, width, height)
      antipodes.each do |antipode|
        antipode_list << antipode if !antipode_list.include?(antipodes)
      end
    end
  end
end

puts antipode_list.uniq.length

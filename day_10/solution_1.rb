# Solution for Day 10

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_10/input.txt")

# Solution logic
width = lines[0].length
height = lines.length
map = Array.new(height) { Array.new(width) }

# Fill map with input
lines.each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    map[y][x] = char.to_i
  end
end

# Assumes starting from a 0 trailhead on the map
def count_hikes_from_trailhead(map, x, y, width, height)
  peaks_reachable = []

  # Add the array result of count_peaks to peaks_reachable
  # count_peaks returns an array, so we need to add the elements of the array to peaks_reachable
  peaks_reachable += count_peaks(map, x + 1, y, 0, width, height)
  peaks_reachable += count_peaks(map, x - 1, y, 0, width, height)
  peaks_reachable += count_peaks(map, x, y + 1, 0, width, height)
  peaks_reachable += count_peaks(map, x, y - 1, 0, width, height)

  # Return the number of distinct peaks reachable from the trailhead
  return peaks_reachable.uniq.length
end

def count_peaks(map, x, y, past_elevation, width, height)
  if x < 0 || x >= width || y < 0 || y >= height
    return []
  end

  elevation = map[y][x]
  # binding.pry

  if elevation - past_elevation == 1
    # puts "Continuing to #{x}, #{y}"
    if elevation == 9
      # puts "Completed trailhead at #{x}, #{y}"
      return [[x, y]]
    end

    return [] + count_peaks(map, x + 1, y, elevation, width, height) +
             count_peaks(map, x - 1, y, elevation, width, height) +
             count_peaks(map, x, y + 1, elevation, width, height) +
             count_peaks(map, x, y - 1, elevation, width, height)
  else
    return []
  end
end

trailheads = 0

# Iterate through each character
map.each_with_index do |row, y|
  row.each_with_index do |elevation, x|
    # puts "x: #{x}, y: #{y}, elevation: #{elevation}"
    if elevation == 0
      trailheads += count_hikes_from_trailhead(map, x, y, width, height)
    end
  end
end

puts "trailheads: #{trailheads}"

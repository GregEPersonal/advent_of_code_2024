# Solution for Day 10

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_10/test_input.txt")

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
  peaks_reachable = 0

  # Just test each direction
  peaks_reachable += count_peaks(map, x + 1, y, 0, width, height)
  peaks_reachable += count_peaks(map, x - 1, y, 0, width, height)
  peaks_reachable += count_peaks(map, x, y + 1, 0, width, height)
  peaks_reachable += count_peaks(map, x, y - 1, 0, width, height)

  # Return the number of distinct peaks reachable from the trailhead
  return peaks_reachable
end

def count_peaks(map, x, y, past_elevation, width, height)
  if x < 0 || x >= width || y < 0 || y >= height
    return 0
  end

  elevation = map[y][x]

  if elevation - past_elevation == 1
    if elevation == 9
      return 1
    end

    # Classic map search
    # Just call each direction recursively
    return count_peaks(map, x + 1, y, elevation, width, height) +
             count_peaks(map, x - 1, y, elevation, width, height) +
             count_peaks(map, x, y + 1, elevation, width, height) +
             count_peaks(map, x, y - 1, elevation, width, height)
  else
    return 0
  end
end

trailheads = 0

# Iterate through each map point
map.each_with_index do |row, y|
  row.each_with_index do |elevation, x|
    if elevation == 0
      trailheads += count_hikes_from_trailhead(map, x, y, width, height)
    end
  end
end

puts "trailheads: #{trailheads}"

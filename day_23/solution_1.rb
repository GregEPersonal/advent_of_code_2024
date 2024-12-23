# Solution for Day 23

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_23/input.txt")

def check_triplet(connection_hash, triplet_list, left, right)
  # Check if current pair shares another connection.
  # Check overlap between connection_hash[left] and connection_hash[right]
  # All overlap elements are triplets
  if connection_hash[left] && connection_hash[right]
    overlap = connection_hash[left] & connection_hash[right]
    overlap.each do |triplet|
      # First, alphabetically sort the triplet
      triplet = [left, right, triplet].sort
      triplet_list << triplet # unless triplet_list.include?(triplet) # Not needed - this only works when the third connection is added.
    end
  end
end

def count_triplets_with_t(triplet_list)
  count = 0
  triplet_list.each do |triplet|
    a, b, c = triplet
    count += 1 if a.start_with?("t") || b.start_with?("t") || c.start_with?("t")
  end
  count
end

connection_hash = {}
triplet_list = []
# Solution logic
lines.each_with_index do |line, index|
  puts "Processing line #{index}" if (index % 100) == 0

  left, right = line.split("-")
  # Add them to the hashes. If they don't exist, create them
  if connection_hash[left]
    connection_hash[left] << right
  else
    connection_hash[left] = [right]
  end
  if connection_hash[right]
    connection_hash[right] << left
  else
    connection_hash[right] = [left]
  end

  check_triplet(connection_hash, triplet_list, left, right)
end

puts "Total Connection Count: #{connection_hash.keys.count}"
puts "Total Triplet Count: #{triplet_list.count}"
puts "Triplets with t: #{count_triplets_with_t(triplet_list)}"

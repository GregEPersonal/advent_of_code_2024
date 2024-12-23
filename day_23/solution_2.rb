# Solution for Day 23

require_relative "../utils"
require "pry"

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

# Okay, let's generalize adding in quartets and quintets.
def increase_clique_size(connection_hash, current_clique_list)
  new_clique_options = []
  current_clique_list.each do |clique|
    # Check if the current clique has a connection with all the other elements
    # If they do, add that connection to the new_clique
    # If the new_clique is the right size, add it to the new_clique
    # Otherwise, add it to the current_clique

    # First, get the intersection of the connection_hash results for each element in the clique
    current_intersection = connection_hash[clique.first]
    clique.each do |c|
      current_intersection = current_intersection & connection_hash[c]
    end

    # Now, add these into the new_clique_options
    current_intersection.each do |ci|
      new_clique = clique + [ci]
      new_clique_options << new_clique.sort
    end
    new_clique_options
  end
  new_clique_options.uniq!
end

# Maybe we just build on the triplet list?
# And so, for each triplet, we check if they have a common connection.
# If they do, we add that connection to a new quartet list. Let's see how many there are.
# quartet_list = []
# triplet_list.each do |triplet|
#   a, b, c = triplet
#   if connection_hash[a] && connection_hash[b] && connection_hash[c]
#     quartet_options = connection_hash[a] & connection_hash[b] & connection_hash[c]
#     quartet_options.each do |q|
#       quartet = [a, b, c, q].sort
#       quartet_list << quartet
#     end
#   end
# end
# quartet_list.uniq!
# puts "Total Quartet Count: #{quartet_list.count}"

# # OKay, let's try for 5
# quintet_list = []
# quartet_list.each do |quartet|
#   a, b, c, d = quartet
#   if connection_hash[a] && connection_hash[b] && connection_hash[c] && connection_hash[d]
#     quintet_options = connection_hash[a] & connection_hash[b] & connection_hash[c] & connection_hash[d]
#     quintet_options.each do |q|
#       quintet = [a, b, c, d, q].sort
#       quintet_list << quintet
#     end
#   end
# end
# quintet_list.uniq!
# puts "Total Quintet Count: #{quintet_list.count}"

puts "Comparing to function method"
fx_quartet_list = increase_clique_size(connection_hash, triplet_list)
puts "Total Quartet Count: #{fx_quartet_list.count}"
fx_quintet_list = increase_clique_size(connection_hash, fx_quartet_list)
puts "Total Quintet Count: #{fx_quintet_list.count}"
fx_sextet_list = increase_clique_size(connection_hash, fx_quintet_list)
puts "Total Sextet Count: #{fx_sextet_list.count}"
fx_septet_list = increase_clique_size(connection_hash, fx_sextet_list)
puts "Total Septet Count: #{fx_septet_list.count}"
fx_octet_list = increase_clique_size(connection_hash, fx_septet_list)
puts "Total Octet Count: #{fx_octet_list.count}"
fx_nonet_list = increase_clique_size(connection_hash, fx_octet_list)
puts "Total Nonet Count: #{fx_nonet_list.count}"
fx_decet_list = increase_clique_size(connection_hash, fx_nonet_list)
puts "Total Decet Count: #{fx_decet_list.count}"
fx_undecet_list = increase_clique_size(connection_hash, fx_decet_list)
puts "Total Undecet Count: #{fx_undecet_list.count}"
fx_duodecet_list = increase_clique_size(connection_hash, fx_undecet_list)
puts "Total Duodecet Count: #{fx_duodecet_list.count}"
fx_tridecet_list = increase_clique_size(connection_hash, fx_duodecet_list)
puts "Total Tridecet Count: #{fx_tridecet_list.count}"
fx_quattuordecet_list = increase_clique_size(connection_hash, fx_tridecet_list)
puts "Total Quattuordecet Count: #{fx_quattuordecet_list&.count}"

puts "Password: #{fx_tridecet_list.first.sort.join(",")}"

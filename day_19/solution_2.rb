# Solution for Day 19

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_19/input.txt")

# Solution logic
towel_types = []

# Get the potential towel types
towel_types = lines[0].split(", ").sort

# Get the requested designs
requested_designs = lines[2..-1]

# Okay, so to solve this, we are going to basically loop through every design and check if it's possible to do.

# We're going to start by checking if the design starts with any of the towel types
# And then return an array of those.
def check_partial_design(design, towel_types)
  matching_towel_types = []

  # Only check those that match the first letter of the design
  towel_types_to_check = towel_types.select { |towel_type| towel_type.start_with?(design[0]) }

  towel_types_to_check.each do |towel_type|
    if design.start_with?(towel_type)
      matching_towel_types.push(towel_type)
    end
  end

  return matching_towel_types
end

# OKay, so we get a string that is a series of letters.
# We then need to see if we can make that string with the available towel_types (small strings)
def count_design(design, towel_types, memo = {})
  # Big change to speed thing up - memoization
  # This is because we often hit the exact same end of the design string multiple times.
  return memo[design] if memo.key?(design)
  return 1 if design.empty?

  # We're going to iterate through the design string, and check which towel_Types work with the current string.
  # IF we find a match, we recursively try it out.

  # This is an array of possible towel types that can be used to start the design.
  matching_towel_types = check_partial_design(design, towel_types)

  total_count = 0

  matching_towel_types.each do |towel_type|
    # We're going to remove the towel_type from the front of the design string
    # We'll then recursively check the remaining.
    remaining_design = design[towel_type.length..-1]

    # If the remaining design is empty, we've found a match.
    # Otherwise, we'll recursively check the remaining design.
    if remaining_design.empty?
      total_count += 1
    else
      success = count_design(remaining_design, towel_types, memo)
      total_count += success
    end
  end

  memo[design] = total_count
  return total_count
end

# OKay, we're going to iterate through towel_types
# And any of them that can be made with OTHER towel types, we're going to remove.
def reduce_towel_types(towel_types)
  reduced_towel_types = []

  towel_types.each_with_index do |towel_type, index|
    # We're goint to call check_design with this towel_type as the design, and all others
    # as the towel_types.
    can_be_made = false

    other_towel_types = towel_types[0...index] + towel_types[index + 1..-1]

    duplicate = check_design(towel_type, other_towel_types)

    if !duplicate
      reduced_towel_types.push(towel_type)
    end
  end

  return reduced_towel_types
end

possible_design_count = 0

requested_designs.each_with_index do |design, index|
  puts "Checking design #{index}"
  # Check if the design is possible
  design_count = count_design(design, towel_types)
  puts "Design count: #{design_count}"
  possible_design_count += design_count
end

puts possible_design_count

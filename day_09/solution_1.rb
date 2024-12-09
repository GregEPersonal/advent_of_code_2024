# Solution for Day 9

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_09/test_input.txt")

# Solution logic
line = lines[0]
block_array = []

file_id = 0
# Loop from 0 to line.length by 2 at a time
(0...line.length).step(2) do |i|
  file_length = line[i]
  free_space_length = line[i + 1]

  file_length.to_i.times do |j|
    block_array << file_id
  end

  free_space_length.to_i.times do |j|
    block_array << nil
  end
  file_id += 1
end

puts "Length of block_array: #{block_array.length}"

# Brute force rearrange the file array
def rearrange_file_array(block_array)
  # puts block_array.join(".")
  (0...block_array.length).step(1) do |i|
    block = block_array[i]
    if block.nil?
      # Get the last non-nil element and its index in the array.
      last_non_nil_index = block_array.rindex { |x| !x.nil? }
      last_non_nil = block_array[last_non_nil_index]

      # Swap it with this nil element.
      if last_non_nil_index > i
        block_array[i] = last_non_nil
        block_array[last_non_nil_index] = nil
      end
    end

    if i % 1000 == 0
      puts "Index: #{i}"
    end
  end

  block_array
end

# Calculate the checksum
def calculate_checksum(block_array)
  checksum = 0
  block_array.each_with_index do |block, i|
    if !block.nil?
      checksum += i * block.to_i
    end
  end
  checksum
end

block_array = rearrange_file_array(block_array)
puts calculate_checksum(block_array)

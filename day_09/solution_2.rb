# Solution for Day 9

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_09/input.txt")

# Solution logic
line = lines[0]
block_array = []
file_index = []

file_id = 0
# Loop from 0 to line.length by 2 at a time
# Create the block_array and the file_index
(0...line.length).step(2) do |i|
  file_length = line[i]
  free_space_length = line[i + 1]

  file_length.to_i.times do |j|
    block_array << file_id.to_i
  end

  # Save the file index
  # ID, first_index, last_index (last is AFTER the last element)
  file_index << [file_id, block_array.length - file_length.to_i, block_array.length]

  free_space_length.to_i.times do |j|
    block_array << nil
  end

  # Really, we should also be doing a free_space_index, but we can get away without it.

  file_id += 1
end

puts "Length of block_array: #{block_array.length}"

#Find the first group of nils of length file_length in block_array
# May have to replace this with a free_space_index for speed improvements (we don't!)
def find_group_of_nils(block_array, goal_number, max_search_index)
  nil_count = 0
  nil_start_index = nil
  nil_end_index = nil
  block_array.each_with_index do |block, i|
    break if i > max_search_index
    if block.nil?
      if nil_count == 0
        nil_start_index = i
      end
      nil_count += 1
      if nil_count == goal_number
        nil_end_index = i
        break
      end
    else
      nil_count = 0
      nil_start_index = nil
    end
  end

  [nil_start_index, nil_end_index]
end

# Rearrange the block_array
def rearrange_file_array_2(block_array, file_index)
  length = block_array.length

  file_index.reverse.each do |file_id, start_index, end_index|
    file_length = end_index - start_index

    #Find the first group of nils of length file_length in block_array
    # May have to replace this with a free_space_index
    nil_start_index, nil_end_index = find_group_of_nils(block_array, file_length, end_index)

    # Swap the file with the nils.
    # If the nils are before the file, swap them.
    # If the nils are after the file, don't
    if nil_start_index && nil_start_index < start_index
      (start_index...end_index).each do |i|
        block_array[i], block_array[nil_start_index] = block_array[nil_start_index], block_array[i]
        nil_start_index += 1
      end
    end

    if file_id % 1000 == 0
      puts "File Index: #{file_id}"
    end
  end

  return block_array
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

puts "File Index length: #{file_index.length}"
block_array = rearrange_file_array_2(block_array, file_index)
puts calculate_checksum(block_array)

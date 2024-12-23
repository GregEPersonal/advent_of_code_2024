# Solution for Day 22

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_22/input.txt")

# To mix a value into the secret number, calculate the bitwise XOR of the given value and the secret number.
# Then, the secret number becomes the result of that operation.
# (If the secret number is 42 and you were to mix 15 into the secret number,
# the secret number would become 37.)
def mix(n, sn)
  return n ^ sn
end

# To prune the secret number, calculate the value of the secret number modulo 16777216.
# Then, the secret number becomes the result of that operation.
# (If the secret number is 100000000 and you were to prune the secret number,
# the secret number would become 16113920.)
def prune(n)
  return n % 16777216
end

# In particular, each buyer's secret number evolves into the next secret number in the sequence via the following process:
# Calculate the result of multiplying the secret number by 64. Then, mix this result into the secret number. Finally, prune the secret number.
# Calculate the result of dividing the secret number by 32. Round the result down to the nearest integer. Then, mix this result into the secret number. Finally, prune the secret number.
# Calculate the result of multiplying the secret number by 2048. Then, mix this result into the secret number. Finally, prune the secret number.
def calc_next_secret_number(secret_number)
  sn = secret_number
  n = sn * 64
  sn = mix(n, sn)
  sn = prune(sn)
  n = sn / 32
  sn = mix(n, sn)
  sn = prune(sn)
  n = sn * 2048
  sn = mix(n, sn)
  sn = prune(sn)
  return sn
end

# Solution logic
secret_number_list = lines.map(&:to_i)
# secret_number_list = [123]
iteration_count = 2000
price_array = Array.new(secret_number_list.size) { Array.new(iteration_count - 1) { } }
diff_array = Array.new(secret_number_list.size) { Array.new(iteration_count - 1) { } }

# Calculate the secret number for each buyer, amd get their pricing.
secret_number_sum = 0
secret_number_list.each_with_index do |sn, index|
  # puts "Secret Number: #{sn}"
  prior_ones_digit = sn % 10
  result = sn
  (0...iteration_count).each do |i|
    result = calc_next_secret_number(result)
    # puts "Next Secret Number: #{result}"
    new_ones_digit = result % 10
    diff_array[index][i] = new_ones_digit - prior_ones_digit
    price_array[index][i] = new_ones_digit
    prior_ones_digit = new_ones_digit

    # puts "sn: #{sn}, i: #{i}, result: #{result}, diff: #{diff_array[index][i]}, price: #{price_array[index][i]}"
  end
  secret_number_sum += result
  # puts "Final Secret Number: #{result}"
end

puts "Completed secret number list"
puts "Secret Number Sum: #{secret_number_sum}"

# Next up, let's just try to test some secret numbers I guess?
# So, let's collect all the possible patterns that end in 1, 2, 3, 4, 5, 6, 7, 8, or 9.

# Create an array of arrays to store the potential patterns. Unknown how long.
potential_patterns = {}

diff_array.each_with_index do |diff_list, monkey_index|
  puts "Monkey Index: #{monkey_index}" if monkey_index % 500 == 0
  prior = diff_array[monkey_index][2]
  two_prior = diff_array[monkey_index][1]
  three_prior = diff_array[monkey_index][0]
  diff_list.each_with_index do |diff, index|
    next if index < 3 # Skip the first three, since we need to have a full pattern.

    pattern = [three_prior, two_prior, prior, diff]
    price = price_array[monkey_index][index]

    if potential_patterns[pattern]
      if potential_patterns[pattern][:last_index] < monkey_index
        potential_patterns[pattern][:count] += price
        potential_patterns[pattern][:last_index] = monkey_index
      end
    else
      potential_patterns[pattern] = { count: price, last_index: monkey_index }
    end

    three_prior = two_prior
    two_prior = prior
    prior = diff
  end
end

puts "Completed potential patterns"
# Sort through the potential patterns hash, and find the key with the highest value.
max_value = 0
max_key = nil
potential_patterns.each do |key, value|
  count = value[:count]
  if count > max_value
    max_value = count
    max_key = key
  end
end

puts "Max Key: #{max_key}"
puts "Max Value: #{max_value}"

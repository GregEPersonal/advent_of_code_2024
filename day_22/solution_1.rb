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

#
secret_number_sum = 0
secret_number_list.each do |sn|
  # puts "Secret Number: #{sn}"
  result = sn
  iteration_count.times do
    result = calc_next_secret_number(result)
    # puts "Next Secret Number: #{result}"
  end
  secret_number_sum += result
  # puts "Final Secret Number: #{result}"
end

puts "Secret Number Sum: #{secret_number_sum}"

day = ARGV[0]
part = ARGV[1]

if day.nil? || part.nil?
  puts "Usage: ruby run.rb <day> <part>"
  exit
end

day_dir = "day_#{day.to_s.rjust(2, "0")}"
solution_file = "#{day_dir}/solution_#{part}.rb"

unless File.exist?(solution_file)
  puts "Solution file for Day #{day} Part #{part} does not exist."
  exit
end

starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
load solution_file
ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = ending - starting
puts "Elapsed time: #{elapsed} seconds"

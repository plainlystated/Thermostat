points = []
File.open("temp.log") do |file|
  file.each do |line|
    timestamp, temp = line.split
    temp = temp.to_f
    next if temp > 100
    next if temp < 30
    points << [timestamp.to_i, temp]
  end
end
p points

#!/usr/bin/env ruby

File.open("temp.log", "a") do |log|
  print "-"
  File.open("/dev/cu.usbmodem621") do |file|
    file.each do |line|
      print "."
      log.puts "#{Time.now.to_i * 1000} #{line}"
      log.flush
    end
  end
end

## eat file-based commands
# @TODO try j ruby server
# @TODO try ruby message bus (branch)
puts "slurp starts.. @ "+Time.now.localtime.strftime("%Y-%m-%d*%H:%M:%S")
i = 3
while (i-=1)>0 do # true
  # (d = Dir .new '.') .entries
  # `ls -alF`
  puts "i: #{i}"
  sleep 1
end

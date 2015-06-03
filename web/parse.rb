#    Copyright 2015 Barcelona Supercomputing Center
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

#!/usr/bin/ruby

if(ARGV.length != 1) then
   puts "Usage: parse.rb <TXT traces file>"
   exit -1
end

file = ARGV[0]

max = 0.0
currentWorkload = 0.0
lastTimeGrain = nil
basePercentage = []

GRANULARITY = 12*60
currentTime = 0

puts "Opening file #{file}..."

profile = File.new('out.csv','w')

text=File.open(file).read
text.gsub!(/\r\n?/, "\n")

text.each_line do |line|
   lines = line.split(/\s/)

   currentTimeGrain = lines[0].to_i

   currentWorkload = currentWorkload + lines[1].to_i

   lastTimeGrain = currentTimeGrain if lastTimeGrain.nil?

   if currentTimeGrain - lastTimeGrain >= GRANULARITY
      basePercentage = basePercentage + [currentWorkload.to_f]
      max = currentWorkload if currentWorkload > max
      lastTimeGrain = currentTimeGrain
      currentWorkload = 0
      currentTime += GRANULARITY
      if currentTime > 7*24*60*60
         break

      end

   end
end

time = 0
days = 0
# repeat the 1-week pattern for a year
while days < 365
   basePercentage.each do |p|
      profile.write "#{time}\t#{p / max}\n"
      time += GRANULARITY
   end
   days += 7
end

puts "\nTask finished successfully."

profile.close



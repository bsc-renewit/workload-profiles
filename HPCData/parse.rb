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
   puts "Usage: parse.rb <SWF file> [--hourly]"
   exit -1
end
file = ARGV[0]

time = 0
maxprocs = 0
runningjobs = []
totaljobs = 0

GRANULARITY = 12*60

puts "Opening file #{file}..."

profile = File.new('out.csv','w')

text=File.open(file).read
text.gsub!(/\r\n?/, "\n")
text.each_line do |line|
   line.strip!
   if line[0] == ';'
      if line.include? 'MaxProcs'
         mp = line.split(':')[1].to_i
         maxprocs = mp if mp > 0
         puts "MaxProcs: #{maxprocs}" if mp > 0
      end
   else
      # columns extracted from http://www.cs.huji.ac.il/labs/parallel/workload/swf.html
      data = {}
      col = 1
      line.split(/\s/).each do |l|
         if l != nil and l.length > 0
            li = l.to_i
            case col
               when 2 #submit time
                  data[:st] = li
                  time = li  if time == 0  #initiates time to the submission time of the first job
               when 3 #wait time
                  data[:wt] = li
               when 4 #run time
                  data[:rt] = li
               when 5 #allocated processors
                  data[:ap] = li
            end
            col+=1
         end
      end
      totaljobs+=1
      runningjobs.push(data)
   end
end


puts "Read traces from #{totaljobs} jobs. Generating profiles..."

timeFromFirstJobSubmission = 0


while runningjobs.length > 0
   # Calculating AVG usage for a given time slice
   usedprocs = 0
   j = 0
   while j < runningjobs.length
      job = runningjobs[j]

      start = job[:st]+job[:wt]
      if start <= time
         start = [start,time-GRANULARITY].max
         endt = [time,job[:st]+job[:wt]+job[:rt]].min
         usedprocs += (endt-start)*job[:ap]
      end

      # Deleting already finished jobs
      if job[:st] + job[:wt] + job[:rt] <= time
         runningjobs.delete_at(j)
         j-=1
      end
      j+=1
   end

   print "\rProfile generation at #{100*(totaljobs-runningjobs.length)/totaljobs}%"
   percentage = [usedprocs.to_f/(maxprocs.to_f*GRANULARITY.to_f) , 1.0].min
   profile.write "#{timeFromFirstJobSubmission}\t#{percentage}\n"
   time+=GRANULARITY
   timeFromFirstJobSubmission+=GRANULARITY
end

puts "\nTask finished successfully"

profile.close



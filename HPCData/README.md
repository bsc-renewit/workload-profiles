# hpcwl
HPC Workload Profiles Generator

It parses a SWF file from the [Parallel Workloads Archive](http://www.cs.huji.ac.il/labs/parallel/workload/swf.html) and writes out a csv file called "out.csv".

Each row of the CSV file has two columns:

1st column: time, in seconds, since the submission of the first job.
2nd column: % of used CPUs in this time slice.

Now each row represent a time slice of 1 hour. If you want to change the granularity of the time slice, edit the code and change the value of the GRANULARITY constant, with the number of seconds between rows.

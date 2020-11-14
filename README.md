# 3D-Memory-Shutdown-Sequence
Helps compute the optimal sequence for shutdown of 3D memory to prevent overheating. Done by finding minimum value of maximum steady state temperature on shutting down 8 ranks of the base layer of memory.


```bash
$ python script.py
$ python script2.py
```
Running script.py returns the optimal values of leakage_flags for minimizing the maximum steady state temperature for access_pattern_flag = 0

After collecting a few notable results for access_pattern_flag = 0, running script2.py returns the access and temperature values of these patterns for access_pattern_flag values 0 to 4.

Starter Files: www.cse.iitd.ernet.in/~siddhulokesh/courses/assignment-2020.zip

Notable results: [result.txt](./result.txt)

Analysis Report: [Analysis-Report.pdf](./Analysis-Report.pdf)

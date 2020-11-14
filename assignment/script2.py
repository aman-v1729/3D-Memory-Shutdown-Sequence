#!usr/bin/python
import subprocess
import time
ctr = 0
bestresout = ""
bestmax = 200
bestconf=[]
for access_flag in range(5):
	for cs in [['0', '1', '0', '1', '1', '1', '0', '0', '0', '0', '1', '1', '1', '0', '1', '0'],['0', '1', '1', '0', '1', '0', '0', '1', '1', '0', '0', '1', '0', '1', '1', '0'],['1','0','1','0','1','0','1','0','1','0','1','0','1','0','1','0'],['1','0','1','0','0','1','0','1','1','0','1','0','0','1','0','1']]:
		p=subprocess.Popen(["./test2.sh"] + cs + [str(access_flag)], stdout=subprocess.PIPE)
		(output, err) = p.communicate()
		output = output[-300:]
		res = output.split("\n")[-2][:-1]
		#print(res)
		res = res.strip().split(", ")
		finres = [float(n) for n in res]
		print(cs, access_flag)
		#print(finres)
		print("\n".join(output.split("\n")[-5:][:-1]))


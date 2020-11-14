#!usr/bin/python
import subprocess
ctr = 0
bestresout = ""
bestmax = 200
bestconf=[]
for i in range(1, 65536):
	s = str(bin(i))[2:]
	if(s.count("1") == 8):
		ctr+=1
		print(ctr)
		cs = [c for c in s]
		cs = ["0"]*(16 - len(s)) + cs
		print(cs)
		p=subprocess.Popen(["./test2.sh"] + cs + ["0"], stdout=subprocess.PIPE)
		(output, err) = p.communicate()
		output = output[-300:]
		#print(output.split("\n"))
		#res = output[output.find("Base Layer Rank Temperatures from Channel 0 to 15"):-2]
		#print(output)	
		res = output.split("\n")[-2][:-1]
		#print(res)
		res = res.strip().split(", ")
		finres = [float(n) for n in res]
		print(finres)
		if(max(finres) < bestmax):
			bestconf = cs
			bestresout = output
			bestmax = max(finres)

			print(bestconf)
			print(bestmax)
			print("-------------------------------------------------------------------------------------")

print(bestconf)
print(bestmax)
print(bestresout)


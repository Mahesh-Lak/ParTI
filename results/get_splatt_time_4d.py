#!/usr/bin/python

import numpy as np
import sys 

# intput_path = '/global/homes/j/jiajiali/Work/ParTI-dev/timing-results/splatt/32bit-single-allmode/'
intput_path = '/global/homes/j/jiajiali/Work/ParTI-dev/timing-results/splatt/32bit-single-onemode/'

# s4tsrs = ['chicago-crime-comm-4d', 'uber-4d', 'nips-4d', 'enron-4d', 'flickr-4d', 'delicious-4d']
s4tsrs = ['chicago-crime-comm-4d', 'nips-4d', 'enron-4d', 'flickr-4d', 'delicious-4d']
test_tsrs = ['flickr-4d']
r = 16
m1_nums = []
m2_nums = []
m3_nums = []
m4_nums = []

# input parameters
t = sys.argv[1]

out_str = 'splatt-t' + str(t) + '.out'
print("Output "+out_str)
fo = open(out_str, 'w')

for tsr in s4tsrs:
	input_str = intput_path + tsr + '-r' + str(r) + '-t' + str(t) + '.txt'
	# print(input_str)

	fi = open(input_str, 'r')
	for line in fi:
		line_array = line.strip().split(" ")
		# print(line_array)

		if(len(line_array) == 4 and line_array[0] == 'mode'):
			if(line_array[2] == '1'):
				m1_nums.append(line_array[3].split("(")[1].split(")")[0].split("s")[0])
			elif(line_array[2] == '2'):
				m2_nums.append(line_array[3].split("(")[1].split(")")[0].split("s")[0])
			elif(line_array[2] == '3'):
				m3_nums.append(line_array[3].split("(")[1].split(")")[0].split("s")[0])
			elif(line_array[2] == '4'):
				m4_nums.append(line_array[3].split("(")[1].split(")")[0].split("s")[0])
		elif( (line_array[0] == '**' and line_array[1] == 'TTBOX') or line_array[0] == 'thd:' or line_array[0] == 'Timing'):
			m1_nums = map(float, m1_nums)
			m2_nums = map(float, m2_nums)
			m3_nums = map(float, m3_nums)
			m4_nums = map(float, m4_nums)
			sum_seq = np.average(m1_nums) + np.average(m2_nums) + np.average(m3_nums) + np.average(m4_nums)
			fo.write(str(np.average(m1_nums))+'\n')
			fo.write(str(np.average(m2_nums))+'\n')
			fo.write(str(np.average(m3_nums))+'\n')
			fo.write(str(np.average(m4_nums))+'\n')
			fo.write(str(sum_seq)+'\n')
			break;
		
	fi.close()
	m1_nums = []
	m2_nums = []
	m3_nums = []
	m4_nums = []

fo.close()






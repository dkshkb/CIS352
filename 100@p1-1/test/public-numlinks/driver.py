#!/usr/bin/python3
#####################################################
#############  LEAVE CODE BELOW  ALONE  #############
# Include base directory into path
import os, sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname( __file__ ), '..', '..')))

# Import tester
from tester import failtest, passtest, assertequals, runcmd, preparefile, runcmdsafe
#############    END UNTOUCHABLE CODE   #############
#####################################################

###################################
# Write your testing script below #
###################################
python_bin = sys.executable
import pickle

# prepare necessary files
preparefile('./test.rkt')

# run test file
runcmdsafe('rm ./output')
b_stdout, b_stderr, b_exitcode = runcmdsafe(f'racket ./test.rkt')


# convert stdout bytes to utf-8
stdout = ""
stderr = ""
try:
	stdout = b_stdout.decode('utf-8')
	stderr = b_stderr.decode('utf-8')
except:
	pass


# stdout comparison with expected.txt here
try:
	with open('answer', 'rb') as file1, open('output', 'rb') as file2:
		answer = int(file1.read())
		output = int(file2.read())
		if answer == output:
			runcmdsafe('rm ./output')
			passtest('')
		else:
			runcmdsafe('rm ./output')
			failtest(stdout+"\n\n"+stderr)
except FileNotFoundError:
	failtest(stdout+"\n\n"+stderr)

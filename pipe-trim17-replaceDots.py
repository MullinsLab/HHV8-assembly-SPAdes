#! /usr/bin/env python
# author: Alec Pankow
# date: 10/6/17

# This python script is based on a script written by Alexander Hill.
# It replaces any instance of a "." in a fastq sequence entry with "N".
# It also trims the first 17 nt of each read sequence. 

import getopt
import sys

opts, args = getopt.getopt(sys.argv[1:],"o:")
output = sys.stdout

for o,a in opts:  
    if o == "-o":
        output = open(a,'w')

with sys.stdin as fq:
    
    ct = 0
    
    for line in fq:
        
        ct += 1
    
        if ct == 1:
            output.write(line)
            
        elif ct == 2:
            output.write(line[17:].replace('.','N'))
            
        elif ct == 3:
            output.write(line)
            
        elif ct == 4:
            output.write(line[17:])
            ct = 0

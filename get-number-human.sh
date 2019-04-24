#! /bin/bash

echo -e "sample\thuman_mapped\thuman_unmapped"

for sample in "$@"; do
	mapped=$(samtools view -cF 4 "${sample%/}/human_aligned.bam")
	unmapped=$(samtools view -cf 4 "${sample%/}/human_aligned.bam")
	echo -e "${sample}\t${mapped}\t${unmapped}"
done 

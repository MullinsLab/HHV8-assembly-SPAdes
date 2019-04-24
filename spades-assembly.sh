function usage {
echo "Usage: $0 reads_for_assembly.bam"
}

if (( "$#" == "0" )); then 
	usage; exit 2
fi

BAM=$(basename "${1}")
EXPDIR=$(dirname "${1}")

## Edit location of reference and gene annotations here ## 
REF="/home/appankow/HHV8/genomes/AF148805-GK18.fa"
GENES="/home/appankow/HHV8/genomes/GK18.gff3.txt"

cd $EXPDIR

# convert back to fastq
samtools bam2fq -s singles.fq $BAM > interleaved.fq

# run spades
spades.py -k 21,35,55,71,81 -t 3 --careful -o spades_output --pe1-12 interleaved.fq --pe1-s singles.fq

# select all contigs longer than 500 bp
filter_contigs.py 500 spades_output/scaffolds.fasta

# run QUAST
quast.py -o quast -R $REF -G $GENES spades_output/scaffolds.filter500.fasta

# align those contigs to specified HHV8 reference
bwa mem $REF spades_output/scaffolds.filter500.fasta >> scaffolds-to-GK18.sam

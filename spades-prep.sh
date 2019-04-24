#! /bin/bash
# author: Alec Pankow
# date: 12.18.17

## Specify num cores, default output directory and path to hg38.fa reference sequence here ##
## The indicated path needs to be the prefix of the bwa index.                             ##
 
CORES=4
JOBS=1
OUTDIR="output"
HG38="/home/appankow/genomes_bwt/hg38.fa"
PHRED="sanger"

function usage {
        echo -e "\nUsage: $0 [ -o ouput_dir -t phred_encoding -@ threads -j jobs -h help ] -f paired_reads_1.fastq -r paired_reads_2.fastq\n"
}

if (( "$#" == "0" )); then
	usage; exit 2
fi

# options parser
while getopts "o:f:r:t:@:j:h" opt; do
        case "$opt" in
                o)      OUTDIR="${OPTARG%/}";;
                f)      R1+=("$OPTARG");;
                r)      R2+=("$OPTARG");;
		t)	PHRED=("$OPTARG");;
		@)	CORES=("$OPTARG");;
		j)	JOBS=("$OPTARG");;
		h) 	usage; exit 2;;
                \?) usage; exit 1;; 
        esac
done
shift $((OPTIND-1))

export PHRED
export HG38
export OUTDIR

# if necessary, make output directory
mkdir -p "$OUTDIR"

parallel --xapply echo "Processsing R1: {1}, and R2: {2} as read group {#}" ::: ${R1[@]} ::: ${R2[@]}

parallel -j $JOBS "cat {} | pipe-trim17-replaceDots.py >> ${OUTDIR}/R1_{#}.trimmed" ::: ${R1[@]}
parallel -j $JOBS "cat {} | pipe-trim17-replaceDots.py >> ${OUTDIR}/R2_{#}.trimmed" ::: ${R2[@]} 

cd "$OUTDIR"
mkdir -p logs

# quality filtering step according to PHRED score
echo "Quality filtering with $PHRED encoding"
parallel -j $JOBS --xapply "sickle pe -q 30 -t $PHRED -f {1} -r {2} -o {1.}.filtered -p {2.}.filtered -s {#}.singles >> logs/filter_{#}.log" ::: R1_*[0-9].trimmed ::: R2_*[0-9].trimmed

# cleanup trimmed files
rm *.trimmed

# align reads to human genome
parallel -j $JOBS --xapply "bwa mem -t $CORES $HG38 {1} {2} 2> logs/bwa_{#}.log | samtools view -bh - >> aln-{#}.bam" ::: R1*[0-9].filtered ::: R2*[0-9].filtered

# cleanup filtered files
rm *.filtered
rm *.singles

# merge read batches, if necessary
if (( "${#R1[@]}" > "1" )); then
	samtools merge -nr@ $CORES human_aligned.bam aln-*[0-9].bam
	rm aln-*[0-9].bam
else 
	mv aln-1.bam human_aligned.bam
fi

#extract unmapped reads
samtools view -bhf 4 human_aligned.bam > human_unmapped.bam

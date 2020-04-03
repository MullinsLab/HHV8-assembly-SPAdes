### Spades assembly pipeline

Contents

`spades-prep.sh`:

Preprocesses reads and aligns them to the indicated reference with BWA. 

`spades-assembly.sh`

Runs SPAdes **de novo** assembly and QUAST, orienting contigs to a reference sequence. 

Requirements:

- `GNU parallel`
- `pipe-trim17-replaceDots.py` (included)
- `sickle`
- `bwa mem`
- `samtools`
- `QUAST`
- `SPAdes`
- `filter_contigs.py` (included)

Configuration:

- Index human genome .fasta with `bwa` and specify path in `spades-prep.sh. 
- Specify path of reference sequence in `spades-assembly.sh`
- Specify path of annotation file in `spades-assembly.sh`
- Make sure all the scripts listed above are on PATH

The directory `testing` contains a test dataset. 

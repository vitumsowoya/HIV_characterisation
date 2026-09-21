HIV_characterisation

Assembling raw HIV sequencing reads into an annotated consensus genome, with subtype assignment and drug-resistance mutation screening.

⚠️ Work in progress. This pipeline currently runs as a series of manual shell steps. The next milestone is wrapping it in Nextflow for automation and HPC deployment.

Overview

This repository takes raw Illumina reads from an HIV sample and carries them through to a phylogenetically classified, annotated consensus genome. The workflow is:

Raw reads
   │
   ▼
Quality check (FastQC)
   │
   ▼
Adapter/quality trimming (Trimmomatic)
   │
   ▼
Re-check quality (FastQC)
   │
   ▼
De novo assembly (IVA) + assembly QC (QUAST)
   │
   ▼
Filter contigs by GC content (38–45%)
   │
   ▼
BLAST filtered contigs against NCBI nt (confirm HIV origin)
   │
   ▼
Remove short/non-HIV contigs (min length 1000 bp)
   │
   ▼
Reference-based mapping & consensus calling (BWA, samtools, iVar)
   │
   ▼
Visual inspection (IGV) + annotation (Liftoff, JBrowse)
   │
   ▼
Extract pol gene → drug resistance mutations (Stanford HIVDB)
   │
   ▼
Subtype phylogeny (MAFFT + IQ-TREE)

Repository contents
File / folder	Purpose
CHIV.sh	Main end-to-end pipeline script: QC → assembly → reference mapping → consensus genome
HIV_phylogeny.sh / phylogeny.sh / subtype_phylogeny.sh	Phylogenetic tree building and HIV subtype assignment
install_packages.sh	Sets up the hiv_pipeline conda environment with all required tools
hxb2.gff3	HXB2 reference annotation, used by Liftoff to annotate the consensus genome
consensus.md	Notes on the consensus-calling step
read_depth.R	Plots read depth/coverage across the genome
Visualising distributionof serotypes.R	Plots HIV subtype/serotype distribution
Malawi_HIV*_fastqc.html/.zip	Example FastQC reports (pre- and post-trimming)
all_subtypes_aligned_renamed.fa.*	Reference subtype alignment and IQ-TREE output files (tree, log, distance matrix, etc.)
copying_to_hpc.sh	Helper script for transferring data to/from an HPC cluster
git.md	Git usage notes for this project
assembly/	Assembly-related working files

Requirements

All tools are installed into a single conda environment:

FastQC
Trimmomatic
IVA (Iterative Virus Assembler)
QUAST
BLAST+ (with a local or --remote connection to NCBI nt)
seqkit / seqtk
BWA
samtools
iVar
Liftoff
MAFFT
IQ-TREE

Install everything with:

bash
bash install_packages.sh
conda activate hiv_pipeline

(This mirrors the conda create command at the top of CHIV.sh.)

You will also need:

An HIV reference genome (e.g. HXB2, HIV_ref.fasta) and its annotation (hxb2.gff3)
Reference sequences for subtypes B, C, D, F1, F2, G, N, O, P, SIVgor and SIVcpz for the phylogeny step
Internet access for the remote BLAST step and for submitting sequences to Stanford HIVDB

Usage
1. Quality check and trimming
bash
fastqc Malawi_HIV.fastq.gz
trimmomatic SE -phred33 \
  Malawi_HIV.fastq.gz Malawi_HIV.trimmed.fastq.gz \
  ILLUMINACLIP:TruSeq3-SE.fa:2:30:10 \
  LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

fastqc Malawi_HIV.trimmed.fastq.gz
2. De novo assembly and QC
bash
iva --fr Malawi_HIV.trimmed.fastq.gz iva_output
python3 ~/tools/quast-5.3.0/quast.py contigs.fasta -o quast_output
3. Filter contigs by GC content and confirm HIV origin
bash
cd iva_output
python3 gc_filter.py   # keeps contigs with 38–45% GC content
blastn -task megablast -query contigs_gc38_45.fasta -db nt -remote \
  -out results.txt -outfmt 6
seqkit seq -m 1000 contigs_gc38_45.fasta > contigs_gc_min1000.fasta
4. Reference-based mapping and consensus genome
bash
bwa index contigs_gc_min1000.fasta
bwa mem -t 4 contigs_gc_min1000.fasta Malawi_HIV.trimmed.fastq.gz > gc1000.sam
samtools view -bS gc1000.sam | samtools sort -o gc1000.bam
samtools index gc1000.bam
samtools view -F 4 gc1000.bam | cut -f1 | sort -u > mapped_reads.txt
seqtk subseq Malawi_HIV.trimmed.fastq.gz mapped_reads.txt > gc1000_mapped.fastq

bwa index HIV_ref.fasta
bwa mem -t 4 HIV_ref.fasta gc1000_mapped.fastq > aln.sam
samtools view -bS aln.sam | samtools sort -o aln.bam
samtools index aln.bam
samtools flagstat aln.bam > mapping_stats.txt
samtools coverage aln.bam > coverage_stats.txt
samtools depth -a aln.bam > depth.txt

samtools mpileup -A -d 0 -Q 0 -f HIV_ref.fasta aln.bam | \
  ivar consensus -p consensus -t 0.6
5. Visualisation and annotation
Inspect the alignment (aln.bam) in IGV.
Index the consensus genome and annotate it with Liftoff (using hxb2.gff3), then view it in JBrowse:
bash
samtools faidx HIV_consensus.fa
6. Drug resistance screening

Extract the pol gene and submit it to the Stanford HIV Drug Resistance Database:

bash
seqkit subseq -r 2097:5108 HIV_consensus.fa > pol.fasta
7. Subtype phylogeny

Concatenate the consensus genome with reference subtypes (B, C, D, F1, F2, G, N, O, P, SIVgor, SIVcpz) into all_subtypes_renamed.fa, then:

bash
mafft --auto --thread 4 all_subtypes_renamed.fa > all_subtypes_aligned_renamed.fa

iqtree \
  -s all_subtypes_aligned_renamed.fa \
  -m GTR+F+R5 \
  -bb 1000 \
  -alrt 1000 \
  -nt 4 \
  -redo

Visualise the resulting subtype/serotype distribution with Visualising distribution of serotypes. R, and read depth/coverage with read_depth.R.

Roadmap
 Chain all steps together with proper error handling instead of manual execution
 Port the pipeline to Nextflow for automation and reproducibility
 Run the automated pipeline on HPC
License

See LICENSE for details.

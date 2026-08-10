#!/bin/bash

# Install necessary packages
conda create -n hiv_pipeline -c conda-forge -c bioconda \
    fastqc \
    trimmomatic \
    iva \
    quast \
    blast \
    seqkit \
    bwa \
    samtools \
    ivar \
    liftoff \
    mafft \
    iqtree
conda activate hiv_pipeline
#1. Quality check
fastqc Malawi_HIV.fastq.gz

#2. If quality is good, proceed to trimming adapters
conda install -c bioconda trimmomatic
conda activate learning
trimmomatic SE -phred33 \
  Malawi_HIV.fastq.gz Malawi_HIV.trimmed.fastq.gz \
  ILLUMINACLIP:TruSeq3-SE.fa:2:30:10 \
  LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

#3. Briefly check quality of trimmed file
fastqc Malawi_HIV.trimmed.fastq.gz 

#4. If Quality is good, proceed to Assembly and visualise assembly stats

iva --fr Malawi_HIV.trimmed.fastq.gz iva_output

python3 ~/tools/quast-5.3.0/quast.py contigs.fasta -o quast_output

#5. Run a Python script that filters contigs with GC content between 38 and 45%
cd iva_output

python3 gc_filter.py

#6. BLAST your filtered contigs
blastn -task megablast -query contigs_gc38_45.fasta -db nt -remote -out results.txt -outfmt 6

#remove contigs which didn't BLAST positively to HIV, for me (which happened to be less than 1000 bases)
seqkit seq -m 1000 contigs_gc38_45.fasta > contigs_gc_min1000.fasta

#7. Map adapter-trimmed reads to the filtered contigs and curate consensus genome

bwa index Malawi_HIV.trimmed.fastq.gz 
bwa mem -t 4 Malawi_HIV.trimmed.fastq.gz contigs_gc_min1000.fasta  > aln.sam
bwa mem -t 4 HIV_ref.fasta Malawi_HIV.fastq.gz > aln.sam
samtools view -bS aln.sam | samtools sort -o aln.bam
samtools index aln.bam
samtools flagstat aln.bam > mapping_stats.txt
samtools coverage aln.bam > coverage_stats.txt
samtools depth -a aln.bam > depth.txt
samtools mpileup -A -d 0 -Q 0 -f HIV_ref.fasta aln.bam | ivar consensus -p consensus -t 0.6
#8. Visualise bam file using the interactive genome visualizer; you can download it from any of your browsers

#9. To visualise the annotated genome, use Jbrowse; you need a fai file for this
samtools faidx HIV_consensus.fa

#10. Extract the polymerase gene and upload to Stanford HIVDB
seqkit subseq -r 2097:5108 HIV_consensus.fa > pol.fasta

#11. Phylogeny; download subtypes B, C, D, F1, F2, G, N, O, P, SIVgor and SIVciz and concatenate them together with the consensus genome into all_subtypes_renamed.fa
mafft --auto --thread 4 all_subtypes_renamed.fa > all_subtypes_aligned_renamed.fa
iqtree \
-s all_subtypes_aligned_renamed.fa \
-m GTR+F+R5 \
-bb 1000 \
-alrt 1000 \
-nt 4 \
-redo

#WAY FORWARD: To connect each step without human interference by adding logic functions and using variables, then later use NEXTFLOW and run the script on HPC.

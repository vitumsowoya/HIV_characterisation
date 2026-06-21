#!/bin/bash

#Quality check
fastqc Malawi_HIV.fastq.gz

#If Quality is good, proceed to Assembly
iva --fr Malawi_HIV.fastq.gz iva_output

#open the directory containing assembled reads (contigs)
cd iva_output

#blast your contigs
blastn -task megablast -query contigs.fasta -db nt -remote -out results.txt -outfmt 6

#Validate your results by uploading the highest performing contigs to REGA 

#Index the subtype specific reference downloaded manually in a local database
bwa index HIV_ref.fasta

#align
bwa mem -t 4 HIV_ref.fasta Malawi_HIV.fastq.gz > aln.sam

# fix BAM pipeline
samtools view -bS aln.sam | samtools sort -o aln.bam
samtools index aln.bam

#visualise bam file using the interactive genome visualiser, you can download it from any of your browsers

consensus assembly
samtools mpileup -A -d 0 -Q 0 -f HIV_ref.fasta aln.bam | ivar consensus -p consensus -t 0.6

#install mamba because it is faster than conda at resolvoing dependencies
conda install -n base -c conda-forge mamba

#create a new environment to run liftoff which will be used for annotating the genome
mamba create -n liftoff_env

#activate the environment
conda activate liftoff_env

#install liftoff
mamba install -c conda-forge -c bioconda liftoff

#check if it is working
liftoff -h

#transfer the annotations from the reference gff3 to your consensus genome, creating a new gff3
liftoff -g HIV_ref_2.gff3 -o HIV_annotation.gff3 HIV_consensus.fa HIV_Ref_2.fasta

#To use jbrowse, create fai file
samtools faidx HIV_consensus.fa

seqkit subseq -r 2097:5108 HIV_consensus.fa > pol.fasta

#upload to HIVDB to characterise the resistome

#to visualise, use python, download jbroswer from edge/chrome/whatever browser, upload HIV_consensus.fa, HIV_consensus.fai and the gff3 file from liftoff

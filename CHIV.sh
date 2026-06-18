#!/bin/bash

#Quality check
fastqc Malawi_HIV.fastq.gz

#If Quality is good, proceed to Assembly
iva --fr Malawi_HIV.fastq.gz iva_output

#Indext the HIV_ref.fasta
bwa index HIV_ref.fasta

#align
bwa mem -t 4 HIV_ref.fasta Malawi_HIV.fastq.gz > aln.sam

# fix BAM pipeline
samtools view -bS aln.sam | samtools sort -o aln.bam
samtools index aln.bam

# 8. consensus assembly
samtools mpileup -A -d 0 -Q 0 -f HIV_ref.fasta aln.bam | ivar consensus -p consensus -t 0.6

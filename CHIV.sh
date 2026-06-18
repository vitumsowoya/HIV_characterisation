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

# 8. consensus assembly
samtools mpileup -A -d 0 -Q 0 -f HIV_ref.fasta aln.bam | ivar consensus -p consensus -t 0.6

#!/bin/bash

#conda activate cytb_phylo

bwa index ../contigs_gc_min1000.fasta 
bwa mem -t 12 ../contigs_gc_min1000.fasta /home/vmsowoya/HIV_characterisation/Malawi_HIV.fastq.gz | samtools view -b - | samtools sort -@ 12 -m 512M -o mapped.sorted.bam
samtools flagstat mapped.sorted.bam
samtools view -b -F 4 mapped.sorted.bam > mapped_only.bam
samtools flagstat mapped_only.bam
samtools sort mapped_only.bam -o mapped_only.sorted.bam
samtools index mapped_only.sorted.bam 
samtools idxstats mapped_only.sorted.bam > idxstats.txt
samtools fastq mapped_only.sorted.bam > hiv_reads.fastq
mkdir consensus
cd consensus
bwa index /home/vmsowoya/HIV_characterisation/assembly/iva_output/alignment/hxb2.fasta 
bwa mem -t 8 /home/vmsowoya/HIV_characterisation/assembly/iva_output/alignment/hxb2.fasta ../hiv_reads.fastq > aln.sam
samtools view -bS aln.sam | samtools sort -o aln.bam
samtools index aln.bam
samtools flagstat aln.bam > mapping_stats.txt
samtools coverage aln.bam > coverage_stats.txt
samtools depth -a aln.bam > depth.txt
samtools depth -a aln.bam | awk '{sum+=$3} END {print sum/NR}'
#visualise bam file using the interactive genome visualiser, you can download it from any of your browsers
conda activate ivar_env
samtools mpileup -A -d 0 -Q 0 -f /home/vmsowoya/HIV_characterisation/assembly/iva_output/alignment/hxb2.fasta aln.bam | ivar consensus -p consensus -t 0.6


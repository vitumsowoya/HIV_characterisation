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

#to visualise, use python, first install
from dna_features_viewer import GraphicFeature, GraphicRecord

features = [
    GraphicFeature(start=801, end=2304, strand=+1, label="gag"),
    GraphicFeature(start=2096, end=5108, strand=+1, label="pol"),
    GraphicFeature(start=5052, end=5631, strand=+1, label="vif"),
    GraphicFeature(start=5570, end=5862, strand=+1, label="vpr"),
    GraphicFeature(start=5842, end=8436, strand=+1, label="tat"),
    GraphicFeature(start=5981, end=8665, strand=+1, label="rev"),
    GraphicFeature(start=6073, end=6322, strand=+1, label="vpu"),
    GraphicFeature(start=6236, end=8807, strand=+1, label="env"),
    GraphicFeature(start=8808, end=9429, strand=+1, label="nef"),
]

record = GraphicRecord(
    sequence_length=9719,
    features=features
)

ax, _ = record.plot(figure_width=15)
ax.figure.savefig("HIV_genome_map.png", dpi=300)

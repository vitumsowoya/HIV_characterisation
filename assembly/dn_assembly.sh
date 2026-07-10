#!/bin/bash

#conda activate iva_new
iva --fr ../Malawi_HIV.trimmed.fastq.gz iva_output
cd iva_output
python3 ~/tools/quast-5.3.0/quast.py contigs.fasta -o quast_output
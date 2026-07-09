#!/bin/bash

mafft --auto --thread 4 hiv_phylo.fa > all_subtypes_aligned.fa
seqkit rename all_subtypes_aligned.fa -o all_subtypes_aligned_renamed.fa
iqtree \
-s all_subtypes_aligned_renamed.fa \
-m GTR+F+R5 \
-bb 1000 \
-alrt 1000 \
-nt 4 \
-redo

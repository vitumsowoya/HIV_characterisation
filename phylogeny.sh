#!/bin/bash

seqkit rename hiv_phylo.fa -o all_subtypes_renamed.fa
mafft --auto --thread 4 all_subtypes_renamed.fa > all_subtypes_aligned_renamed.fa
iqtree \
-s all_subtypes_aligned_renamed.fa \
-m GTR+F+R5 \
-bb 1000 \
-alrt 1000 \
-nt 4 \
-redo

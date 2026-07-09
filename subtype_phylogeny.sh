#!/bin/bash

#SBATCH --job-name=hiv_phylo_gpu            # Job name
#SBATCH --output=GPU-Test%j.out             # Standard output file (%j = jobID)
#SBATCH --error=GPU-Test%j.err              # Standard error file
#SBATCH -p gpu-nodes                        # GPU partition/queue
#SBATCH --gres=gpu:1                        # Request 1 GPU
#SBATCH -N 1                                # Number of nodes
#SBATCH -n 4                               # Number of tasks (cores)
#SBATCH --mem=30G                          # Memory allocation
#SBATCH --time=7:00:00                      # Walltime (hh:mm:ss)
#SBATCH --mail-type=ALL                     # Notifications for all events
#SBATCH --mail-user=vmsowoya@mlw.mw         # Your email for notifications

# Load required modules (adjust to your HPC environment)
module load MAFFT/7.520-GCC-12.3.0-with-extensions
module load iqtree/2.3.6

# Run workflow
mafft --auto --thread 4 all_subtypes_renamed.fa > all_subtypes_aligned_renamed.fa
iqtree \
-s all_subtypes_aligned_renamed.fa \
-m GTR+F+R5 \
-bb 1000 \
-alrt 1000 \
-nt 4 \
-redo

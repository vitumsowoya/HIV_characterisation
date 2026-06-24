
#Use the cytb_phylo because it has the necessary packages installed
conda activate cytb_phylo

#login to HPC

#download 20-50 subtype specific seqences for whole genome HIV and concatenate into one document
cat HIV_B.fasta HIV_C.fasta HIV_D.fasta HIV_P.fasta> HIV_phylo_trial.fa

# Step 1: Align sequences with MAFFT
mafft --auto hiv_phylo_trial2.fa > HIV_phylo_trial_aligned.fa

# Step 2: Build phylogenetic tree with IQ-TREE 2
iqtree -s HIV_phylo_trial_aligned.fa -m GTR+G -bb 1000 -nt AUTO

#to create consensus genomes
mafft --auto HIV_B_metadata.fasta > b_aligned.fa
seqkit rename b_aligned.fa -o b_aligned_renamed.fa
cons -sequence b_aligned_renamed.fa -outseq b_consensus.fa
#
cat subtype_a1_ref.fasta subtype_c_ref.fasta subtype_b_ref.fasta subtype_d_ref.fasta > hiv_subtypes.fa
mafft --auto hiv_subtypes.fa > hiv_subtypes_aligned.fa
iqtree -s hiv_subtypes_aligned.fa -m TEST -redo -nt AUTO
conda install artemis

#SBATCH --error=GPU-Test%j.err
#SBATCH  -p gpu-nodes
#SBATCH --gres=gpu:1
#SBATCH  -N 1
#SBATCH  -n 16
#SBATCH --mem=120G
#SBATCH --time=1:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=vmsowoya@mlw.mw


#module load mafft \
iqtree

#cellranger count --id=samples_pbmc \
           --transcriptome=refdata-gex-GRCh38-2020-A \
           --fastqs=pbmc_1k_v3_fastqs \
           --sample=samples_C.csv \
           --create-bam=true \
           --localcores=16 \
           --include-introns \
           --localmem=120
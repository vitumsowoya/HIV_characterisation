
#Use the cytb_phylo because it has the necessary packages installed
conda activate cytb_phylo

#login to HPC

#download 20-50 subtype specific seqences for whole genome HIV and concatenate into one document
cat HIV_B.fasta HIV_C.fasta HIV_D.fasta HIV_P.fasta> HIV_phylo_trial.fa

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
#conda create -n ivar_env
conda activate ivar_env
bwa index hxb2.fasta
bwa mem -t 4 hxb2.fasta ../contigs_gc_min1000.fasta > aln.sam
samtools view -bS aln.sam | samtools sort -o aln.bam
samtools index aln.bam
samtools coverage aln.bam > coverage_stats.txt
samtools flagstat aln.bam > mapping_stats.txt
samtools depth -a aln.bam > depth.txt
samtools depth -a aln.bam | awk '{sum+=$3} END {print sum/NR}'
samtools mpileup -A -d 0 -Q 0 -f hxb2.fasta aln.bam | ivar consensus -p consensus -t 0.6

from Bio import SeqIO

input_fasta = "contigs.fasta"
output_fasta = "contigs_gc38_45.fasta"

with open(output_fasta, "w") as out_handle:
    for record in SeqIO.parse(input_fasta, "fasta"):
        seq = str(record.seq).upper()

        gc_count = seq.count("G") + seq.count("C")
        gc_percent = (gc_count / len(seq)) * 100

        if 38 <= gc_percent <= 45:
            SeqIO.write(record, out_handle, "fasta")

print("Filtering complete.")

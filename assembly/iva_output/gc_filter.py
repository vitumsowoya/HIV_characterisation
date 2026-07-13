from Bio import SeqIO

with open("hiv_gc_filtered.fasta", "w") as out:
    for record in SeqIO.parse("contigs.fasta", "fasta"):
        seq = str(record.seq).upper()
        gc = (seq.count("G") + seq.count("C")) / len(seq) * 100
        if 39 <= gc <= 45:
            SeqIO.write(record, out, "fasta")

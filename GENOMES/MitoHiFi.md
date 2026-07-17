# Mitochondrial Genome identification

## BLAST
1. Create database of sequences

    `makeblastdb -in cytb_alignment.clean.fasta -dbtype nucl -parse_seqids -out cytb_database `

2. Blast query against database
```
blastn   -db cytb_database   \
    -query ../../genome/Pegre-CLP3001_assembled_blood.fa   \
    -task megablast   \
    -num_threads 5   \
    -outfmt '6 qseqid sseqid pident length qlen slen qstart qend sstart send evalue bitscore'  \
    -out hifi_to_cytb.tsv
```
3. Review output

    **Option 1**: Sum alignment lengths per contig (query) 

    `awk '{sum[$1]+=$4} END {for (c in sum) print c, sum[c]}' hifi_to_cytb | sort -k2,2nr | head `

    **Option 2**: Count unique hits per contig (query)

    ` awk '{print $1,$2}' hifi_to_cytb | sort -u | awk '{count[$1]++} END {for (c in count) print c, count[c]}' | sort -k2,2nr | head `

4. Extract candidate Mitochondrial Genome 

    `samtools faidx Pegre-CLP3001_assembled_blood.fa contig_42 > mito_candidate.fa`
5. BLAST candidate against published data

    `blastn -query mito_candidate.fa -db nt -remote`

## MitoHifi
1. Install docker image
    ` apptainer pull ghcr.io/marcelauliano/mitohifi:master `

2. Run MitoHifi
``` 
apptainer exec --bind /home/tecorn/mitohifi/:/home/tecorn/mitohifi docker://ghcr.io/marcelauliano/mitohifi:master findMitoReference.py --species "Plestiodon egregius" --outfolder . 

apptainer exec --bind /home/tecorn/mitohifi/:/home/tecorn/mitohifi docker://ghcr.io/marcelauliano/mitohifi:master mitohifi.py -c /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/Pegre-CLP3001_assembled_blood.fa -f AB016606.1.fasta -g AB016606.1.gb -t 6 -o 2
```
This found a mitochondrial genome (GenBank: AB016606.1)
https://www.ncbi.nlm.nih.gov/nuccore/AB016606.1/ 

```
samtools sort -o reads.HiFiMapped.sorted.bam reads.HiFiMapped.bam
samtools index reads.HiFiMapped.sorted.bam
```

```
samtools depth reads.HiFiMapped.sorted.bam | \
> awk '{sum+=$3; n++} END {print "Mean depth =",sum/n}'
Mean depth = 1200.2
```

```
cat atg000001l.individual.stats
atg000001l	No frameshift found	potential_contigs/atg000001l/atg000001l.mitogenome.rotated.gb	17388	37	True
```



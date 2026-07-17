### tidk

```sh
source activate tidk
tidk build
idk search -s TTAGGG --dir output/ --output hifi_hic_scaffold ../04_YaHs/Pegre-CLP3001_hifi_hic_scaffold_genome.fasta
tidk plot --tsv hifi_hic_scaffold_telomeric_repeat_windows.tsv 
```

```sh

Now check the telomeric regions
addded tidk to yahs_env
tidk search -s TTAGGG \
  --dir tidk_out \
  --output Scutulatus_1832_trimmed \
  --extension bedgraph \
  yahs.out_trimmed_scaffolds_final.fa


but did not create the .tsv file i need so I ran:
tidk search -s TTAGGG \
  --dir tidk_out \
  --output Scutulatus_1832_trimmed \
  yahs.out_trimmed_scaffolds_final.fa


This worked now i need to run another thing to generate the graph:
tidk plot \
  --tsv tidk_out/Scutulatus_1832_trimmed_telomeric_repeat_windows.tsv \
  --output tidk_out/Scutulatus_1832_telomere_plot



Now for the turtle for telomere plot
tidk search -s TTAGGG \
  --dir tidk_out \
  --output Turtle_trimmed \
  yahs.out_scaffolds_final.fa


This worked now i need to run another thing to generate the graph:
tidk plot \
  --tsv tidk_out/Turtle_trimmed_telomeric_repeat_windows.tsv \
  --output tidk_out/Turtle_telomere_plot
```

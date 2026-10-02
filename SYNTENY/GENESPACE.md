# Genespace

### GENESPACE directory layout
```sh
├── output_figures
├── raw_genomes
│   ├── Pegregius.fasta
│   ├── Pegregius.gff
│   ├── Pgilberti.fasta
│   └── Pgilberti.gff
├── scripts
│   ├── bed
│   ├── format_genespace.sh
│   ├── formatgff2bed.sh
│   ├── get_genes_gtf.py
│   ├── gtf_class.py
└── working_dir
```

### format files
```sh
cd raw_genomes/
../scripts/format_genespace.sh Pgilberti ../working_dir/
```

### run orthofinder

```sh
module load orthofinder
orthofinder -f <peptide dir> -t 12 -a 1 -X -o /project/viper/venom/Taryn/Plestiodon/synteny/GENESPACE/working_dir/orthofinder
```

### open R studio

```sh
GENESPACE.R
```

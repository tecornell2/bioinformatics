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

## open R studio
```sh
devtools::install_github("jtlovell/GENESPACE")

#library("Biostrings")
#library("rtracklayer")
```

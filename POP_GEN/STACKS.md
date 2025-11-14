NextRAD libraries were generated from genomic DNA (150-bp single-end reads). 

```sh

~/stacks-2.68/process_radtags -f ./00_raw/816/ -o ./process_radtags_output/ -b ./barcodes_run816.txt \
  --inline_null -c -q  -r --filter_illumina -i gzfastq
# -f single paired-end reads
# -c clean
# -r rescue barcodes and RAD-tags
# -i input file type
```


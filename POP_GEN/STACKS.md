NextRAD libraries were generated from genomic DNA (150-bp single-end reads). 

```sh
# -f for single paired-end reads
process_radtags -f ./raw/rad_data.fq -o ./samples/ -b ./barcodes/barcodes -e sbfI -r -c -q
```


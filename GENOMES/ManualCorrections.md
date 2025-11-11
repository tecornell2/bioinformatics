# Manual Corrections of Genome Assembly

## Plot contig size relative to scaffolds
1. Import chr_plot_relative_size.py and scaffolds_size
2. Generate a summary file from the ragtag.scaffold.agp (in ragtag_output folder)
```sh
awk '$5=="W" {print $1"\t"$6"\t"$9}' ragtag.scaffold.agp | sort | uniq > ragtag_scaffold_summary.txt
```
3. Run chr_plot_relative_size.py

## Hi-C Contact Map review
1. Download Juicebox
2. Open .hic file from Juicer pipeline
3. Load annotation files: TAD Annotations, Loop Annotations, and Compartment Data (Show → Annotations → 1D Annotations/2D Annotations → Add Local)

Resource: https://ngs101.com/how-to-analyze-hi-c-data-for-absolute-beginners-from-raw-reads-to-3d-genome-organization-with-juicer/

## BLAST

## RagTag contigs and scaffolds
1. RagTag contigs and scaffolds to closest reference genome relative available
2. Identify contigs (from query genome) that associate with different chromosomes/locations compared to the scaffolded genome, relative to the reference genome

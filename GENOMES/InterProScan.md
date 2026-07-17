```sh
#!/bin/bash
#SBATCH --job-name=07_InterProScan_Nfasc
#SBATCH --output=07_InterProScan_Nfasc_output
#SBATCH --nodes=1
#SBATCH --partition=nodeviper
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=21
#SBATCH --mem=200gb
#SBATCH --time=40:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=tecorn@clemson.edu

# load java
module load java/11.0.2

INTERPROSCAN=/home/tecorn/interproscan/interproscan-5.76-107.0/interproscan.sh
INPUT=/project/viper/venom/Taryn/Nerodia/Nfasciata/07_annotation/interproscan/Nfasc_longIso.gtf
OUTDIR=/project/viper/venom/Taryn/Nerodia/Nfasciata/07_annotation/interproscan/output

mkdir -p $OUTDIR

$INTERPROSCAN \
  -i $INPUT \
  -f XML,GFF3,TSV \
  -dp \
  -cpu 20 \
  -appl Pfam,SMART,TIGRFAM,CDD \
  -iprlookup \
  -goterms \
```

script from Joh Hen:

```sh
#!/bin/bash
#SBATCH --job-name=InterProScan
#SBATCH --output=InterProScan_output
#SBATCH --error=InterProScan_error
#SBATCH --nodes=1
#SBATCH --partition=nodeviper
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=370gb
#SBATCH --time=120:00:00

# Load Java (required by InterProScan)
module load java/11.0.2

INTERPROSCAN=/home/johnhen/Databases/funannotate_databases/interproscan-5.75-106.0/interproscan.sh
INPUT=/project/viper/venom/John_Henry/Turtle/03_Funannotate/funannotate_predict_output/predict_results/Geoemyda_japonica.proteins.fa
OUTDIR=/project/viper/venom/John_Henry/Turtle/03_Funannotate/interproscan_output

mkdir -p $OUTDIR

$INTERPROSCAN \
  -i $INPUT \
  -f XML,GFF3,TSV \
  -dp \
  -cpu 24 \
  -appl Pfam,SMART,TIGRFAM,CDD \
  -iprlookup \
  -goterms \

```

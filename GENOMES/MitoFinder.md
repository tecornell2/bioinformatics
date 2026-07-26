
### set up

```sh
singularity pull --arch amd64 library://remiallio/default/mitofinder:v1.4.2 

```

```sh
#!/bin/bash

#SBATCH --job-name MitoFinder_Plest
#SBATCH --output MitoFinder_test_output
#SBATCH --partition nodeviper
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 48gb
#SBATCH --time 100:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

module load gnuparallel
module load biocontainers
module load megahit


MITO_REF="/project/viper/venom/Taryn/Plestiodon/Pegregius/genome/mito/MitoHifi/output/final_mitogenome.gb"
TRIM_DIR="/project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/01_trim_galore"
MITO_DIR="/project/viper/venom/Taryn/Plestiodon/Pegregius/mtDNA"

export MITO_REF TRIM_DIR MITO_DIR

parallel -a 00_samples_list4.txt -j 2 '

    echo "Started {1}"

    cd $TRIM_DIR
    cd {1}


    ####### PREP READS
	if [ ! -s "{1}*_R1.trim.fq.gz" ]; then

        echo "Concatenating reads for {1}..."

        cat {1}_R1.run1.fq.gz {1}_R1.run2.fq.gz > {1}_R1.trim.fq.gz
        cat {1}_R2.run1.fq.gz {1}_R2.run2.fq.gz > {1}_R2.trim.fq.gz
    fi

    R1="$TRIM_DIR/{1}_R1.trim.fq.gz"
    R2="$TRIM_DIR/{1}_R2.trim.fq.gz"


    ####### MITO FINDER

    cd $MITO_DIR
    mkdir -p MitoFinder/{1}/
    cd MitoFinder/{1}/

    echo "Running MitoFinder on {1}..."
    singularity run ~/mitofinder_v1.4.2.sif -j {1} -1 $R1 -2 $R2 -r $MITO_REF -o 2 -p 8 -m 24

    echo "Finished {1}"
'

```
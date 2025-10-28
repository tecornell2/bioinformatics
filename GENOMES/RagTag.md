## RagTag

Use RagTag to scaffold a drafted genome with a closely related reference genome. 

#### .job file
```sh
#!/bin/bash
#SBATCH --job-name ragtag_scaff_Nfasc
#SBATCH --output agtag_scaff_Nfasc_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 136gb
#SBATCH --time 24:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

  cd /project/viper/venom/Taryn/Nerodia/Nfasciata/07_ragtag
  
  module load anaconda3/2023.09-0
  source activate ragtag

  ragtag.py scaffold ThaEle.pri_genomic.fa Nfasc-CLP2811_genome.fasta \
    -o ragtag_out \
    -t 16
```

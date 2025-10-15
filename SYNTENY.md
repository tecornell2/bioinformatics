#### MiniMap2 alignment
```sh
# download ncbi genome to align to
wget -O ThaEle.zip '{API URL}'
unzip ThaEle.zip
# rename .fna to .fa
```

```sh
#!/bin/bash

#SBATCH --job-name synt_Nfasc_Tele
#SBATCH --output synt_Nfasc_Tele_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 6
#SBATCH --mem 48gb
#SBATCH --time 5:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

cd /project/viper/venom/Taryn/Nerodia/Synt

module load anaconda3/2023.09-0
source activate minimap2
minimap2 -x asm10 Nerodia_clarkii.fa Nerodia_fasciata.fa > Nclar_Nfasc_aln.pfa
conda deactivate
```
---

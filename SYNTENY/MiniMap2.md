#### MiniMap2 alignment
```sh
# download ncbi genome to align to
wget -O ThaEle.zip '{API URL}'
unzip ThaEle.zip
# rename .fna to .fa ????
```

```sh
#!/bin/bash

#SBATCH --job-name synt_Pele_Pfasc_Pgil
#SBATCH --output synt_Pele_Pfasc_Pgil_output
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 48gb
#SBATCH --time 10:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user tecorn@clemson.edu

cd /project/viper/venom/Taryn/Plestiodon/synteny/alignments

module load anaconda3/2023.09-0
source activate minimap2

minimap2 -x asm10 -t 7 /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/Pegre-CLP3001_assembled_blood.fa /project/viper/venom/Taryn/Plestiodon/Pfasciatus/ncbi_dataset/rPleFas1.1.fa > Pegre_Pfasc_aln.pfa

minimap2 -x asm10 -t 7 /project/viper/venom/Taryn/Plestiodon/Pegregius/genome/Pegre-CLP3001_assembled_blood.fa /project/viper/venom/Taryn/Plestiodon/Pgilberti/any2fasta/rPleGil1.0.hap2.fa > Pegre_Pgilb_aln.pfa

conda deactivate
```
---

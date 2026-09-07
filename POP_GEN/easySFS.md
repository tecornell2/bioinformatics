# easySFS


### step 1
```sh
./easySFS.py -i /project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/03_vcf_filter_test/run5/filter_v2 \
    -p run5_popmap.txt --preview -a -o preview
```

### step 2
```sh
easySFS.py -i /project/viper/venom/Taryn/Plestiodon/Pegregius/nextRAD/03_vcf_filter_test/run5/filter_v2 \
    -p run5_popmap.txt  -a --proj=50,50 -o output
```

### full example:
```sh
BASE="/project/viper/venom/Taryn/Plestiodon/Pegregius"

./easySFS.py \
    -i ${BASE}/nextRAD/03_vcf_filter_test/run5/filter_v2/demographic_dataset.recode.vcf \
    -p ${BASE}/popgen/easySFS/run5/run5_popmap.txt \
    --preview -a \
    -o ${BASE}/popgen/easySFS/run5/
```

```sh
#!/bin/bash
#SBATCH --job-name STACKS_01_process
#SBATCH --output STACKS_01_process_output
#SBATCH --nodes 1
#SBATCH --cpus-per-task 30
#SBATCH --mem 28gb
#SBATCH --time 20:00:00
#SBATCH --mail-type ALL
#SBATCH --mail-user email@clemson.edu

BASE="/project/viper/venom/Taryn/Plestiodon/Pegregius"

~/easySFS/easySFS.py  
    -i ${BASE}/nextRAD/03_vcf_filter_test/run5/filter_v2/demographic_dataset.recode.vcf \
    -p run5_popmap_v2.txt -a --proj 32,40,22,20,20,4,6 -o output
```

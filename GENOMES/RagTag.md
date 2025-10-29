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

---

Stats on Assembly [bbstats]
Compariosn of statistics before and after RagTag scaffold

```sh
bbstats.sh in=Nclar-CLP2810_assembled_blood.bp.p_ctg.fasta out=Nclar-CLP2810_assembled_blood.bp.p_ctg.fasta.stats.txt Xmx64g
```


<details><summary> bbstats .txt output file</summary>


```sh
A	      C	      G	      T	      N	      IUPAC	  Other	  GC	    GC_stdev
0.2936	0.2064	0.2062	0.2938	0.0000	0.0000	0.0000	0.4126	0.0558

Main genome scaffold total:         	818
Main genome contig total:           	818
Main genome scaffold sequence total:	1869.125 Mb
Main genome contig sequence total:  	1869.125 Mb  	0.000% gap
Main genome scaffold N/L50:         	13/49.916 Mbp
Main genome contig N/L50:           	13/49.916 Mbp
Main genome scaffold N/L90:         	90/1.506 Mbp
Main genome contig N/L90:           	90/1.506 Mbp
Max scaffold length:                	155.878 Mbp
Max contig length:                  	155.878 Mbp
Number of scaffolds > 50 KB:        	658
% main genome in scaffolds > 50 KB: 	99.70%
```

</details>

<details><summary> bbstats .txt output file</summary>


```sh
A	      C	      G	      T	      N	      IUPAC	   Other	GC	    GC_stdev
0.2936	0.2065	0.2061	0.2938	0.0000	0.0000	0.0000	0.4126	0.0630

Main genome scaffold total:         	418
Main genome contig total:           	818
Main genome scaffold sequence total:	1869.165 Mb
Main genome contig sequence total:  	1869.125 Mb  	0.002% gap
Main genome scaffold N/L50:         	6/105.5 Mbp
Main genome contig N/L50:           	13/49.916 Mbp
Main genome scaffold N/L90:         	16/41.113 Mbp
Main genome contig N/L90:           	90/1.506 Mbp
Max scaffold length:                	240.092 Mbp
Max contig length:                  	155.878 Mbp
Number of scaffolds > 50 KB:        	301
% main genome in scaffolds > 50 KB: 	99.78%
```

</details>
<p></p>

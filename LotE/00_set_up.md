### 00_set_up

R/3.1.4 had to be downloaded locally to my $HOME on the HPC

When setting up .sh files in /-scripts-/... \
$WORKING_DIR is the directory with bioconductor.sif

Run ```00_setup_life_on_the_edge.sh``` interactively (not a batch script)
* although it was written as a SLURM batch job, the command 'singularity exec' is inherently interactive
* copy/paste .sh script line by line
* skip all updates when downloading packages

### 01_input data
* genomic data must be in PLINK format
* spatial data must be a .csv with coordinate in decimal degrees <sample,lat,long>

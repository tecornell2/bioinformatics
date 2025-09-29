# TERMINAL SET UP

**Palmetto Cluster Access**
```sh
  ssh <username>@slogin.palmetto.clemson.edu
```

## Linux/Unix basic commands

```sh
    # change current working directory to its immediate parent directory
    cd ..
    
    # copy document to different directory
    cp my_document.pdf /home/user/documents/

    # copy file to different directory and rename it
    cp /path/to/original/file.txt /path/to/destination/new_file_name.txt

    # rename a file or directory
    mv old_filename new_filename
    mv old_directory_name new_directory_name 

    # create new folder
    mkdir directory_name

    # view contents of a file in the terminal
    cat filename

    # edit a file
    nano filename

```

## .bashrc

```sh
# color styles
# export PS1='\[\033[0;32m\]\u@\h\[\033[00m\]:\[\033[0;37m\]\w\[\033[00m\]\$ '
export PS1='\[$(tput setaf 15)\](\[$(tput setaf 70)\]\u\[$(tput setaf 15)\]@\[$(tput setaf 214)\]\h\[$(tput setaf 15)\])-[ \[$(tput setaf 38)\]\w\[$(tput setaf 15)\]]\[$(tput sgr0)\]$ '

## aliases

alias conda3='module load anaconda3/2023.09-0'
alias assembly='source activate asm_env'
alias r_stat='module load r/4.3.0'
alias interactive='salloc --nodes=1 --ntasks-per-node=1 --cpus-per-task=16 --mem=48G --time=12:00:00'
alias nero='cd /project/viper/venom/Taryn/Nerodia/'
alias save_scratch='find /scratch/tecorn -used tecorn -exec touch {} +'
alias check='squeue -u tecorn'
```

Resource for altering bash prompt: https://robotmoon.com/bash-prompt-generator/ https://bash-prompt-generator.org/ 

## Anaconda

```sh
 # load anaconda into terminal
 module load anaconda3/2023.09
```

**Navigating Anaconda**

```sh
 # list your environments
 conda env list

 # remove an environment
 conda env remove -n env_name
```

**Create Environments and load packages**
```sh
 # load module anaconda in an interactive job
 module load anaconda3/2023.09
 # create environment (ex. assembly environmnet) to save packages (hifiasm)
 # the addition of mamba loads mamba while creating the environment
 conda create -n hifiasm mamba
 conda activate hifiasm
 mamba install -c bioconda hifiasm
```

```sh
 module load anaconda3/2023.09
 # create enviornment for BBMap (includes bbstats, samtools)
 conda create -n bbmap mamba
 conda activate bbmap
 mamba install -c bioconda bbmap
```

```sh
conda create -n edta mamba
conda activate edta
mamba install -c conda-forge -c bioconda edta
```

```sh
conda create -n blobtools2 mamba
conda activate blobtools2
mamba install -c conda-forge docopt pyyaml ujson tqdm nodejs -c bioconda pysam seqtk 
```

```sh
conda create -n pasa mamba
conda activate pasa
mamba install -c bioconda pasa
```

## funannotate
use an Apptainer



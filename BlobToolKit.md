### blobtoolkit 


#### set-up
```sh
# create anaconda environment
module load anaconda3/2023.09-0
conda create -n blob
conda activate blob
pip install blobtoolkit[full]

# fetch api and viewer binaries
RELEASE=4.1.5
PLATFORM=linux # or macos
curl -L https://github.com/blobtoolkit/blobtoolkit/releases/download/${RELEASE}/blobtoolkit-api-${PLATFORM} > blobtoolkit-api
curl -L https://github.com/blobtoolkit/blobtoolkit/releases/download/${RELEASE}/blobtoolkit-viewer-${PLATFORM} > blobtoolkit-viewer
chmod 755 blobtoolkit-*

# api and viewer must be in the directory immediately outside of the data set
```

#### create directory
```sh
# create directory
conda activate blob
blobtools create --fasta Nerodia_clarkii.fasta --meta Nerodia_clarkii.yaml --taxdump ~/taxdump Nerodia_clarkii

# add data set to directory
blobtools add --busco /project/viper/venom/Taryn/Nerodia/Nclarkii/03_BUSCO/03_BUSCO_output/run_tetrapoda_odb12/full_table.tsv Nerodia_clarkii
```

#### run viewer and api
```sh
# open 3 terminal windows, first 2 on the login node
# first terminal launches api
BTK_API_PORT=8880 BTK_PORT=8881 BTK_FILE_PATH=/home/user/blobtoolkit/datasets ./blobtoolkit-api

# second terminal launches viewer
BTK_API_PORT=8880 BTK_PORT=8881 ./blobtoolkit-viewer

# third terminal for remote access
ssh -L 8881:localhost:8881 -L 8880:localhost:8880 tecorn@slogin.palmetto.clemson.edu
# login to HPC
```

Open this window to view plot:
http://localhost:8881/view/all

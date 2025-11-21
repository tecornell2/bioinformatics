## Set-up

Following install instructions: https://cd-barratt.github.io/Life_on_the_edge.github.io/Vignette


```sh
# use apptainer to download bioconductor.sif
apptainer remote add --no-login SylabsCloud cloud.sycloud.io
apptainer remote use SylabsCloud
apptainer pull --arch amd64 library://sinwood/bioconductor/bioconductor_3.14:0.0.1
```

## Data import
1. Env predictor data
  * **WorldClim future scenarios**:
    - SSP1 (ssp126), SSP2 (ssp245). SSP5 (ssp585)
    - 30 second spatial resolution
    - time scales 2021-2040 <insert others>
  * **WorldClim current**: 
2. PLINK and MaxEnt
3. Country border

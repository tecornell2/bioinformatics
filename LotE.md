## Set-up

Following install instructions: https://cd-barratt.github.io/Life_on_the_edge.github.io/Vignette

```sh
# use apptainer to download bioconductor.sif
apptainer remote add --no-login SylabsCloud cloud.sycloud.io
apptainer remote use SylabsCloud
apptainer pull --arch amd64 library://sinwood/bioconductor/bioconductor_3.14:0.0.1
```


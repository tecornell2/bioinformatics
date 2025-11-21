## Set-up

apptainer remote add --no-login SylabsCloud cloud.sycloud.io
apptainer remote use SylabsCloud
apptainer pull --arch amd64 library://sinwood/bioconductor/bioconductor_3.14:0.0.1

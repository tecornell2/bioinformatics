Source: https://github.com/sanger-tol/PretextMap

# Install
```sh
conda create -n pretext
source activate pretext
conda install pretext-suite
```
# Generate .pretext file
```sh
# for ultraRes 40G ram requirement
samtools view -h Pegre-CLP3001_hic_aligned_sorted.bam | PretextMap -o Pegre-CLP3001_hic_map.pretext --ultraRes
```

Source: https://github.com/sanger-tol/PretextView

# Install

```sh
# Intel Mac running macOS Ventura 13.7.8
# ensure develop tools and more are installed
xcode-select --install
brew --version

# clone source code
git clone https://github.com/sanger-tol/PretextView.git
cd PretextView

# install.sh script specifically for building the application
chmod +x install.cmake.sh
./install.cmake.sh

# open app
open ./build_cmake/PretextViewAI.app
```

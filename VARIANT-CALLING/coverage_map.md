# BAM coverage calculator

```sh
library(dplyr)
library(data.table)

setwd("/project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/02_align/CLPT1251/")

dat <- fread(
  "CLPT1251_depth.txt"
)

colnames(dat) <- c('CHROM', 'POS', 'DEPTH')

dat %>%
  summarise(
    prop_epth_0  = mean(DEPTH == 0, na.rm = TRUE),
    prop_epth_1x  = mean(DEPTH == 1, na.rm = TRUE),
    prop_DEPTH_1_5x  = mean(DEPTH >= 1 & DEPTH <= 5, na.rm = TRUE),
    prop_DEPTH_5_10x = mean(DEPTH >= 5 & DEPTH <= 10, na.rm = TRUE),
    prop_DEPTH_10_20x = mean(DEPTH >= 10 & DEPTH <= 20, na.rm = TRUE),
    prop_DEPTH_20_30x = mean(DEPTH >= 20 & DEPTH <= 30, na.rm = TRUE),
    prop_DEPTH_over30x = mean(DEPTH >= 31, na.rm = TRUE)
  )
```

# karyoploteR package

```sh
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("karyoploteR")
library(karyoploteR)
library(tidyverse)

# load in genome chr position file
setwd("/project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/genome/")
genome <- data.frame(read_tsv("CLP3001_genome_draft_chr_pos.txt"))
gg <- toGRanges(genome)

# set parameters
pp <- getDefaultPlotParams(plot.type = 4)
pp$ideogramlateralmargin <- 0
pp$leftmargin <- 0.07


# plot background
kp <- plotKaryotype(genome = gg, chromosomes=c("ptg000004l"), plot.type=4, ideogram.plotter = NULL, labels.plotter = NULL, plot.params = pp)
kpAddCytobandsAsLine(kp)
kpAddChromosomeNames(kp, srt=45)
kpAddLabels(kp, "Contigs", data.panel = "ideogram")
kpDataBackground(kp)
kpAddLabels(kp, "Data Density", srt=90)
kpAxis(kp, ymin=0, ymax=kp.density$latest.plot$computed.values$max.density)

kpPlotBAMDensity(kp, data="/project/viper/venom/Taryn/Plestiodon/Pegregius/WGS/02_align/CLPT1251/CLPT1251_aligned_sorted_marked_RG.bam", window.size = 1000)

ggsave("plotBAMdensity_test.png")
```

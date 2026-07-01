# BAM coverage calculator

```sh
#!/bin/bash

Rscript BAM_depth_proportions_calc
```

```sh
library(dplyr)
library(data.table)
library(argparser)

# capture terminal arguments as a character vector
args <- commandArgs(trailingOnly = TRUE)

# Verify if an argument was actually provided
if (length(args) == 0 || file_ext(args) != "txt") {
  stop("Error: No .txt file provided", call. = FALSE)
}

# read in file
argi <- arg_parser(description = "This Rscript will create an relief-shaded admixture map in pdf format from in input admixture dataframe and a coordinates file. 
                                  The script requires the R libraries 'terra', 'mapmixture', 'ggplot2', 'gridExtra', and 'argsparser'.
                                  See README.txt for more information.", name = "MapMixture for All!")

argi <- add_argument(argi, arg = 'samtools_depth_output', help = "The samtools depth txt file is the output of the command samtools depth <.bam> < filename_depth.txt")

args <- parse_args(argi)

colnames(dat) <- c('CHROM', 'POS', 'DEPTH')

table <- dat %>%
  summarise(
    prop_depth_0  = mean(DEPTH == 0, na.rm = TRUE),
    prop_epth_1x  = mean(DEPTH == 1, na.rm = TRUE),
    prop_depth_1_5x  = mean(DEPTH >= 1 & DEPTH <= 5, na.rm = TRUE),
    prop_depth_5_10x = mean(DEPTH >= 5 & DEPTH <= 10, na.rm = TRUE),
    prop_depth_10_20x = mean(DEPTH >= 10 & DEPTH <= 20, na.rm = TRUE),
    prop_depth_20_30x = mean(DEPTH >= 20 & DEPTH <= 30, na.rm = TRUE),
    prop_depth_over30x = mean(DEPTH >= 31, na.rm = TRUE)
  )

write_table("CLPT1258")
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

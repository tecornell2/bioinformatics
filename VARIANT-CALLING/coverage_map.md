# BAM Coverage Map

```sh
library(tidyverse)

dat <- read_tsv(
  "CLPT1251_depth.txt",
  col_names = c("contig", "position", "depth"),
  show_col_types = FALSE
)

# number of positions with 0 depth
sum(dat$depth == 0, na.rm =T)


dat_by_contig <- dat %>%
  group_split(contig, .keep = TRUE)

names(dat_by_contig) <- dat %>%
  distinct(contig) %>%
  pull(contig)

depth %>%
  summarise(
    pct_1x = mean(depth >= 1),
    pct_5x = mean(depth >= 5),
    pct_10x = mean(depth >= 10),
    pct_20x = mean(depth >= 20),
    pct_30x = mean(depth >= 30)
  )

# plot across chr
ggplot(dat_by_contig[["ptg000001l"]], aes(x = position, y = depth)) +
  geom_line(linewidth = 0.2) +
  labs(x = "Position on ptg000001l",
    y = "Depth",
    title = "Coverage across ptg000001l") +
  ylim(0,100) +
  theme_bw()

ggsave("ptg000001l_plot_test.png")

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

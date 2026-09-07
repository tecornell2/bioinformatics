library(ggplot2)
library(tidyverse)
library(readxl)
library(scales)
library(patchwork)
library(gridExtra)

install.packages("gridExtra")

# script to visiualize nextRAD data using STACKS ref_map.pl

### --------------------------------
### Generate summary stats files
### --------------------------------

#### terminal commands
# cat populations.log | grep -A 4 '^Removed' > kept_loci.txt

# stacks-dist-extract gstacks.log.distribs bam_stats_per_sample \ | cut -f 1-4,6-7 > ref_aligned_stats_per_sample.tsv

# verify at least two alignment statistics including, 
## 1) the number of  primary records (alignments) kept per sample, and
## 2) the fraction of records kept.

### --------------------------------
### Import data
### --------------------------------

## sample info

sample.info <- read_xlsx('C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Samples/2018/RADseq_Mercier.xlsx', col_names = TRUE, sheet = 'fastq_files')

## process_radtags

#process1 <-
  
#process2 <-

## gstacks
run1 <- read_tsv('C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Data_Analysis/STACKS/ref_map/run1/ref_aligned_stats_per_sample.tsv', col_names = TRUE)

run2 <- read_tsv('C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Data_Analysis/STACKS/ref_map/run2/ref_aligned_stats_per_sample.tsv', col_names = TRUE)

run3 <- read_tsv('C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Data_Analysis/STACKS/ref_map/run3/ref_aligned_stats_per_sample.tsv', col_names = TRUE)

#run4 <- read_tsv('C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Data_Analysis/STACKS/ref_map/run/', col_names = TRUE)

## populations


### --------------------------------
### Merge dataframes
### --------------------------------


ref_aligned_stats <- merge(run1, sample.info, by.x='sample', by.y='sampleID')

ref_aligned_stats <- ref_aligned_stats %>% select(-c(location, popmap_grouping_STACKS, popmap_STACKS_v1, popmap_STACKS_v2))

### --------------------------------
### Plot
### --------------------------------

ref_aligned_stats <- ref_aligned_stats %>% arrange((primary_kept))

# kept primary reads per sample
p1 <- ggplot(ref_aligned_stats, aes(x = primary_kept, y = fct_inorder(sample))) + 
  theme_classic() +
  xlab("Retained Reads") +
  ylab("nextRAD Sample") +
  geom_point(shape=1) + 
  geom_vline(xintercept = mean(ref_aligned_stats$primary_kept), linetype = "dotted", color = "red", linewidth = 0.75) +
  theme(axis.text = element_text(size = 7),
        panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.5)) +
  scale_x_continuous(labels = unit_format(unit = "M", scale = 1e-6))

print(p1)

# kept primary reads per sample by spp.
p2 <- ggplot(ref_aligned_stats, aes(x = primary_kept, y = subspecies)) + 
  theme_classic() +
  xlab("Retained Reads") +
  ylab("Subspecies") +
  geom_boxplot(outlier.shape = 1) + 
  theme(panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.5)) +
  scale_x_continuous(labels = unit_format(unit = "M", scale = 1e-6))

print(p2)

####

ref_aligned_stats <- ref_aligned_stats %>% arrange((kept_frac))

p3 <- ggplot(ref_aligned_stats, aes(x = kept_frac, y = fct_inorder(sample))) + 
  theme_classic() +
  xlab("Proportion of Retained Reads") +
  ylab("nextRAD Sample") +
  geom_point(shape=1) + 
  geom_vline(xintercept = mean(ref_aligned_stats$kept_frac), linetype = "dotted", color = "red", linewidth = 0.75) +
  theme(axis.text = element_text(size = 7),
        panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.5)) +
  scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, by = 0.10))

print(p3)

# kept primary reads per sample by spp.
p4 <- ggplot(ref_aligned_stats, aes(x = kept_frac, y = subspecies)) + 
  theme_classic() +
  xlab("Proportion of Retained Reads") +
  ylab("Subspecies") +
  geom_boxplot(outlier.shape = 1) +
  theme(panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.5)) +
  scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, by = 0.20))

print(p4)

### --------------------------------
### Save Plot
### --------------------------------

plot <- grid.arrange(p1,p2,p3,p4, top = "STACKS ref_map.pl run1", ncol=2, 
                     layout_matrix = rbind(c(1, 1, 2),
                                           c(1, 1, 2),
                                           c(3, 3, 4),
                                           c(3, 3, 4))
)

ggsave("run1.png", plot,  width = 8, height = 11, dpi = 300 , units = c("in"))



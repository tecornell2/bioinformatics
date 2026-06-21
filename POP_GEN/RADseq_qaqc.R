library(ggplot2)
library(tidyverse)
library(readxl)
library(gridExtra)

# script to visualize nextRAD data set 

### --------------------------------
### Import fastQC data
### --------------------------------

RADseq.stats <- read_tsv('C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Samples/2018/fastQC/multiqc_data/general_stats_table.tsv', col_names = TRUE)

sample.info <- read_xlsx('C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Samples/2018/RADseq_Mercier.xlsx', col_names = TRUE, sheet = 'fastq_files')


### --------------------------------
### Merge dataframes
### --------------------------------


RADseq.final <- merge(RADseq.stats, sample.info, by.x='Sample', by.y='sampleID')

RADseq.final$Seqs<-as.numeric(RADseq.final$Seqs)


### --------------------------------
### Plot seq reads summary
### --------------------------------

#make histogram of number of sequence reads for each sample
p1 <- ggplot(RADseq.final, aes(x=Seqs))+
  geom_histogram(color="black", fill="white", bins=20)+
  geom_vline(aes(xintercept=median(Seqs)), color = "red")+
  geom_vline(aes(xintercept=median(Seqs)*.1), color = "red", lty=14)+
  theme_classic()+
  xlab("Number of sequencing reads (million bp)") +
  ylab("Count (samples)") +
  scale_x_continuous(breaks = c(0,2,4,6,8,10,12,14))

p2 <- ggplot(RADseq.final, aes(x=Seqs, fill=subspecies))+
  geom_histogram(color="black", bins=20)+
  geom_vline(aes(xintercept=median(Seqs)), color = "red")+
  geom_vline(aes(xintercept=median(Seqs)*.1), color = "red", lty=14)+
  theme_classic()+
  xlab("Number of sequencing reads (million bp)") +
  ylab("Count (samples)") +
  scale_x_continuous(breaks = c(0,2,4,6,8,10,12,14))

ggsave("nextRAD_trimmed_hist.png", p1,  width = 8, height = 8, dpi = 300 , units = c("in"))


#solid red line = median sample value
#dashed red line = 10% of median sample value
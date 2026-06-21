install.packages("RADstackshelpR")
install.packages("gridExtra")
library(RADstackshelpR)
library(gridExtra)

### --------------------------------
### Generate dataframes from STACKS .vcf files
### --------------------------------

# default m=3
# default M=2
# default n=2

M_out <- optimize_bigM( 
  M1 = 'C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Methods/STACKS/denovo_param_optimization/bigM/M1_populations.snps.vcf', 
  M2 = NULL, 
  M3 = 'C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Methods/STACKS/denovo_param_optimization/bigM/M3_populations.snps.vcf', 
  M4 = 'C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Methods/STACKS/denovo_param_optimization/bigM/M4_populations.snps.vcf', 
  M5 = NULL, 
  M6 = NULL, 
  M7 = NULL, 
  M8 = 'C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Methods/STACKS/denovo_param_optimization/bigM/M8_populations.snps.vcf' )

m_out <- optimize_m(
  m3 = 'C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Methods/STACKS/denovo_param_optimization/m3_populations.snps.vcf', 
  m4 = 'C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Methods/STACKS/denovo_param_optimization/m4_populations.snps.vcf', 
  m5 = 'C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Methods/STACKS/denovo_param_optimization/m5_populations.snps.vcf', 
  m6 = 'C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Methods/STACKS/denovo_param_optimization/m6_populations.snps.vcf', 
  m7 = 'C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Methods/STACKS/denovo_param_optimization/m7_populations.snps.vcf')

n_out <- optimize_n(
  nequalsMminus1 = NULL, 
  nequalsM = NULL, 
  nequalsMplus1 = NULL)

### --------------------------------
### Visualize depth of samples
### --------------------------------

# function takes the list of dataframes output by optimize_m() as input

vis_depth(output = m_out)

### --------------------------------
### Visualize number of retained polymorphic loci 
### --------------------------------

# function takes the list of dataframes output by optimize_m(), optimize_M(), or optimize_n() as input

vis_loci(output = M_out, stacks_param = "M")

vis_loci(output = m_out, stacks_param = "m")

vis_loci(output = n_out, stacks_param = "n")


### --------------------------------
### Visualize number of retained SNPs
### --------------------------------

# function takes the list of dataframes output by optimize_m(), optimize_M(), or optimize_n() as input

vis_snps(output = M_out, stacks_param = "M")

vis_snps(output = m_out, stacks_param = "m")

vis_snps(output = n_out, stacks_param = "n")


### --------------------------------
### Organize plots into a figure
### --------------------------------

#load gridExtra package to combine ggplot visualizations

#combine all of these prior visulizations in a single list
gl<-list()
gl[[1]]<-vis_depth(output = m_out)
#> [1] "Visualize how different values of m affect average depth in each sample"
gl[[2]]<-vis_snps(output = m_out, stacks_param = "m")
#> Visualize how different values of m affect number of SNPs retained.
#> Density plot shows the distribution of the number of SNPs retained in each sample,
#> while the asterisk denotes the total number of SNPs retained at an 80% completeness cutoff.
gl[[3]]<-vis_loci(output = m_out, stacks_param = "m")

grid.arrange(grobs = gl, widths = c(1,1,1,1,1,1),
             layout_matrix = rbind(c(1,1,2,2,3,3))
)

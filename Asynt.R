install.packages("intervals")
source("asynt.R")

alignments <- import.paf("name.paf.gz")

#import scaffold length data
ref_data <- import.genome(fai_file="examples/dplex_mex.fa.fai")
query_data <- import.genome(fai_file="examples/Dchry2.2.fa.fai")

###############  Filtering and finding meaningful alignments  #################


# Remove short alignments
# Rlen and Qlen give the number of bases on the reference aand query that are included in an alignment tract
alignments <- subset(alignments, Rlen >= 200 & Qlen >= 200)

#Remove short scaffolds
#Some assembly scaffolds are too short for meaningful analysis.
alignments <- subset(alignments, ref_data$seq_len[reference] >= 1000000 & query_data$seq_len[query] >= 1000000)

#subset to a specific scaffold of interest
#If there is already a scaffold in the reference you are most interested in, you can remove all others
alignments <- subset(alignments, reference == "mxdp_9")

# now we usually only care about query scaffolds that share a large proportion of aligned sequence with the reference scaffold
# We can find these by looking at the total alignemnt length for each scaffold
query_aln_len <- get.query.aln.len(alignments)
barplot(query_aln_len, las=2)
# this shows that only two scaffolds have extansive alignments with our target reference scaffold

#a similar approach can be used with aligned proportion, which may be more appropriate if query scaffolds are very variable in length
query_aln_prop <- get.query.aln.prop(alignments, query_lens = query_data$seq_len)
barplot(query_aln_prop, las=2)

#now subset the alignments for only those contigs with large proportion aligned to the reference contig of interest
alignments <- subset(alignments, query_aln_prop[query] > 0.1)

#and finally we can visualise the alignemnt (see more examples of visualisation below)
plot.alignments.multi(alignments, reference_lens=ref_data$seq_len, query_lens=query_data$seq_len, sigmoid=T)


###############  multiple scaffold plot of synetny blocks  ####################

synblocks <- get.synteny.blocks.multi(alignments, min_subblock_size=200)
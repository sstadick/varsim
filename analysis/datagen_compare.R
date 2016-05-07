
# Read in a vcf file


# Read in a bed file (aka truth set)


# build a dataframe that has each sample as a row
# EX: hg38_vaf_20_bwa_mutect, hg38_vaf_20_bwa_varscan...etc
# Columns will be: 
# true positive snps, false positive snps, total in truth set, ture positive indels, false postive indels, total in truth set


# Another data frame per sample
# Columns will be:
# Mutation called, actual mutation (T/F), caller pass/fail, type, mutation, region???

make_truth_df <- function(samplepath, sampfiles, mutset) {
  if (mutset == "snp"){
    pos <- grep("snp.bed", sampfiles)
  } else {
    pos <- grep("indel.bed", sampfiles)
  }
  path <- paste(samplepath, sampfiles[pos], sep="/")
  truth_df <- read.table(path, header=F, sep="\t", fill=T)
  if (mutset == "indel"){
    colnames(truth_df) <- c("Chromosome", "start", "end", "VAF", "Mut Type", "New Base")
  } else {
    colnames(truth_df) <- c("Chromosome", "start", "end", "VAF", "Sequence")
  }
  truth_df
}

# Will create a row to add to master_list
# | Sample name | snp True Positves | snp False Positives | Total snp Truth Mut | indel True Positives | indel False Positives | Total indel Truth Mut
process_snp <- function(roi_snp_df, variant_snp_df, samplename){
  samplename_array <- strsplit(samplename, "_")[[1]]
  if (grepl("^hg", samplename_array[1]) != T) {
    samplename_array <- c("hg38", samplename_array)
  }
  new_samplename <- paste(samplename_array[1:5], collapse="_", sep="_")
  # Get snp numbers
  roisnplookup <- paste(roi_snp_df[[1]], roi_snp_df[[2]], sep=":")
  varsnplookup <- paste(variant_snp_df[[1]], variant_snp_df[[2]], sep=":")
  snphits = c()
  snppos= c()
  for (search in varsnplookup) {
    pos<-grep(search, roisnplookup)
    if (length(pos)>0){
      # Ignores quality assigned by caller
      snphits<-c(snphits, roisnplookup[pos])
      snppos<-c(snppos, pos)
    }
    #print(snphits)
  }
  all <- c(1:140)
  missed <- setdiff(all, snppos)
  missedsnps <- roi_snp_df[missed,]
  print(class(missedsnps))
  write.xlsx(as.data.frame(missedsnps), "/Users/pgdx-seth/Documents/irp_2016/DATA/analysis/set6/missed_snp.xlsx", sheetName=new_samplename, append=T)
  
  # if (grepl("hg19", new_samplename) && !grepl("novo_varscan", new_samplename)) {
  #   print("adding to hg19 missed")
  #   hg19_missed <- c(hg19_missed, missedsnps)
  #   print(hg19_missed)
  # } else if (grepl("hg38", new_samplename) && !grepl("novo_varscan", new_samplename)) {
  #   hg38_missed <- merge(hg38_missed, missedsnps, all.x=T, all.y=T)
  # }
  
  ## This is where the positions for the maching entries are stored ##
  matching_snps <- roi_snp_df[snppos,]
  snp_true_pos <- length(snphits)
  total_snp <- length(roi_snp_df[[1]])
  print(grepl("mutect", new_samplename))
  print(nrow(matching_snps))
  if (nrow(matching_snps) > 0) {
    write.xlsx(as.data.frame(matching_snps), "/Users/pgdx-seth/Documents/irp_2016/DATA/analysis/set7/compare_snp.xlsx", sheetName=new_samplename, append=T)
  }
  # Ignore Keep / Reject
  # if (grepl("mutect", new_samplename)) {
  #   total_found_snps<- length(grep("KEEP", variant_snp_df$judgement))
  #   print(total_found_snps)
  # } else if (grepl("varscan", new_samplename)) {
  #   total_found_snps <- length(variant_snp_df[[1]])
  # }
  total_found_snps <- length(variant_snp_df[[1]])
  false_positive_snp<- (total_found_snps - snp_true_pos)
  percent_error <- (total_snp - snp_true_pos) / total_snp
  if (false_positive_snp < 0){ false_positive_snp <- 0}
  sample_row <- c("SampleName"=new_samplename, "TruePostive"=snp_true_pos, "FalsePositive"=false_positive_snp, 
                  "TotalFoundSNPs"=total_found_snps, "TotalTruthSNPs"=total_snp, "PercentError"=percent_error)
  return(sample_row)
}

process_indel <- function(roi_indel_df, variant_indel_df, samplename) {
  # Normalize file names
  samplename_array <- strsplit(samplename, "_")[[1]]
  if (grepl("^hg", samplename_array[1]) != T) {
    samplename_array <- c("hg38", samplename_array)
  }
  new_samplename <- paste(samplename_array[1:5], collapse="_", sep="_")
  varindellookup <- paste(variant_indel_df[[1]], variant_indel_df[[2]], sep=":")
  indelhits = c()
  indelpos = c()
  roiindellookup <- c()
  count <- 1
  for (var in roi_indel_df[[1]]) {
    toadd<- paste(var, c((roi_indel_df[count,2] - 50):(roi_indel_df[count,2] + 50)), sep=":")
    roiindellookup <- c(roiindellookup, toadd)
    count = count + 1
  }
  #write(roiindellookup, file="~/Desktop/outtest.txt")
  # find matches
  # Currently showing 0 matches
  for (search in varindellookup) {
    pos <- grep(search, roiindellookup)
    if (length(pos)>0){
      indelhits<-c(indelhits, roiindellookup[pos])
      indelpos<-c(indelpos, pos)
    }
  }
  ## This is where the positions for the maching entries are stored ##
  matching_indels <- roi_indel_df[indelpos,]
  indel_true_positives <- length(indelhits)
  total_indels <- length(roi_indel_df[[1]])
  # Can't use pos to find match in indels because I do the +- 50 thing
  # print(matching_indels)
  # if (nrow(matching_indels) > 0) {
  #   write.xlsx(as.data.frame(matching_indels), "/Users/pgdx-seth/Documents/irp_2016/DATA/analysis/set5/compare_indels.xlsx", sheetName=new_samplename, append=T)
  # }
  
  total_found_indels <- length(variant_indel_df[[1]])
  false_postive_indels <- total_found_indels - indel_true_positives
  percent_error <- (total_indels - indel_true_positives) / total_indels
  if (false_postive_indels < 0) { false_postive_indels <- 0 }
  sample_row <- c("SampleName"=new_samplename, "TruePostive"=indel_true_positives, "FalsePositive"=false_postive_indels, 
                  "TotalFoundIndels"=total_found_indels, "TotalTruthIndels"=total_indels, "PercentError"=percent_error)
}


create_plots <- function(gen_list, plotbasename) {
  df <- as.data.frame(gen_list)
  df2<-data.frame(t(df))
  #x11()
  library(gridExtra)
  pdf(file=(paste("~/Documents/irp_2016/DATA/analysis", plotbasename)), height=11, width=8, paper='a4r', onefile=FALSE)
  #grid.arrange(tableGrob(df2, name="Differences in Variant Calling Tools"))
  grid.table(df2)
  dev.off()
}

# "Main"
basedir <- "~/Documents/irp_2016/DATA/reportsync/"
sampdirs <- list.files(path<-basedir)
#sampdirs <- "hg19_vaf_2_data"
snp_list <- list()
indel_list <- list()
sample_dfs_list <- list
hg19_missed <<- data.frame()
hg38_missed <<- data.frame()

# Iterate through every sample I've generated and make a dataframe of it. 
for (dir in sampdirs) {
  # Read in the truth set bed files
  sampledirpath<-paste(basedir, dir, sep="")
  sampdirfiles<-list.files(path<-sampledirpath)
  #sampdirfiles<-c("hg19_vaf_2_novo_varscan", "hg19_vaf_2_indel.bed", "hg19_vaf_2_snp.bed")
  #Not Processing Dream yet
  if (grepl("dream", sampledirpath)) {
    next
  }
  snp_df <- make_truth_df(sampledirpath, sampdirfiles, mutset="snp")
  indel_df <- make_truth_df(sampledirpath, sampdirfiles, mutset="indel")
  
  # Read in the vcf
  for (sample in sampdirfiles) {
    variant_snp_df <- data.frame()
    variant_indel_df <- data.frame()
    snp <- F
    indel <- F
    print(paste("Processing sample: ", sample))
    if (grepl("mutect", sample)){
      path <- paste(sampledirpath, sample, sep="/")
      variant_snp_df <- read.table(path, sep="\t", fill=T, skip=1, header=T)
      snp <- T
    } else if (grepl("varscan2_callstats_snp", sample) || grepl("varscan_callstats_snp", sample)){
      path <- paste(sampledirpath, sample, sep="/")
      variant_snp_df <- read.table(path, sep="\t", fill=T, header=T)
      snp <- T
    } else if (grepl("varscan2_callstats_indel", sample) || grepl("varscan_callstats_indel", sample)){
      path <- paste(sampledirpath, sample, sep="/")
      variant_indel_df <- read.table(path, sep="\t", fill=T, header=T)
      indel <- T
    } else {
      next
    }
    
    if (snp == T)  {
      toappend<-process_snp(snp_df, variant_snp_df, sample)
      snp_list <- c(snp_list, list("Sample"=toappend))
    } else if (indel == T) {
      toappend<-process_indel(indel_df, variant_indel_df, sample)
      indel_list<- c(indel_list, list("Sample"=toappend))
    } else{
      next
    }
    # I've read in all the data files here
    # Process them, append to master data frame as per above
    # create data frame for this sample
  }
}

#create_plots(snp_list, "snp_plot")
df <- as.data.frame(snp_list)
df2 <- data.frame(t(df))
write.csv(df2, "~/Documents/irp_2016/DATA/analysis/set7/snp.csv")
#create_plots(indel_list, "indel_plot")
df <- as.data.frame(indel_list)
df2 <- data.frame(t(df))
write.csv(df2, "~/Documents/irp_2016/DATA/analysis/set6/indel.csv")
write.xlsx(hg19_missed, "/Users/pgdx-seth/Documents/irp_2016/DATA/analysis/set7/missed_snp.xlsx", sheetName="hg19_missed", append=T)
write.xlsx(g38_missed, "/Users/pgdx-seth/Documents/irp_2016/DATA/analysis/set7/missed_snp.xlsx", sheetName="hg38_missed", append=T)


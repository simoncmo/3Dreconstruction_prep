library(Seurat)
library(tidyverse)
library(dplyr)
library(purrr)
library(optparse)


source('./functions/extract_images.r')
source('./functions/make_sample_info_table.r')

##---------------------------------------------------------------
##                        Parse options                         -
##---------------------------------------------------------------

option_list <- list(
    make_option(c("-i", "--input"), type = "character", default = NULL,
                help = "Seurat object with muliple slices"),
    make_option(c("-n", "--name"), type = "character", default = "3DRecon",
                help = "Name of this group of samples"),
    make_option(c("-o", "--output"), type = "character", default = ".",
                help = "Path to the output directory"), 
    make_option(c("-s", "--sample_column"), type = "character", default = NULL,  
                help = "Seurat Meta data column with name of each sample"),
    make_option(c("-a", "--assay_name"), type = "character", default = NULL,
                help = "Name of the Assay containing cell type proportions")
)   

args = parse_args(OptionParser(option_list=option_list))

##---------------------------------------------------------------
##                        Load object                           -
##---------------------------------------------------------------
message('loading object ..')
st = readRDS(args$input)

##---------------------------------------------------------------
##                        Extrat table                         -
##---------------------------------------------------------------

# Extract
info_table = Make3DReconstructTable(st, 
	sample_column = args$sample_column,
	assay_name    = args$assay_name
)

# Save 
path_table = file.path(args$output, 'table')
dir.create(path_table)
write_tsv(info_table, 
	paste0(path_table, '/', args$name, '_info_table.tsv')
)


##---------------------------------------------------------------
##                        Extrat Low Res Image  				-
##---------------------------------------------------------------

dir.create('image')
# Extract image
ExtractAllSeuratSTLowResImage(st, 
	path = file.path(args$output, 'image')
)





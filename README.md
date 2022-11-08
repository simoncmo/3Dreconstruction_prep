# 3Dreconstruction Preperation
- Instruction and script to generate files needed for 3D reconstruction tool by Tao and Aiden 

## The workflow_script.r can extract Slice, coordinate and Cell type proportion information needed to used in the 3D reconstrunction tool
- Dependency
```R
tidyverse
Seurat
optparse # Needed if using command line Rscript workflow
```
### Method 1: Command line R script
- To use, first clone this repo, cd into the folder
```bash
cd script/

# Edit command below follow the format layout here
Rscript workflow_script.r \
--input "/diskmnt/Datasets/Spatial_Transcriptomics/seurat_obj/BRCA/Merged/BR_206B1_U2-5/merged_BR_206B1_U2-5.rds" \
--name 'HT206B1_U2to5' \ # Run name
--output '.' \ # Output Path
--sample_column 'orig.ident' \ # Meta data column contains Sample Name (e.g. Slice1,..., Slice2, ...)
--assay_name 'scrna_prediction' # Name of Assay contain cell type proportion


```
- result will be output to `/table` and `/image` of assigned output path


### Method 2: Load Object in R and use provided functions in script/functions
```R
# Make sure in right directory, change path below if needed
source('./functions/extract_images.r')
source('./functions/make_sample_info_table.r')

# 1. Extract Table contains Slice name (from Meta.data), Coordinate and Cell type (From Assay)
info_table = Make3DReconstructTable(
        obj = SEURAT_OBJECT,
        sample_column = SAMPLE_COLUMN, # Seurat Meta data column with name of each sample
        assay_name    = ASSAY_NAME, # Name of the Assay containing cell type proportions
        other_meta_columns = NULL # (Optional) other columns from the meta.data to extract
)
# remember to write this table out. (e.g. write_tsv(info_table, 'TABLE_OUT_PAHT'))

# 2. Extract and Save image
# - Note, this will save directly into the provided function.
# - Make sure to create the folder first use dir.create('IMAGE_OUT_PATH')

ExtractAllSeuratSTLowResImage(
        obj = SEURAT_OBJECT,
        path = 'IMAGE_OUT_PATH'
)

```

# 3. Manually Collect Requied Information
### A. Table
- Here's a short guideline if want collect table/image manually from spaceranger output
- The table contains main columns include
1. Slice Name/ID : 
- e.g. slice1, slice1 ,.., slice2, slice2, ...
- This can be manually create. 1 ID for each sample/slice
2. Coordinates : 
- coordinate of each spot **That Matches the Image Resolution To Use*
- Note : This `HAS to match the image you decide to use`, if use shunk lowres image, need to multiply to correct scaling ratio.
- For instance: if using `tissue_lowres_image.png` from '/spatial' folder in the 10x spaceranger output
  - Spaceranger >= 2.0 : `tissue_positions.csv`
  - Spaceranger <= 1.3  : `tissue_positions_list.csv`
- last 2 columns are the row and column in `fullres`
- to convert to correct ratio, refer to `scalefactors_json` file. find 
  - `tissue_lowres_scalef` for low res image
  - `tissue_hires_scalef` for high res image
3. Cell type ratio
-- This is usually attained using Deconvolution tools (RCTD/Spacexr, Cell2Location, etc), which contains a matrix with row = spot_id, columns cell types (Tumor, DC, T-cell, etc) and entry are their proportion/probability

Final table follows format as:
- row = Spots
- columns = Slice_ID, image_row (lowrew/highres), image_column (lowrew/highres), cell_type_1, cell_type_2, cell_type_3, ...
```
### Here's A quick example of the matrix
         spot_id       tissue_id  imagerow_lowres imagecol_lowres CellType_1  CellType_2  CellType_3
U2_AAACAACGAATAGTTC-1   U2        123.7359        45.07156      0.00000000  0.00000000   0.01559287
U2_AAACAAGTATCTCCCA-1   U2        445.0515       370.96662      0.05636844  0.00000000   0.00000000
U2_AAACAATCTACTAGCA-1   U2        224.7251        64.71504      0.00000000  0.00000000   0.02147359
U2_AAACACCAATAACTGC-1   U2        134.4615       429.11374      0.26981925  0.08527919   0.07642417
U2_AAACAGAGCGACTCCT-1   U2        415.4356       136.57043      0.00000000  0.76450798   0.17709148
```
- Repeat and combine tables from multiple spaceranger output
- Make sure tissue_id are assiged for each sample/slice

### B. Images
- choose either `tissue_hires_image` for high res or `tissue_lowres_image` for lowres in the `/spatial` folder



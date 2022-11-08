## Extract Slice info, Coordinate and Cell Type proportion from Assay obj

GetAllImagesCoordinate = function(obj, keep_cols = c(1,4,5)){
	map(Images(obj), function(slice){
		# scale fabor
		scale_lowres = obj@images[[slice]]@scale.factors$lowres
		# coord
		coord_df = obj@images[[slice]]@coordinates[,keep_cols, drop =F]
		coord_df$imagerow_lowres = coord_df$imagerow * scale_lowres
		coord_df$imagecol_lowres = coord_df$imagecol * scale_lowres
		return(coord_df)
	}) %>% bind_rows()
}


Make3DReconstructTable = function(obj, sample_column = 'orig.ident', 
assay_name=NULL, other_meta_columns){
	
	# Checks
	if(!sample_column %in% names(obj@meta.data)) 
		stop('sample_column not found in meta')
	if(!assay_name %in% Assays(obj)) 
		stop('assay_name not found in assays slot')	
	
	# Extract meta
	meta_df = data.frame(
		spot_id = rownames(obj@meta.data),
		tissue_id = obj@meta.data[[sample_column]],
		row.names = rownames(obj@meta.data)
	)
	
	# Other meta column
	if(!missing(other_meta_columns)){
		meta_df = cbind(meta_df, 
			obj@meta.data[rownames(meta_df), other_meta_columns, drop=F])
	}
	
	# Extract coordinate and add to dataframe
	coord_df = GetAllImagesCoordinate(obj)
	out_df   = cbind(meta_df, coord_df[rownames(meta_df), ,drop=F])

	# Add assay (Cell types percentage) if provided
	if(!is.null(assay_name)){
		cell_df = t(GetAssayData(obj@assays[[assay_name]]))
		cell_df = as.data.frame(cell_df)
		cell_df[['spot_id']] = rownames(cell_df)		
		# combine
		out_df  = left_join(out_df, cell_df, by = 'spot_id')
	}

	return(out_df)
}


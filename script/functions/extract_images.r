## Function to extract image from Seurat object
## Simon Mo 11/07/2022


ExtractSeuratSTLowResImage = function(
	obj, slice, suffix = 'lowres', path = '.'
){
	if(missing(slice)) slice = Images(obj)[[1]] # default use the first one
	mtx_img = obj@images[[slice]]@image
	col_img = rgb(mtx_img[,,1], mtx_img[,,2], mtx_img[,,3])
	dim(col_img) = dim(mtx_img[,,1])
	# Make image
	
	file_path = file.path(path, paste0('ST_',slice,'-',suffix,'.png'))
	message(paste0('File save to ',file_path))
	png(file_path)
	grid::grid.raster(col_img, interpolate=FALSE)
	dev.off()
}

ExtractAllSeuratSTLowResImage = function(
	obj, path = '.', use_possibly = T
){
	# possibly version of extract function
	possiblyExtrSTImg = possibly(
		.f = ExtractSeuratSTLowResImage, 
		otherwise = 'Error'
	)

	# Select function
	extrat_fun = if(use_possibly) possiblyExtrSTImg else ExtractSeuratSTLowResImage
	# Run and save images 
	walk(Images(obj), ~extrat_fun(obj, .x, path = path))
}

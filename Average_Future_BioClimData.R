library(terra)
library(dplyr)
library(tidyr)
library(sf)

### -------------------------------
### Template raster (reference grid)
### -------------------------------

current_ <- rast('Modern_BioClimData/wc2.1_2.5m_bio_01.tif')

# Ensure clean geometry
current_ <- trim(current_)

### -------------------------------
### Clip the geometry to North America
### -------------------------------

ext_ <- ext(-100, -40, 20, 80)

current_ <- crop(current_, ext_)

################################################################################
### Run for contemporary data
################################################################################

### -------------------------------
### Create list of modern tif files to iterate over
### -------------------------------

tif_files <- list.files(
  "Modern_BioClimData/",
  pattern = "\\.tif$",
  full.names = TRUE
)

# -------------------------------
# Process each raster and write out the cropped tif ascii file
# -------------------------------

output_dir <- "Modern_BioClimData/Cropped"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

for (f in tif_files) {
  
  r <- rast(f)
  
  # Optional: ensure alignment (only if needed)
  if (!compareGeom(r, current_, stopOnError = FALSE)) {
    r <- resample(r, current_, method = "bilinear")
  }
  
  # Crop and mask to match current_
  r_crop <- crop(r, current_)
  r_crop <- mask(r_crop, current_)
  
  # Clean invalid values
  r_crop[is.nan(r_crop)] <- NA
  r_crop[is.infinite(r_crop)] <- NA
  
  # Output filename (keeps original name)
  out_name <- file.path(
    output_dir,
    paste0(tools::file_path_sans_ext(basename(f)), ".asc")
  )
  
  writeRaster(
    r_crop,
    out_name,
    filetype = "AAIGrid",   # correct GDAL driver
    overwrite = TRUE,
    NAflag = -9999          # 🔑 REQUIRED for MaxEnt
  )
}

# -------------------------------
# Final check (optional)
# -------------------------------

# Check one file to confirm geometry
test_r <- rast(tif_files[1])
test_r <- crop(test_r, current_)
stopifnot(compareGeom(test_r, current_, stopOnError = FALSE))

################################################################################
### Run for ssp126
################################################################################

### -------------------------------
### Load, align, and store GCMs
### -------------------------------

future_files <- list.files(
  "Future_BioClimData_ssp126/",
  pattern = "\\.tif$",
  full.names = TRUE
)

gcm_future <- list()

for (i in seq_along(future_files)) {
  
  gcm <- rast(future_files[i])
  names(gcm) <- paste0("bio", 1:nlyr(gcm))
  
  # 🔑 CRITICAL: force exact alignment to current raster
  gcm_aligned <- resample(gcm, current_, method = "bilinear")
  
  # crop + mask to match EXACT extent
  gcm_aligned <- crop(gcm_aligned, current_)
  gcm_aligned <- mask(gcm_aligned, current_)
  
  gcm_future[[i]] <- gcm_aligned
}

### -------------------------------
### Average across GCMs (safe mean)
### -------------------------------

bio_names <- paste0("bio", 1:19)

gcm_future_mean <- rast(lapply(seq_along(bio_names), function(k){
  
  layers_k <- lapply(gcm_future, function(s) s[[k]])
  
  # 🔑 avoids NaN creation
  app(rast(layers_k), mean, na.rm = TRUE)
}))

names(gcm_future_mean) <- bio_names

gcm_future_mean

### -------------------------------
### Clean invalid values
### -------------------------------

# 🔑 Remove NaN explicitly (critical for MaxEnt)
gcm_future_mean[is.nan(gcm_future_mean)] <- NA

# Optional but good: remove infinite values
gcm_future_mean[is.infinite(gcm_future_mean)] <- NA

gcm_future_mean

### -------------------------------
### Final alignment check
### -------------------------------

# ensure PERFECT match
stopifnot(compareGeom(gcm_future_mean, current_, stopOnError = FALSE))

### -------------------------------
### Write MaxEnt-compatible ASCII
### -------------------------------

out_dir <- "Future_BioClimData_ssp126/Average_GCMs"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

for (i in 1:nlyr(gcm_future_mean)) {
  
  fname <- file.path(out_dir, paste0(names(gcm_future_mean)[i], ".asc"))
  
  writeRaster(
    gcm_future_mean[[i]],
    fname,
    filetype = "AAIGrid",   # correct GDAL driver
    overwrite = TRUE,
    NAflag = -9999          # 🔑 REQUIRED for MaxEnt
  )
}

################################################################################
### Now run for ssp585
################################################################################

### -------------------------------
### Load, align, and store GCMs
### -------------------------------

future_files <- list.files(
  "Future_BioClimData_ssp585/",
  pattern = "\\.tif$",
  full.names = TRUE
)

gcm_future <- list()

for (i in seq_along(future_files)) {
  
  gcm <- rast(future_files[i])
  names(gcm) <- paste0("bio", 1:nlyr(gcm))
  
  # 🔑 CRITICAL: force exact alignment to current raster
  gcm_aligned <- resample(gcm, current_, method = "bilinear")
  
  # crop + mask to match EXACT extent
  gcm_aligned <- crop(gcm_aligned, current_)
  gcm_aligned <- mask(gcm_aligned, current_)
  
  gcm_future[[i]] <- gcm_aligned
}

### -------------------------------
### Average across GCMs (safe mean)
### -------------------------------

bio_names <- paste0("bio", 1:19)

gcm_future_mean <- rast(lapply(seq_along(bio_names), function(k){
  
  layers_k <- lapply(gcm_future, function(s) s[[k]])
  
  # 🔑 avoids NaN creation
  app(rast(layers_k), mean, na.rm = TRUE)
}))

names(gcm_future_mean) <- bio_names

gcm_future_mean

### -------------------------------
### Clean invalid values
### -------------------------------

# 🔑 Remove NaN explicitly (critical for MaxEnt)
gcm_future_mean[is.nan(gcm_future_mean)] <- NA

# Optional but good: remove infinite values
gcm_future_mean[is.infinite(gcm_future_mean)] <- NA

gcm_future_mean

### -------------------------------
### Final alignment check
### -------------------------------

# ensure PERFECT match
stopifnot(compareGeom(gcm_future_mean, current_, stopOnError = FALSE))

### -------------------------------
### Write MaxEnt-compatible ASCII
### -------------------------------

out_dir <- "Future_BioClimData_ssp585/Average_GCMs"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

for (i in 1:nlyr(gcm_future_mean)) {
  
  fname <- file.path(out_dir, paste0(names(gcm_future_mean)[i], ".asc"))
  
  writeRaster(
    gcm_future_mean[[i]],
    fname,
    filetype = "AAIGrid",   # correct GDAL driver
    overwrite = TRUE,
    NAflag = -9999          # 🔑 REQUIRED for MaxEnt
  )
}


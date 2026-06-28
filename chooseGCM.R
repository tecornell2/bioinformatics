##############################################
############# set up choose GCM
install.packages("devtools")
devtools::install_github("luizesser/chooseGCM")
install.packages("raster")
install.packages("geodata")

library(chooseGCM)
library(raster)
library(geodata)

##############################################
############# bounds and inital data

# p.egregius geographic bounds
bounds <- extent(-88, -80, 24.5, 33)

# current climate data (reference/baseline)
current_climate <- worldclim_global(var = 'bio', res = 2.5, path = tempdir())
current_climate <- crop(current_climate, bounds)
# convert to raster stack
baseline <- stack(current_climate)

# plot to verify extent
plot(baseline[[1]], main = "BIO1 - SE USA")

# download GCM models manually
gcm_models <- c('ACCESS-CM2', 'BCC-CSM2-MR', 'CanESM5', 
                'CNRM-CM6-1', 'GFDL-ESM4', 'IPSL-CM6A-LR',
                'MIROC6', 'MRI-ESM2-0', 'UKESM1-0-LL')

gcm_data <- list()
successful_models <- c()

for(model in gcm_models) {
  cat("Downloading", model, "...\n")
  
  tryCatch({
    # Download future climate projections
    gcm <- cmip6_world(
      model = model,
      ssp = '585',           # SSP5-8.5 (high emissions scenario)
      time = '2061-2080',    # 2070s
      var = 'bioc',          # Bioclimatic variables
      res = 2.5,              # 2.5 arc-minutes resolution
      path = tempdir()
    )
    
    # Crop to your study area
    gcm_crop <- crop(gcm, bounds)
    
    # Convert to raster stack (chooseGCM expects this format)
    gcm_data[[model]] <- stack(gcm_crop)
    successful_models <- c(successful_models, model)
    
    cat("  Success!\n")
    
  }, error = function(e) {
    cat("  Error:", e$message, "\n")
  })
  
  # Small delay to avoid overwhelming the server
  Sys.sleep(2)
}

print(successful_models)

##############################################
############# gcm comparisons

### envelope similarity

cat("\n=== Calculating Envelope Similarity ===\n")

envelope_scores <- data.frame(
  model = character(),
  correlation = numeric(),
  rmse = numeric(),
  stringsAsFactors = FALSE
)

for(model in successful_models) {
  # Extract values
  base_vals <- getValues(baseline)
  gcm_vals <- getValues(gcm_data[[model]])
  
  # Remove NAs
  valid <- complete.cases(base_vals, gcm_vals)
  base_vals <- base_vals[valid, ]
  gcm_vals <- gcm_vals[valid, ]
  
  # Calculate correlation for each bioclimatic variable
  cors <- sapply(1:ncol(base_vals), function(i) {
    cor(base_vals[, i], gcm_vals[, i], use = "complete.obs")
  })
  
  # Calculate RMSE for each variable
  rmses <- sapply(1:ncol(base_vals), function(i) {
    sqrt(mean((base_vals[, i] - gcm_vals[, i])^2, na.rm = TRUE))
  })
  
  # Store results
  envelope_scores <- rbind(envelope_scores, data.frame(
    model = model,
    correlation = mean(cors, na.rm = TRUE),
    rmse = mean(rmses, na.rm = TRUE)
  ))
}

# Rank by correlation (higher is better)
envelope_scores <- envelope_scores[order(-envelope_scores$correlation), ]

cat("\nGCM Rankings by Envelope Similarity:\n")
print(envelope_scores)

cat("\n=== Calculating Future Spread/Uncertainty ===\n")

# Stack all GCMs for key variables
bio1_stack <- stack(lapply(gcm_data, function(x) x[[1]]))  # Annual mean temp
bio12_stack <- stack(lapply(gcm_data, function(x) x[[12]])) # Annual precip

# Calculate ensemble statistics
bio1_mean <- calc(bio1_stack, mean, na.rm = TRUE)
bio1_sd <- calc(bio1_stack, sd, na.rm = TRUE)
bio1_min <- calc(bio1_stack, min, na.rm = TRUE)
bio1_max <- calc(bio1_stack, max, na.rm = TRUE)

bio12_mean <- calc(bio12_stack, mean, na.rm = TRUE)
bio12_sd <- calc(bio12_stack, sd, na.rm = TRUE)

# Calculate coefficient of variation (uncertainty measure)
bio1_cv <- bio1_sd / bio1_mean * 100
bio12_cv <- bio12_sd / bio12_mean * 100

cat("Mean CV for BIO1 (temp):", round(mean(getValues(bio1_cv), na.rm = TRUE), 2), "%\n")
cat("Mean CV for BIO12 (precip):", round(mean(getValues(bio12_cv), na.rm = TRUE), 2), "%\n")

## 5c. Calculate projected changes from baseline
cat("\n=== Calculating Projected Changes ===\n")

change_summary <- data.frame(
  model = character(),
  bio1_change = numeric(),
  bio12_change = numeric(),
  stringsAsFactors = FALSE
)

for(model in successful_models) {
  # Calculate mean change across study area
  bio1_change_raster <- gcm_data[[model]][[1]] - baseline[[1]]
  bio12_change_raster <- gcm_data[[model]][[12]] - baseline[[12]]
  
  bio1_change <- mean(getValues(bio1_change_raster), na.rm = TRUE)
  bio12_change <- mean(getValues(bio12_change_raster), na.rm = TRUE)
  
  change_summary <- rbind(change_summary, data.frame(
    model = model,
    bio1_change = bio1_change / 10,  # Convert to °C
    bio12_change = bio12_change
  ))
}

cat("\nProjected Changes by Model:\n")
print(change_summary)


# Step 6: Select optimal GCMs
cat("\n=== Selecting Optimal GCMs ===\n")

# Combine envelope similarity with representation of uncertainty range
# Select top models by correlation
top_performers <- envelope_scores$model[1:5]

# Also identify models that span the range of projections
# Find warmest and coolest projections
warmest <- change_summary$model[which.max(change_summary$bio1_change)]
coolest <- change_summary$model[which.min(change_summary$bio1_change)]

# Combine selections
selected_models <- unique(c(top_performers[1:3], warmest, coolest))

cat("\nSelected GCMs for analysis:\n")
cat("  Top performers (envelope similarity):", paste(top_performers[1:3], collapse = ", "), "\n")
cat("  Warmest projection:", warmest, "\n")
cat("  Coolest projection:", coolest, "\n")
cat("\nFinal selection:", paste(selected_models, collapse = ", "), "\n")

# Step 7: Visualize comparisons
cat("\n=== Creating Visualizations ===\n")

# Plot 1: Current vs Future Ensemble
par(mfrow = c(2, 2))
plot(baseline[[1]], main = "Current Climate\n(BIO1: Ann. Mean Temp)")
plot(bio1_mean, main = "Future Ensemble Mean\n(2061-2080, SSP5-8.5)")
plot(bio1_sd, main = "Model Uncertainty\n(Standard Deviation)")
change_mean <- bio1_mean - baseline[[1]]
plot(change_mean, main = "Mean Projected Change\n(°C × 10)")

# Plot 2: Individual GCM projections for BIO1
n_models <- length(successful_models)
n_cols <- ceiling(sqrt(n_models))
n_rows <- ceiling(n_models / n_cols)

par(mfrow = c(n_rows, n_cols))
for(model in successful_models) {
  plot(gcm_data[[model]][[1]], main = paste(model, "\nBIO1"))
}

# Plot 3: Changes from baseline for each model
par(mfrow = c(n_rows, n_cols))
for(model in successful_models) {
  change <- gcm_data[[model]][[1]] - baseline[[1]]
  plot(change, main = paste(model, "\nChange (°C × 10)"))
}

# Plot 4: Model agreement
# What percentage of models project warming?
warming_stack <- stack(lapply(successful_models, function(model) {
  gcm_data[[model]][[1]] - baseline[[1]] > 0
}))
agreement <- calc(warming_stack, sum, na.rm = TRUE) / nlayers(warming_stack) * 100

par(mfrow = c(1, 1))
plot(agreement, main = "Model Agreement\n(% projecting warming)")

# Step 8: Export results
cat("\n=== Exporting Results ===\n")

# Save comparison tables
write.csv(envelope_scores, "gcm_envelope_similarity.csv", row.names = FALSE)
write.csv(change_summary, "gcm_projected_changes.csv", row.names = FALSE)

# Save selected models list
write.csv(data.frame(selected_models = selected_models), 
          "selected_gcms.csv", row.names = FALSE)

# Save ensemble rasters
writeRaster(bio1_mean, "ensemble_mean_bio1.tif", overwrite = TRUE)
writeRaster(bio1_sd, "ensemble_sd_bio1.tif", overwrite = TRUE)
writeRaster(change_mean, "ensemble_change_bio1.tif", overwrite = TRUE)

# Save selected GCM rasters
for(model in selected_models) {
  filename <- paste0("gcm_", gsub("-", "_", model), "_bio1.tif")
  writeRaster(gcm_data[[model]][[1]], filename, overwrite = TRUE)
}

cat("\nAnalysis complete! Results saved.\n")

# Step 9: Summary statistics
cat("\n=== SUMMARY ===\n")
cat("Study area extent:", as.character(bounds), "\n")
cat("Number of GCMs compared:", length(successful_models), "\n")
cat("Scenario: SSP5-8.5 (2061-2080)\n")
cat("Mean projected temperature change:", 
    round(mean(change_summary$bio1_change), 2), "°C\n")
cat("Range of projections:", 
    round(min(change_summary$bio1_change), 2), "to",
    round(max(change_summary$bio1_change), 2), "°C\n")
cat("Best performing GCM (envelope similarity):", envelope_scores$model[1], "\n")
cat("\nSelected models for further analysis:\n")
print(selected_models)
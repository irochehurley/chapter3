# Optimization code over parameters

# Pseudo code for calculating SSE for time-series
calculate_sse_time_series <- function(ram_ssb, model_ssb)
{
  
  # Temporarily remove spin up years
  start_year = which(rownames(model_ssb) == "1970")
  end_year = which(rownames(model_ssb) == "2017")
  
  # TEMPORARY
  model_ssb = model_ssb[start_year:end_year,]
  
  total_sse = 0
  
  # Loop through species
  for (species in 1:dim(model_ssb)[2])
  {
    not_na_years = !is.na(ram_ssb[, species])
    
    # Calculate sum of squares and add to the running total
    total_sse = total_sse + sum((ram_ssb[not_na_years, species] - model_ssb[not_na_years, species])^2)
  }
  print(total_sse)
  return(total_sse)
}

# Pseudo code for calculating SSE for time-series
calculate_sse_time_series_normalized <- function(ram_ssb, model_ssb)
{
  
  # Temporarily remove spin up years
  start_year = which(rownames(model_ssb) == "1970")
  end_year = which(rownames(model_ssb) == "2017")
  
  # TEMPORARY
  model_ssb = model_ssb[start_year:end_year,]
  
  # Normalize SSB time-series to assign equal weighting to all
  
  for (species in 1:dim(model_ssb)[2])
  {
    temp_val = mean(ram_ssb[,species], na.rm=T)
    ram_ssb[,species] <- ram_ssb[,species] / temp_val
    model_ssb[,species] <- model_ssb[,species] / temp_val
  }
  

  total_sse = 0
  
  # Loop through species
  for (species in 1:dim(model_ssb)[2])
  {
    not_na_years = !is.na(ram_ssb[, species])
    
    # Calculate sum of squares and add to the running total
    total_sse = total_sse + sum((ram_ssb[not_na_years, species] - model_ssb[not_na_years, species])^2)
    if (species == 3)
      {
      #print(mean(ram_ssb[,species], na.rm = T))
      #print(model_ssb[not_na_years,species])
      #print(ram_ssb[not_na_years, species])
      print(log(total_sse))
      }
  }
  return(total_sse)
}

# Run model just inputting rMax
runModel <- function(rMax, params, effort, t_max)
{
  # Put new vector back into species params
  params@species_params$R_max = rMax
  
  print(params@species_params$R_max)
  params <- setParams(params)
  
  # Run the model
  sim <- project(params, t_max = t_max, effort = effort)
  
  # Extract final biomasses
  biomasses_through_time = getSSB(sim)
  
  # Calculate SSE
  sse_final <- calculate_sse_time_series(obs_SSB, biomasses_through_time)
  print(sse_final)
  return(sse_final)
}

# Run model just inputting rMax
runModelNormalized <- function(rMax, params, effort, t_max)
{
  # Put new vector back into species params
  params@species_params$R_max = exp(rMax)
  
  params <- setParams(params)
  
  # Run the model
  sim <- project(params, t_max = t_max, effort = effort)
  
  # Extract final biomasses
  biomasses_through_time = getSSB(sim)
  
  # Calculate SSE
  sse_final <- calculate_sse_time_series_normalized(obs_SSB, biomasses_through_time)
  return(sse_final)
}

# Run model just inputting rMax
runModelNormalizedeRepro <- function(param_values, params, effort, t_max)
{
  # Put new vector back into species params
  params@species_params$R_max = exp(param_values[1:9])
  params@species_params$f0 = 1 / (1 + exp(-(param_values[10:18])))
  print(params@species_params$f0)
  params <- setParams(params)
  
  # Run the model
  sim <- project(params, t_max = t_max, effort = effort)
  
  # Extract final biomasses
  biomasses_through_time = getSSB(sim)
  
  # Calculate SSE
  sse_final <- calculate_sse_time_series_normalized(obs_SSB, biomasses_through_time)
  return(sse_final)
}

# Run model just inputting rMax
runModelNormalizedeReproKappa <- function(param_values, params, effort, t_max)
{
  # Put new vector back into species params
  params@species_params$R_max = exp(param_values[1:9])
  params@species_params$f0 = 1 / (1 + exp(-(param_values[10:18])))
  params@other_params$other$kappa_scaling = exp(param_values[19])
  print(params@species_params$f0)
  print(params@other_params$other$kappa_scaling)
  params <- setParams(params)
  
  # Run the model
  sim <- project(params, t_max = t_max, effort = effort)
  
  # Extract final biomasses
  biomasses_through_time = getSSB(sim)
  
  # Calculate SSE
  sse_final <- calculate_sse_time_series_normalized(obs_SSB, biomasses_through_time)
  print(sse_final)
  return(sse_final)
}


# # Run model just inputting kappa scaling
runModelKappaScale <- function(kappaScale, params, effort, t_max)
{
  # Put new vector back into species params
  other_params(params)$kappa_scaling = kappaScale

  params <- setParams(params)

  # Run the model
  sim <- project(params, t_max = t_max, effort = effort)

  # Extract final biomasses
  biomasses_through_time = getSSB(sim)

  # Calculate SSE
  sse_final <- calculate_sse_time_series_normalized(obs_SSB, biomasses_through_time)
  return(sse_final)
}



# Run model just inputting rMax
runModelNormalizedf0 <- function(param_values, params, effort, t_max)
{
  # Put new vector back into species params
  params@species_params$erepro = 1 / (1 + exp(-(param_values[1:9])))
  
  print(params@species_params$erepro)
  params <- setParams(params)
  
  # Run the model
  sim <- project(params, t_max = t_max, effort = effort)
  
  # Extract final biomasses
  biomasses_through_time = getSSB(sim)
  
  # Calculate SSE
  sse_final <- calculate_sse_time_series_normalized(obs_SSB, biomasses_through_time)
  return(sse_final)
}
# Run model just inputting rMax
runModelNormalizedeRepro <- function(param_values, params, effort, t_max)
{
  # Put new vector back into species params
  params@species_params$R_max = exp(param_values[1:9])
  params@species_params$f0 = 1 / (1 + exp(-(param_values[10:18])))
  
  print(params@species_params$f0)
  params <- setParams(params)
  
  # Run the model
  sim <- project(params, t_max = t_max, effort = effort)
  
  # Extract final biomasses
  biomasses_through_time = getSSB(sim)
  
  # Calculate SSE
  sse_final <- calculate_sse_time_series_normalized(obs_SSB, biomasses_through_time)
  print(sse_final)
  return(sse_final)
}

# # Run model just inputting kappa scaling
# runModelKappaScale <- function(kappaScale, params, effort, t_max)
# {
#   # Put new vector back into species params
#   other_params(params)$kappa_scaling = kappaScale
#   
#   print(params@other_params$other$kappa_scaling)
#   params <- setParams(params)
#   
#   # Run the model
#   sim <- project(params, t_max = t_max, effort = effort)
#   
#   # Extract final biomasses
#   biomasses_through_time = getBiomass(sim)
#   
#   # Calculate SSE
#   sse_final <- calculate_sse_time_series(obs_SSB, biomasses_through_time)
#   print(sse_final)
#   return(sse_final)
# }



# Run model just inputting rMax
runModelMultiOptim <- function(param_values, params, effort, t_max)
{
  # Put new vector back into species params
  params@species_params$R_max = exp(param_values[1:9])
  params@species_params$erepro = 1 / (1 + exp(-(param_values[10:18])))
  params@other_params$other$kappa_scaling = exp(param_values[19])
  
  params <- setParams(params)
  
  # Run the model
  sim <- project(params, t_max = t_max, effort = effort)
  
  # Extract final biomasses
  biomasses_through_time = getSSB(sim)
  
  # Calculate SSE
  sse_final <- calculate_sse_time_series(obs_SSB, biomasses_through_time)
  return(sse_final)
}


# Run model just inputting rMax
runModelMultiOptimAll <- function(param_values, params, effort, t_max)
{
  # Put new vector back into species params
  params@species_params$R_max = exp(param_values[1:9])
  params@species_params$erepro = 1 / (1 + exp(-(param_values[10:18])))
  params@species_params$X.beta = exp(param_values[19:27])
  params@species_params$sigma = exp(param_values[28:36])
  params@other_params$other$kappa_scaling = exp(param_values[37])
  
  params <- setParams(params)
  
  # Run the model
  sim <- project(params, t_max = t_max, effort = effort)
  
  # Extract final biomasses
  biomasses_through_time = getSSB(sim)
  
  # Calculate SSE
  sse_final <- calculate_sse_time_series(obs_SSB, biomasses_through_time)
  return(sse_final)
}

# ptm <- proc.time()
# aa = optim(new_Rmax, runModel2)
# proc.time() - ptm
# 
# cl <- makeCluster(detectCores()-1)
# setDefaultCluster(cl = cl)
# clusterExport(cl, c("runModel", "calculate_sse_time_series", "params", "relative_effort", "ram_ssb"))
# 
# ptm <- proc.time()
# aa = optimParallel(par = new_Rmax, fn = runModel, method = "L-BFGS-B", lower = rep(0,9), upper = rep(1e+20, 9))
# proc.time() - ptm
# stopCluster(cl)
# -------------------------------------------------------------------------------------
# this function performs missing values imputation based on missForest algorithm
# -------------------------------------------------------------------------------------

# arguments ___________________________________________________________________________
#           : dataSet.mvs       - expression matrix with MVs (either peptides or proteins)

# output ______________________________________________________________________________
#           : dataSet.imputed      - dataset containing complete abundances
require(missForest)
impute.wrapper.RF = function(dataSet.mvs, ...){
  
  resultmissForest = missForest(mwk, verbose = TRUE, ...)
  dataSet.imputed = resultmissForest$ximp
  
  return(dataSet.imputed)
  
}

##### File Description ######################################################################################################
#   This file is to create the new RunAanlysis that calculates based on a beta-binomial
#   Inputs:
#     cAnalysis - The class( cAnalysis ) determines the specific version of RunAnalysis that is called. It contains
#                 the details about the analysis such as the priors, MAV, TV, decision cut-off boundaries.
#     lDataAna  - The data that is used int he analysis.  Typically contains vISA (the ISA for the patient),
#                 vTrt (treatment for each patient), vOut (the outcome for each patient)
#     nISAAnalysisIndx - index of the analysis used for changing boundaries)
#     bIsFinaISAAnalysis - TRUE or FALSE, often we change the value of the cut-off at the final analysis for an ISA
#     cRandomizer - The randomizer, mainly used for cases with covariates
#
#############################################################################################################################.
RunAnalysis.TTestOneSided <- function( cAnalysis, lDataAna,  nISAAnalysisIndx, bIsFinalISAAnalysis, cRandomizer )
{
    #print( "RunAnalysis.TTestOneSided")
    # if( bDebug2 == TRUE )
    #     browser()
    lTTest  <- t.test(lDataAna$vOut ~ as.factor(lDataAna$vTrt), alternative = c("less"),mu = 0, var.equal = TRUE)
        
    dPValue <- lTTest["p.value"][[1]]
   
    #print( paste( "Pvalue ", dPValue))
    
    # The lRet must be a list list( nGo = nGo, nNoGo = nNoGo, nPause = nPause) 
    
    dCutoffFut <- cAnalysis$vPValueCutoffForFutility[ nISAAnalysisIndx ]
    dCutoffSuc <- cAnalysis$vPValueCutoffForSuccess[ nISAAnalysisIndx ]
    
    lRet <- list( nGo = 0, nNoGo = 0, nPause = 1 )
    
    if( dPValue <= dCutoffSuc)
    {
        # Success
        lRet <- list( nGo = 1, nNoGo = 0, nPause = 0 )
    }
    else if( dPValue > dCutoffFut )
    {
        # Futility
        lRet <- list( nGo = 0, nNoGo = 1, nPause = 0 )
    }

    
    
    lRet$cRandomizer <- cRandomizer
    
    return( lRet )
    


}








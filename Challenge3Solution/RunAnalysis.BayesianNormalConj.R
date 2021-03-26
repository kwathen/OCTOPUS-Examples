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
#     the cAnalysis should have the elements vPriorMean, vPriorSD 
#############################################################################################################################.
RunAnalysis.BayesianNormalConj <- function( cAnalysis, lDataAna,  nISAAnalysisIndx, bIsFinalISAAnalysis, cRandomizer )
{
    #print( "RunAnalysis.TTestOneSided")
    #if( bDebug2 == TRUE )
    #     browser()
    
    
    # The lRet must be a list list( nGo = nGo, nNoGo = nNoGo, nPause = nPause) 
   
    
    nQtyPostSamples <- 100000
    
    mPostSamp <- matrix( NA, nrow = nQtyPostSamples, ncol = 2 )
     # Loop over the two arms in the ISA
    for( iArm in 1:2 )
    {
        nTrt       <- cAnalysis$vTrtLab[ iArm ]
        
        # Get the prior parameters
        dPriorMean <- cAnalysis$vPriorMeans[ iArm ]
        dPriorSD   <- cAnalysis$vPriorSD[ iArm ]
        
        #Compute the observed data statistics
        vObsX      <- lDataAna$vOut[ lDataAna$vTrt == nTrt ]
        nN         <- length( vObsX )
        dObsMean   <- mean( vObsX )
        dObsSD     <- sqrt( var( vObsX ) )
        
        
        #Compute Post params and sample
        lPost      <- NormalNormalPosterior( dObsMean, dObsSD, nN, dPriorMean, dPriorSD )
        
        dPostMean  <- lPost$postmean
        dPostSigma <- lPost$postsigma
        
        mPostSamp[ , iArm ] <- rnorm( nQtyPostSamples, dPostMean, dPostSigma )
        
    }
    
    # Compute Pr( mean_E > mean_C | Data )
    dPrExpGrtCont <- mean( mPostSamp[ , 2] > mPostSamp[ , 1] )
    
    
    
    dPostProbCutoffForFutility   <- cAnalysis$vPostProbCutoffForFutility[ nISAAnalysisIndx ]
    dPostProbCutoffForSuccess    <- cAnalysis$vPostProbCutoffForSuccess[ nISAAnalysisIndx ]
    
    lRet <- list( nGo = 0, nNoGo = 0, nPause = 1 )
    
    if( dPrExpGrtCont >  dPostProbCutoffForSuccess )   # The trial was a success
    {
        # Success
        lRet <- list( nGo = 1, nNoGo = 0, nPause = 0 )
    }
    else if( dPrExpGrtCont  < dPostProbCutoffForFutility ) 
    {
        # Futility
        lRet <- list( nGo = 0, nNoGo = 1, nPause = 0 )
    }

    
    
    lRet$cRandomizer <- cRandomizer
    
    return( lRet )
    


}








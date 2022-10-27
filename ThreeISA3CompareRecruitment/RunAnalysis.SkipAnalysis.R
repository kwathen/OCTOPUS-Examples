##### File Description ######################################################################################################
#   This file is to create the new RunAanlysis that DOES NOTHING.   This is only for the ability to compare recruitment
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
RunAnalysis.SkipAnalysis <- function( cAnalysis, lDataAna,  nISAAnalysisIndx, bIsFinalISAAnalysis, cRandomizer )
{

    lCutoff    <- GetBayesianCutoffs( cAnalysis, nISAAnalysisIndx, bIsFinalISAAnalysis )


    lCalcs     <- list( dPrGrtMAV      = 0.5,
                        dPUpperCutoff  = lCutoff$dPUpperCutoff,
                        dPLowerCutoff  = lCutoff$dPLowerCutoff )

    lRet       <- MakeDecisionBasedOnPostProb(cAnalysis, lCalcs )

    lRet$cRandomizer <- cRandomizer  # Needed because the main code will pull the randomizer off just in-case this function were to close a covariate group
    return( lRet )


}








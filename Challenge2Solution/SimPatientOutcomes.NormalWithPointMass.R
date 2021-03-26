
################################################################################################### #
#   Description - This file will add a new patient outcome where patient outcomes are binary
#
#   TODO: The cSimOutcomes should contain the elements
#         vTrueMean - vector of means for (Control, Experimental)
#         vProbPatAtPointMass - The probability a patient is at the point mass in (Control, Experimental)
#                                For example, c( 0.3, 0.1 ) would indicate that 30% of patients on control are at point mass and 10% of 
#                                patients on experimental are on point mass
#          vPointMassValue - Vector of the values for the point mass for (Control, Experimental)
################################################################################################### #

SimPatientOutcomes.NormalWithPointMass <- function(  cSimOutcomes, cISADesign, dfPatCovISA )
{
    # print( "SimPatientOutcomes.NormalWithPointMass")
    # In order to debug and stop here create a variable bDebug2 and set to TRUE
    #if( bDebug2 == TRUE )
    #     browser()
    
    #print( "Executing SimPatientOutcomes.NormalWithPointMass ...")
    if( !is.null(  dfPatCovISA  ) )
        stop( "SimPatientOutcomes.NormalWithPointMass is not designed to incorporate patient covariates and  dfPatCovISA  is not NULL.")


    mOutcome        <- NULL

    vMeans          <- cSimOutcomes$vTrueMean
    vQtyPats        <- cISADesign$vQtyPats
    dStdDev         <- cSimOutcomes$dTrueStdDev
    
    vProbPatAtPointMass <- cSimOutcomes$vProbPatAtPointMass
    vPointMassValue     <- cSimOutcomes$vPointMassValue

    vPatTrt         <- rep( cISADesign$vTrtLab, vQtyPats )
    iArm            <- 1
    for( iArm in 1:length( vQtyPats ) )
    {
        # First, simuate the number of patients at point mass
        nQtyPatsAtPointMass <- rbinom( 1, vQtyPats[ iArm ], vProbPatAtPointMass[ iArm ] )
        
        # Second simulate vQtyPats[ iArm ] - nQtyPatsAtPointMass patients from the N()
        vPatientOutcomes    <- rnorm( vQtyPats[ iArm ] - nQtyPatsAtPointMass, vMeans[ iArm ], dStdDev )
        
        # Last set nQtyPatsAtPointMass at the point mass value. 
        vPatientOutcomes    <- c( vPatientOutcomes, rep( vPointMassValue[ iArm ], nQtyPatsAtPointMass) )
        
        #print( paste( "iArm ", iArm, " Prob Resp ", vProbResponse[ iArm ], " # Pats ", vQtyPats[ iArm ], " % resp ", sum(vPatientOutcomes)/vQtyPats[iArm]))
        mOutcome         <- rbind( mOutcome, matrix( vPatientOutcomes , ncol = 1) )
    }


    lSimDataRet <- structure( list( mSimOut1 = mOutcome, vObsTime1 = cISADesign$cISAAnalysis$vAnalysis[[1]]$vObsTime ), class= class(cSimOutcomes) )


    lSimDataRet$nQtyOut  <- 1
    lSimDataRet$vPatTrt  <- vPatTrt

    return( lSimDataRet )

}



################################################################################################### #
#   Description - This file will add a new patient outcome where patient outcomes are binary
#
#   TODO: Test this function.
################################################################################################### #

SimPatientOutcomes.Normal <- function(  cSimOutcomes, cISADesign, dfPatCovISA )
{
    # print( "SimPatientOutcomes.Normal")
    # if( bDebug2 == TRUE )
    #     browser()
    
    #print( "Executing SimPatientOutcomes.Normal ...")
    if( !is.null(  dfPatCovISA  ) )
        stop( "SimPatientOutcomes.Binary is not designed to incorporate patient covariates and  dfPatCovISA  is not NULL.")


    mOutcome        <- NULL

    vMeans          <- cSimOutcomes$vTrueMean
    vQtyPats        <- cISADesign$vQtyPats
    dStdDev         <- cSimOutcomes$dTrueStdDev

    vPatTrt         <- rep( cISADesign$vTrtLab, vQtyPats )
    iArm            <- 1
    for( iArm in 1:length( vQtyPats ) )
    {

        vPatientOutcomes <- rnorm( vQtyPats[ iArm ], vMeans[ iArm ], dStdDev )
        #print( paste( "iArm ", iArm, " Prob Resp ", vProbResponse[ iArm ], " # Pats ", vQtyPats[ iArm ], " % resp ", sum(vPatientOutcomes)/vQtyPats[iArm]))
        mOutcome         <- rbind( mOutcome, matrix( vPatientOutcomes , ncol = 1) )
    }


    lSimDataRet <- structure( list( mSimOut1 = mOutcome, vObsTime1 = cISADesign$cISAAnalysis$vAnalysis[[1]]$vObsTime ), class= class(cSimOutcomes) )


    lSimDataRet$nQtyOut  <- 1#length( cSimOutcomes )
    lSimDataRet$vPatTrt  <- vPatTrt

    return( lSimDataRet )

}


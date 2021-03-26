##### File Description ######################################################################################################
#  Set up the simulation object.
#  vISAStarTime - A vector of start time, in months, for each ISA to begin enrolment.  By default the first ISA should
#                 have a start time of 0.  If the argument is not provided, all ISAs start at time = 0
#
#   Items below that need to be check.
#       Recruitment times - the recruitment times for each patient are simulated by a Poisson process but you should
#       specify the number of patient accrued each month.  Which can be done directly or by computing as the product of expected
#       number of patients per month per site and the number of sites enroll each month, see below.
#
#       Add additional scenarios that are for the particular application.
#############################################################################################################################.

SetupSimulations <- function( cTrialDesign, nQtyReps,
                              strSimPatientOutcomeClass,
                              vISAStartTimes = NULL,
                              nDesign = 1, ...)
{

    vObsTime1    <- cTrialDesign$cISADesigns$cISA1$cISAAnalysis$vAnalysis[[1]]$vObsTime

    nQtyCol <- length( vObsTime1 )


    #Set up the first Scenario, starting with non-ISA specific information

    nQtyISAs        <- length( cTrialDesign$cISADesigns)
    if( is.null( vISAStartTimes ) )
        vISAStartTimes <- rep( 0, nQtyISAs )

    #############################################.
    # Set up ISA cISADesign element          ####
    # For each ISA you must specify a start time or provide an interval to simulate the start time for.
    # The first ISA is assumed to start at time 0.  The options are
    # 1. cISAStart   <- structure( list( dParam1 = dStartTime ), class="SetTime" )  # Where dStartTime is the time, in months from trial start that an ISA opens
    # 2. cISAStart   <- structure( list( dParam1=dTime1, dParam2=dTime2), class="Uniform" ) #Simulate uniform time between dTime1 and dTime2
    #    See ?SimulateISAStartTime.SetTime or ?SimulateISAStartTime.Uniform
    #############################################.

    cISADesigns <- list()
    #ReadMe - The example loop below created a list of ISA simulation objects.  Update as needed for particular use case.
    # The goal of the loop is to fill cISADesigns with the info for each ISA.  The elements of cISADesigns should be
    # cISA1, cISA2,...
    
    # This loop is setting up the structure for the cSimOutcome so make sure to add the desired paramters here for simulation and also below
    for( iISA in 1:nQtyISAs )
    {
        cISAStart    <- structure( list( dParam1 = vISAStartTimes[ iISA ]), class="SetTime" )
        vObsTime1    <- cTrialDesign$cISADesigns$cISA1$cISAAnalysis$vAnalysis[[1]]$vObsTime

        #Set up the patient simulator - in this example it assume treatment and control both have a response rate of 0.2.  More scenarios are added below
        cSimOutcome  <- structure(list( vTrueMean = c(0.0, 0.0 ), 
                                        dTrueStdDev = 1,
                                        ...), class=c( strSimPatientOutcomeClass ))
        cISAInfo     <- structure( list(cSimOutcomes = cSimOutcome,  cSimISAStart = cISAStart ) )

        cISADesigns[[ paste( "cISA", iISA, sep="" ) ]] <- cISAInfo


    }



    #####################################################.
    # Set up the non-ISA specific info and scenarios ####
    #####################################################.

    nMaxQtyPats <- 0
    i<-1
    if( is.null( cTrialDesign$nMaxQtyPats) )
    {
        for( i in 1:nQtyISAs )
        {
            nMaxQtyPats     <- nMaxQtyPats + sum(  cTrialDesign$cISADesigns[[i]]$vQtyPats)

        }
    }
    else
    {
        nMaxQtyPats <- cTrialDesign$nMaxQtyPats
    }


    ##########################################################################################.
    # Recruitment rates, how many patient are expected to enroll each month in the trial ####
    ##########################################################################################.
    # The information provided is in terms of the number of patients per month per site and
    #
    vPatsPerMonthPerSite1   <- c(0.1, 0.3, 0.45, 0.5, 0.5, 0.5 )
    vQtyOfSitesPlat         <- c(3,     8,  15,   35,  50, 70)
    vQtyOfPatsPerMonth1     <- vPatsPerMonthPerSite1 * vQtyOfSitesPlat

    ap                      <- NewAccrualProcess( vQtyPatsPerMonth = vQtyOfPatsPerMonth1, nMaxQtyPatients = nMaxQtyPats )
    #################################################################################.

    # Example of creating a scenario utilizing cISADesigns created above
    cScen1 <- structure(list(cAcc         = ap,
                             nDesign      = nDesign,
                             Scen         = 1,
                             nQtyReps     = nQtyReps,
                             nPrintDetail = 0,
                             cISADesigns  = cISADesigns))



    lScen <- list( cScen1 = cScen1 )
    vName <- c( "cScen1" )

    # Example of updating and adding another scenario, null case was added above

    # For this exercise you did not need the probability of response but rather the true mean
    vTrueMeanTrt <- c( 0.3 )  #This vector is used in the loop below
    vTrueStdDev  <- c(  1   )
    for( iScen in 1:length( vTrueMeanTrt ) )   # Loop over the scenarios in vTrueMeanTrt
    {
        cScen          <- cScen1

        
        # For the example SimPatientOutcomes.XXX there the vector
        for( iISA in 1:nQtyISAs )
        {
            cScen$cISADesigns[[ paste( "cISA", iISA, sep="") ]]$cSimOutcomes$vTrueMean <- c( 0, vTrueMeanTrt[ iScen ] )
            cScen$cISADesigns[[ paste( "cISA", iISA, sep="") ]]$cSimOutcomes$dTrueStdDev <- vTrueStdDev[ iScen ]
        }

        #Note: Using iScen + 1 because the null was added as scenario 1

        iScenTmp             <- iScen + 1
        cScen$Scen           <- iScenTmp
        lScen[[ iScenTmp]]   <- cScen
        vName                <- c( vName, paste( "cScen", iScenTmp, sep="" )  )
    }
    names( lScen )     <- vName


    # It would be useful to run more scenarios where the effectiveness of the treatment is not
    # the same for ISAs
    cSimulation <- structure( list( lScenarios    = lScen,
                                    cTrialDesign  = cTrialDesign
    ))

    lSimulation <- list( SimDesigns = list(cSimulation))

    return( lSimulation )
}

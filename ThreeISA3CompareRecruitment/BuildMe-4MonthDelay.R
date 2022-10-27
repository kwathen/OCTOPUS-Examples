

# This file was created as part of the call to OCTOPUS::CreateProject()

#### Description ################################################################################################
#   This project was created utilizing the OCTOPUS package located at https://kwathen.github.io/OCTOPUS/ .
#   The intent of this example is to compare various recruitment approaches rather then the usual performance of a design. 
#  
#   Overview of Simulation Process
#   1.  The following code builds the required objects to simulate a platform trial with OCTOPUS.  
#   2.  Run the simulations (see below)
#   3.  The outputs are written to the folders out, ISAOut1, ISAout2, ISAOut3 
#   4.  Please see BuildSimulationResults.R to create plots. 
################################################################################################### #

# It is a good practice to clear your environment before building your simulation/design object then
# then clean it again before you run simulations with only the minimum variables need to avoid potential
# misuse of variables
remove( list=ls() )

# ReadMe - If needed, install the latest copy of OCTOPUS using the remotes package
#remotes::install_github( "kwathen/OCTOPUS")

library( "OCTOPUS" )

library( "parallel" )            # This is required to utilize more cores on the machine, if this is not included then only 1 core is utilized
source( "Functions.R")           # Contains a function to delete any previous results
CleanSimulationDirectories( )    # only call when you want to erase previous results

gdConvWeeksToMonths <- 12/52     # Global variable to convert weeks to months, the g is for global as it may be used
                                 # in functions


######################################################################################################################## .
# Source in helper functions  ####
######################################################################################################################## .
source( "TrialDesign.R")
source( "SimulationDesign.R")
source( "TrialDesignFunctions.R")

######################################################################################################################## .
# Build the design elements ####
# In this design we want to look at 3 ISAs, each ISA will have 60 patients on control and 120 on treatment.  
# This patient balance could allow for borrowing of control patients such that there would be 120 on control and 120 on 
# treatment for each ISA comparison.  
# We assume that all the ISA start at the beginning of the platform. 
######################################################################################################################## .
dQtyMonthsFU       <- 6

# The number of patients on control and treatment in each ISA.   Each row is an ISA and column 1 is number of patients on control
# column 2 is the number on treatment.
mQtyPatientsPerArm <- matrix( c( 60,120,
                                 60,120,
                                 60,120 ), nrow=3, ncol = 2, byrow =TRUE )

# The start times, in months, are 0, 4 and 8
vISAStartTimes     <- c(  0, 4, 8 )  

nQtyCores          <- max( detectCores() - 1, 1 )  # When the simulations are executed we only want to utilize the number of cores on the machine - 1.


# The number of replications to simulate each scenario.  In this example, a scenario is defined by the number of sites enrolling in the platform
nQtyReps           <- ceiling( 1000/nQtyCores )# How many replications to simulate each scenario, dividing by the number of cores to get 1000 that we want

vMaxNumberOfSites  <- seq( 30, 100, 10)   # The number of sites enrolling in the platform, this will create the scenarios 


# Call OCTOPUS functions to create the required objects, the SkipAnalysis is used to avoid spending compute time for analysis since this example
# is supposed to show operating characteristics. 
cTrialDesign <- SetupTrialDesign( strAnalysisModel   = "SkipAnalysis",
                                  strBorrowing       = "AllControls",
                                  mPatientsPerArm    = mQtyPatientsPerArm,
                                  dQtyMonthsFU       = dQtyMonthsFU )

cSimulation  <- SetupSimulations( cTrialDesign,
                                  nQtyReps                  = nQtyReps,
                                  strSimPatientOutcomeClass = "Binary",
                                  vISAStartTimes            = vISAStartTimes,
                                  vMaxNumberOfSites         = vMaxNumberOfSites,
                                  nDesign                   = 1)

#Save the design file because we will need it in the RMarkdown file for processing simulation results
save( cTrialDesign, file="cTrialDesign.RData" )
 


lTrialDesigns <- list( cTrialDesign1 = cTrialDesign )
save( lTrialDesigns, file="lTrialDesigns.RData")

# End of design options ####

#  As a general best practice, it is good to remove all objects in the global environment just to make sure they are not inadvertently used.
#  The only object that is needed is the cSimulation object and gDebug, gnPrintDetail (defined below).
rm( list=(ls()[ls()!="cSimulation" ]))



# Declare global variable (prefix with g to make it clear)
gDebug        <- FALSE   # Can be useful to set if( gDebug ) statements when developing new functions
gnPrintDetail <- 1       # Higher number cause more printing to be done during the simulation.  A value of 0 prints almost nothing and should be used when running
                         # large scale simulations.

# Source the files for simulation ####
# Files specific for this project that were added and are not available in OCTOPUS.
# These files create new generic functions that are utilized during the simulation.
source( 'RunAnalysis.SkipAnalysis.R' )
source( 'SimPatientOutcomes.Binary.R' )  # This will add the new outcome
source( "BinaryFunctions.R" )

# The next line will execute the simulations WITHOUT using multiple cores.   
#RunSimulation( cSimulation )




#################################################################################################### .
# Setup of parallel processing                                                                  ####
#################################################################################################### .

library( "foreach")
library( "parallel" )
library( "doParallel" )
library( "foreach")
library( "utils" )
library( "iterators" )
library( "doSNOW" )
library( "snow" )
source( "RunParallelSimulations.R" ) # This file has a version of simulations that utilize more cores

# Use 1 less than the number of cores available
nQtyCores  <- max( detectCores() - 1, 1 )

# The nStartIndex and nEndIndex are used to index the simulations and hence the output files see the RunParallelSimulations.R file
# for more details
RunParallelSimulations( nStartIndex = 1, nEndIndex = nQtyCores,  nQtyCores, cSimulation )


# Next Steps: Please see the BuildSimulationResults.R file to create graphs ####
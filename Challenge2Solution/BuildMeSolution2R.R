# This file was created as part of the call to OCTOPUS::CreateProject()


#### Description ################################################################################################
#   This project was created utilizing the OCTOPUS package located at https://kwathen.github.io/OCTOPUS/ .
#   There are several ReadMe comments in the document to help understand the next steps.
#   When this project was created from the template if an option was not supplied then there
#   may be variables with the prefix TEMP_ which will need to be updated.
################################################################################################### #

# It is a good practice to clear your environment before building your simulation/design object then
# then clean it again before you run simulations with only the minimum variables need to avoid potential
# misuse of variables
# remove( list=ls() )

# ReadMe - If needed, install the latest copy of OCTOPUS using the remotes package
#remotes::install_github( "kwathen/OCTOPUS")

library( "OCTOPUS" )

# ReadMe - Useful statements for running on a grid such as linux based grid
if (interactive() || Sys.getenv("SGE_TASK_ID") == "") {
  #The SGE_TASK_ID is used if you are running on a linux based grid
    Sys.setenv(SGE_TASK_ID=1)
}

source( "Functions.R")           # Contains a function to delete any previous results
CleanSimulationDirectories( )   # only call when you want to erase previous results

gdConvWeeksToMonths <- 12/52     # Global variable to convert weeks to months, the g is for global as it may be used
                                 # in functions



source( "TrialDesign.R")
source( "SimulationDesign.R")
source( "TrialDesignFunctions.R")

dQtyMonthsFU       <- 1

#################################################################################################### .
# Simulation Case 0 - Patients are simulated from a Normal, no point mass simulation ####
#################################################################################################### .

# Design option 1 ####
# This design option with have 2 ISAs  and each ISA will have 1 interim analysis and a final analysis
# At IA 1 if p-value > 0.9 --> futility, p-value < 0.048 --> Early success (Go) otherwise continue
# at IA 2 if p-value > 0.048 -->futility, p-value < 0.048 --> success (Go) 

# UPDATE: Adding a 2nd row for the mQtyPatientsPerArm will add another ISA with  192 per arm
mQtyPatientsPerArm <- matrix( c( 192, 192,
                                 192, 192 ), nrow=2, ncol = 2 )
mMinQtyPats       <- cbind( floor(apply( mQtyPatientsPerArm , 1, sum )/2),  apply( mQtyPatientsPerArm , 1, sum ) )
vMinFUTime        <- rep( dQtyMonthsFU, ncol( mMinQtyPats) )
dQtyMonthsBtwIA   <- 0

# UPDATE: Because you have 2 ISAs you must have 2 ISA starts time, this version assumes ISA1 starts at time 0 and
# ISA 2 starts at 4 months after the start of the trial.  If you wanted to simulate a random start time for ISA 2 see 
# SimulationDesign.R line 31

vISAStartTimes     <- c(  0, 4 )
nQtyReps           <- 1 # How many replications to simulate each scenario
vPValueCutoffForFutility <- c( 0.9, 0.048 )
vPValueCutoffForSuccess  <- c( 0.048, 0.048 )



cTrialDesign <- SetupTrialDesign( strAnalysisModel   = "TTestOneSided",
                                  strBorrowing       = "AllControls",
                                  mPatientsPerArm    = mQtyPatientsPerArm,
                                  mMinQtyPat         = mMinQtyPats,
                                  vMinFUTime         = vMinFUTime,
                                  dQtyMonthsFU       = dQtyMonthsFU,
                                  dQtyMonthsBtwIA    = dQtyMonthsBtwIA,
                                  vPValueCutoffForFutility = vPValueCutoffForFutility,
                                  vPValueCutoffForSuccess  = vPValueCutoffForSuccess)

# Update - For this challenge the patient simulator is the normal with point mass so need to update the class in the simulation object

cSimulation  <- SetupSimulations( cTrialDesign,
                                  nQtyReps                  = nQtyReps,
                                  strSimPatientOutcomeClass = "Normal",
                                  vISAStartTimes            = vISAStartTimes,
                                  nDesign                   = 1 )

#Save the design file because we will need it in the RMarkdown file for processing simulation results
save( cTrialDesign, file="cTrialDesign.RData" )

####################################################################################################### .

# Design Option 2 ####
# This design option with have 2 ISAs  and each ISA will have 2 interim analysis and a final analysis
# At IA 1 if p-value > 0.9 --> futility, p-value < 0.001 --> Early success (Go) otherwise continue
# at IA 2 if p-value > 0.048 -->futility, p-value < 0.016 --> Early success (Go) otherwise continue
# at final if p-value > 0.045 -->Futility, Go otherwise
# 
# UPDATE: Adding a 2nd row for the mQtyPatientsPerArm will add another ISA with  192 per arm
mQtyPatientsPerArm <- matrix( c( 293, 293,
                                 293, 293), nrow=2, ncol = 2 )
mMinQtyPats       <- cbind( floor(apply( mQtyPatientsPerArm , 1, sum )/3),floor(2*apply( mQtyPatientsPerArm , 1, sum )/3),  apply( mQtyPatientsPerArm , 1, sum ) )
vMinFUTime        <- rep( dQtyMonthsFU, ncol( mMinQtyPats) )
dQtyMonthsBtwIA   <- 0

# UPDATE: Because you have 2 ISAs you must have 2 ISA starts time, this version assumes ISA1 starts at time 0 and
# ISA 2 starts at 4 months after the start of the trial.  If you wanted to simulate a random start time for ISA 2 see 
# SimulationDesign.R line 31

vISAStartTimes     <- c(  0, 4 )

vPValueCutoffForFutility <- c( 0.9,   0.048, 0.045 )
vPValueCutoffForSuccess  <- c( 0.001, 0.016, 0.045 )

cTrialDesign2 <- SetupTrialDesign( strAnalysisModel   = "TTestOneSided",
                                   strBorrowing       = "AllControls",
                                   mPatientsPerArm    = mQtyPatientsPerArm,
                                   mMinQtyPat         = mMinQtyPats,
                                   vMinFUTime         = vMinFUTime,
                                   dQtyMonthsBtwIA    = dQtyMonthsBtwIA,
                                   vPValueCutoffForFutility = vPValueCutoffForFutility,
                                   vPValueCutoffForSuccess = vPValueCutoffForSuccess)

cSimulation2 <- SetupSimulations( cTrialDesign2,
                                  nQtyReps                  = nQtyReps,
                                  strSimPatientOutcomeClass = "Normal",
                                  vISAStartTimes            = vISAStartTimes,
                                  nDesign                   = 2)

cSimulation$SimDesigns[[2]] <- cSimulation2$SimDesigns[[1]]

save( cTrialDesign2, file = "cTrialDesign2.RData" )




#################################################################################################### .
# Simulation Case 1 - Patients are simulated from a Normal with a point mass.
# Control: 70% of patients come from a N( 0, 1) and 30% have an outcome value of 0.  
#          Experimental: 90% of patients come from a normal( 0.3, 1) and 10% have  an outcome of 0.  ####
#################################################################################################### .



# Design option 3 - SAME AS DESIGN 1 JUST CHANGING THE SIMULATION MODEL SO WE CAN COMPARE THE EFFECT ON THE SAME GRAPH####
# This design option with have 2 ISAs  and each ISA will have 1 interim analysis and a final analysis
# At IA 1 if p-value > 0.9 --> futility, p-value < 0.048 --> Early success (Go) otherwise continue
# at IA 2 if p-value > 0.048 -->futility, p-value < 0.048 --> success (Go) 

# UPDATE: Adding a 2nd row for the mQtyPatientsPerArm will add another ISA with  192 per arm

mQtyPatientsPerArm <- matrix( c( 192, 192,
                                 192, 192 ), nrow=2, ncol = 2 )
mMinQtyPats       <- cbind( floor(apply( mQtyPatientsPerArm , 1, sum )/2),  apply( mQtyPatientsPerArm , 1, sum ) )
vMinFUTime        <- rep( dQtyMonthsFU, ncol( mMinQtyPats) )
dQtyMonthsBtwIA   <- 0

# UPDATE: Because you have 2 ISAs you must have 2 ISA starts time, this version assumes ISA1 starts at time 0 and
# ISA 2 starts at 4 months after the start of the trial.  If you wanted to simulate a random start time for ISA 2 see 
# SimulationDesign.R line 31

vISAStartTimes     <- c(  0, 4 )
vPValueCutoffForFutility <- c( 0.9, 0.048 )
vPValueCutoffForSuccess  <- c( 0.048, 0.048 )



cTrialDesign3 <- SetupTrialDesign( strAnalysisModel   = "TTestOneSided",
                                  strBorrowing       = "AllControls",
                                  mPatientsPerArm    = mQtyPatientsPerArm,
                                  mMinQtyPat         = mMinQtyPats,
                                  vMinFUTime         = vMinFUTime,
                                  dQtyMonthsFU       = dQtyMonthsFU,
                                  dQtyMonthsBtwIA    = dQtyMonthsBtwIA,
                                  vPValueCutoffForFutility = vPValueCutoffForFutility,
                                  vPValueCutoffForSuccess  = vPValueCutoffForSuccess)

# Update - For this challenge the patient simulator is the normal with point mass so need to update the class in the simulation object

cSimulation3  <- SetupSimulations( cTrialDesign3,
                                  nQtyReps                  = nQtyReps,
                                  strSimPatientOutcomeClass = "NormalWithPointMass",
                                  vISAStartTimes            = vISAStartTimes,
                                  nDesign                   = 3,
                                  vProbPatAtPointMass       = c( 0.3, 0.1 ), 
                                  vPointMassValue           = c( 0, 0 ) )

cSimulation$SimDesigns[[3]] <- cSimulation3$SimDesigns[[1]]

#Save the design file because we will need it in the RMarkdown file for processing simulation results
save( cTrialDesign3, file="cTrialDesign3.RData" )

####################################################################################################### .

# Design Option 4 SAME AS DESIGN 2 JUST CHANGING THE SIMULATION MODEL SO WE CAN COMPARE THE EFFECT ON THE SAME GRAPH####
# This design option with have 2 ISAs  and each ISA will have 2 interim analysis and a final analysis
# At IA 1 if p-value > 0.9 --> futility, p-value < 0.001 --> Early success (Go) otherwise continue
# at IA 2 if p-value > 0.048 -->futility, p-value < 0.016 --> Early success (Go) otherwise continue
# at final if p-value > 0.045 -->Futility, Go otherwise
# 
# UPDATE: Adding a 2nd row for the mQtyPatientsPerArm will add another ISA with  192 per arm
mQtyPatientsPerArm <- matrix( c( 293, 293,
                                 293, 293), nrow=2, ncol = 2 )
mMinQtyPats       <- cbind( floor(apply( mQtyPatientsPerArm , 1, sum )/3),floor(2*apply( mQtyPatientsPerArm , 1, sum )/3),  apply( mQtyPatientsPerArm , 1, sum ) )
vMinFUTime        <- rep( dQtyMonthsFU, ncol( mMinQtyPats) )
dQtyMonthsBtwIA   <- 0

# UPDATE: Because you have 2 ISAs you must have 2 ISA starts time, this version assumes ISA1 starts at time 0 and
# ISA 2 starts at 4 months after the start of the trial.  If you wanted to simulate a random start time for ISA 2 see 
# SimulationDesign.R line 31

vISAStartTimes     <- c(  0, 4 )

vPValueCutoffForFutility <- c( 0.9,   0.048, 0.045 )
vPValueCutoffForSuccess  <- c( 0.001, 0.016, 0.045 )

cTrialDesign4 <- SetupTrialDesign( strAnalysisModel   = "TTestOneSided",
                                   strBorrowing       = "AllControls",
                                   mPatientsPerArm    = mQtyPatientsPerArm,
                                   mMinQtyPat         = mMinQtyPats,
                                   vMinFUTime         = vMinFUTime,
                                   dQtyMonthsBtwIA    = dQtyMonthsBtwIA,
                                   vPValueCutoffForFutility = vPValueCutoffForFutility,
                                   vPValueCutoffForSuccess = vPValueCutoffForSuccess)

cSimulation4 <- SetupSimulations( cTrialDesign4,
                                  nQtyReps                  = nQtyReps,
                                  strSimPatientOutcomeClass = "NormalWithPointMass",
                                  vISAStartTimes            = vISAStartTimes,
                                  nDesign                   = 4,
                                  vProbPatAtPointMass       = c( 0.3, 0.1 ), 
                                  vPointMassValue           = c( 0, 0 ))

cSimulation$SimDesigns[[4]] <- cSimulation4$SimDesigns[[1]]

save( cTrialDesign4, file = "cTrialDesign4.RData" )







#################################################################################################### .
# Simulation Case 2 - Patients are simulated from a Normal with a point mass.
# Control: 70% of patients come from a N( 0, 1) and 30% have an outcome value of 0.3.  
#          Experimental: 90% of patients come from a normal( 0.3, 1) and 10% have  an outcome of 0.3.  ####
#################################################################################################### .



# Design option 5 - SAME AS DESIGN 1 AND 3 JUST CHANGING THE SIMULATION MODEL SO WE CAN COMPARE THE EFFECT ON THE SAME GRAPH####
# This design option with have 2 ISAs  and each ISA will have 1 interim analysis and a final analysis
# At IA 1 if p-value > 0.9 --> futility, p-value < 0.048 --> Early success (Go) otherwise continue
# at IA 2 if p-value > 0.048 -->futility, p-value < 0.048 --> success (Go) 

# UPDATE: Adding a 2nd row for the mQtyPatientsPerArm will add another ISA with  192 per arm

mQtyPatientsPerArm <- matrix( c( 192, 192,
                                 192, 192 ), nrow=2, ncol = 2 )
mMinQtyPats       <- cbind( floor(apply( mQtyPatientsPerArm , 1, sum )/2),  apply( mQtyPatientsPerArm , 1, sum ) )
vMinFUTime        <- rep( dQtyMonthsFU, ncol( mMinQtyPats) )
dQtyMonthsBtwIA   <- 0

# UPDATE: Because you have 2 ISAs you must have 2 ISA starts time, this version assumes ISA1 starts at time 0 and
# ISA 2 starts at 4 months after the start of the trial.  If you wanted to simulate a random start time for ISA 2 see 
# SimulationDesign.R line 31

vISAStartTimes     <- c(  0, 4 )

vPValueCutoffForFutility <- c( 0.9, 0.048 )
vPValueCutoffForSuccess  <- c( 0.048, 0.048 )



cTrialDesign5 <- SetupTrialDesign( strAnalysisModel   = "TTestOneSided",
                                   strBorrowing       = "AllControls",
                                   mPatientsPerArm    = mQtyPatientsPerArm,
                                   mMinQtyPat         = mMinQtyPats,
                                   vMinFUTime         = vMinFUTime,
                                   dQtyMonthsFU       = dQtyMonthsFU,
                                   dQtyMonthsBtwIA    = dQtyMonthsBtwIA,
                                   vPValueCutoffForFutility = vPValueCutoffForFutility,
                                   vPValueCutoffForSuccess  = vPValueCutoffForSuccess)

# Update - For this challenge the patient simulator is the normal with point mass so need to update the class in the simulation object

cSimulation5  <- SetupSimulations( cTrialDesign5,
                                   nQtyReps                  = nQtyReps,
                                   strSimPatientOutcomeClass = "NormalWithPointMass",
                                   vISAStartTimes            = vISAStartTimes,
                                   nDesign                   = 5,
                                   vProbPatAtPointMass       = c( 0.3, 0.1 ), 
                                   vPointMassValue           = c( 0.3, 0.3 ) )

cSimulation$SimDesigns[[5]] <- cSimulation5$SimDesigns[[1]]

#Save the design file because we will need it in the RMarkdown file for processing simulation results
save( cTrialDesign5, file="cTrialDesign5.RData" )

####################################################################################################### .

# Design Option 6 SAME AS DESIGN 2 AND 4 JUST CHANGING THE SIMULATION MODEL SO WE CAN COMPARE THE EFFECT ON THE SAME GRAPH####
# This design option with have 2 ISAs  and each ISA will have 2 interim analysis and a final analysis
# At IA 1 if p-value > 0.9 --> futility, p-value < 0.001 --> Early success (Go) otherwise continue
# at IA 2 if p-value > 0.048 -->futility, p-value < 0.016 --> Early success (Go) otherwise continue
# at final if p-value > 0.045 -->Futility, Go otherwise
# 
# UPDATE: Adding a 2nd row for the mQtyPatientsPerArm will add another ISA with  192 per arm
mQtyPatientsPerArm <- matrix( c( 293, 293,
                                 293, 293), nrow=2, ncol = 2 )
mMinQtyPats       <- cbind( floor(apply( mQtyPatientsPerArm , 1, sum )/3),floor(2*apply( mQtyPatientsPerArm , 1, sum )/3),  apply( mQtyPatientsPerArm , 1, sum ) )
vMinFUTime        <- rep( dQtyMonthsFU, ncol( mMinQtyPats) )
dQtyMonthsBtwIA   <- 0

# UPDATE: Because you have 2 ISAs you must have 2 ISA starts time, this version assumes ISA1 starts at time 0 and
# ISA 2 starts at 4 months after the start of the trial.  If you wanted to simulate a random start time for ISA 2 see 
# SimulationDesign.R line 31

vISAStartTimes     <- c(  0, 4 )

vPValueCutoffForFutility <- c( 0.9,   0.048, 0.045 )
vPValueCutoffForSuccess  <- c( 0.001, 0.016, 0.045 )

cTrialDesign6 <- SetupTrialDesign( strAnalysisModel   = "TTestOneSided",
                                   strBorrowing       = "AllControls",
                                   mPatientsPerArm    = mQtyPatientsPerArm,
                                   mMinQtyPat         = mMinQtyPats,
                                   vMinFUTime         = vMinFUTime,
                                   dQtyMonthsBtwIA    = dQtyMonthsBtwIA,
                                   vPValueCutoffForFutility = vPValueCutoffForFutility,
                                   vPValueCutoffForSuccess = vPValueCutoffForSuccess)

cSimulation6 <- SetupSimulations( cTrialDesign6,
                                  nQtyReps                  = nQtyReps,
                                  strSimPatientOutcomeClass = "NormalWithPointMass",
                                  vISAStartTimes            = vISAStartTimes,
                                  nDesign                   = 6,
                                  vProbPatAtPointMass       = c( 0.3, 0.1 ), 
                                  vPointMassValue           = c( 0.3, 0.3 ))

cSimulation$SimDesigns[[6]] <- cSimulation6$SimDesigns[[1]]

save( cTrialDesign6, file = "cTrialDesign6.RData" )








#################################################################################################### .
# Simulation Case 3 - Patients are simulated from a Normal with a point mass.
# Control: 70% of patients come from a N( 0, 1) and 30% have an outcome value of -0.3.  
#          Experimental: 90% of patients come from a normal( 0.3, 1) and 10% have  an outcome of -0.3.  ####
#################################################################################################### .



# Design option 7- SAME AS DESIGN 1, 3 AND 5 JUST CHANGING THE SIMULATION MODEL SO WE CAN COMPARE THE EFFECT ON THE SAME GRAPH####
# This design option with have 2 ISAs  and each ISA will have 1 interim analysis and a final analysis
# At IA 1 if p-value > 0.9 --> futility, p-value < 0.048 --> Early success (Go) otherwise continue
# at IA 2 if p-value > 0.048 -->futility, p-value < 0.048 --> success (Go) 

# UPDATE: Adding a 2nd row for the mQtyPatientsPerArm will add another ISA with  192 per arm

mQtyPatientsPerArm <- matrix( c( 192, 192,
                                 192, 192 ), nrow=2, ncol = 2 )
mMinQtyPats       <- cbind( floor(apply( mQtyPatientsPerArm , 1, sum )/2),  apply( mQtyPatientsPerArm , 1, sum ) )
vMinFUTime        <- rep( dQtyMonthsFU, ncol( mMinQtyPats) )
dQtyMonthsBtwIA   <- 0

# UPDATE: Because you have 2 ISAs you must have 2 ISA starts time, this version assumes ISA1 starts at time 0 and
# ISA 2 starts at 4 months after the start of the trial.  If you wanted to simulate a random start time for ISA 2 see 
# SimulationDesign.R line 31

vISAStartTimes     <- c(  0, 4 )

vPValueCutoffForFutility <- c( 0.9, 0.048 )
vPValueCutoffForSuccess  <- c( 0.048, 0.048 )



cTrialDesign7 <- SetupTrialDesign( strAnalysisModel   = "TTestOneSided",
                                   strBorrowing       = "AllControls",
                                   mPatientsPerArm    = mQtyPatientsPerArm,
                                   mMinQtyPat         = mMinQtyPats,
                                   vMinFUTime         = vMinFUTime,
                                   dQtyMonthsFU       = dQtyMonthsFU,
                                   dQtyMonthsBtwIA    = dQtyMonthsBtwIA,
                                   vPValueCutoffForFutility = vPValueCutoffForFutility,
                                   vPValueCutoffForSuccess  = vPValueCutoffForSuccess)

# Update - For this challenge the patient simulator is the normal with point mass so need to update the class in the simulation object

cSimulation7  <- SetupSimulations( cTrialDesign7,
                                   nQtyReps                  = nQtyReps,
                                   strSimPatientOutcomeClass = "NormalWithPointMass",
                                   vISAStartTimes            = vISAStartTimes,
                                   nDesign                   = 7,
                                   vProbPatAtPointMass       = c( 0.3, 0.1 ), 
                                   vPointMassValue           = c( -0.3, -0.3 ) )

cSimulation$SimDesigns[[7]] <- cSimulation7$SimDesigns[[1]]

#Save the design file because we will need it in the RMarkdown file for processing simulation results
save( cTrialDesign7, file="cTrialDesign7.RData" )

####################################################################################################### .

# Design Option 8 SAME AS DESIGN 2, 4 AND 6 JUST CHANGING THE SIMULATION MODEL SO WE CAN COMPARE THE EFFECT ON THE SAME GRAPH####
# This design option with have 2 ISAs  and each ISA will have 2 interim analysis and a final analysis
# At IA 1 if p-value > 0.9 --> futility, p-value < 0.001 --> Early success (Go) otherwise continue
# at IA 2 if p-value > 0.048 -->futility, p-value < 0.016 --> Early success (Go) otherwise continue
# at final if p-value > 0.045 -->Futility, Go otherwise
# 
# UPDATE: Adding a 2nd row for the mQtyPatientsPerArm will add another ISA with  192 per arm
mQtyPatientsPerArm <- matrix( c( 293, 293,
                                 293, 293), nrow=2, ncol = 2 )
mMinQtyPats       <- cbind( floor(apply( mQtyPatientsPerArm , 1, sum )/3),floor(2*apply( mQtyPatientsPerArm , 1, sum )/3),  apply( mQtyPatientsPerArm , 1, sum ) )
vMinFUTime        <- rep( dQtyMonthsFU, ncol( mMinQtyPats) )
dQtyMonthsBtwIA   <- 0

# UPDATE: Because you have 2 ISAs you must have 2 ISA starts time, this version assumes ISA1 starts at time 0 and
# ISA 2 starts at 4 months after the start of the trial.  If you wanted to simulate a random start time for ISA 2 see 
# SimulationDesign.R line 31

vISAStartTimes     <- c(  0, 4 )

vPValueCutoffForFutility <- c( 0.9,   0.048, 0.045 )
vPValueCutoffForSuccess  <- c( 0.001, 0.016, 0.045 )

cTrialDesign8 <- SetupTrialDesign( strAnalysisModel   = "TTestOneSided",
                                   strBorrowing       = "AllControls",
                                   mPatientsPerArm    = mQtyPatientsPerArm,
                                   mMinQtyPat         = mMinQtyPats,
                                   vMinFUTime         = vMinFUTime,
                                   dQtyMonthsBtwIA    = dQtyMonthsBtwIA,
                                   vPValueCutoffForFutility = vPValueCutoffForFutility,
                                   vPValueCutoffForSuccess = vPValueCutoffForSuccess)

cSimulation8 <- SetupSimulations( cTrialDesign8,
                                  nQtyReps                  = nQtyReps,
                                  strSimPatientOutcomeClass = "NormalWithPointMass",
                                  vISAStartTimes            = vISAStartTimes,
                                  nDesign                   = 8,
                                  vProbPatAtPointMass       = c( 0.3, 0.1 ), 
                                  vPointMassValue           = c( -0.3,-0.3 ))

cSimulation$SimDesigns[[8]] <- cSimulation8$SimDesigns[[1]]

save( cTrialDesign8, file = "cTrialDesign8.RData" )





#Often it is good to keep the design objects for utilizing in a report

lTrialDesigns <- list( cTrialDesign1 = cTrialDesign, 
                       cTrialDesign2 = cTrialDesign2, 
                       cTrialDesign3 = cTrialDesign3, 
                       cTrialDesign4 = cTrialDesign4, 
                       cTrialDesign5 = cTrialDesign5, 
                       cTrialDesign6 = cTrialDesign6, 
                       cTrialDesign7 = cTrialDesign7, 
                       cTrialDesign8 = cTrialDesign8 )
save( lTrialDesigns, file="lTrialDesigns.RData")

# End of multiple design options - stop deleting or commenting out here if not utilizing example for multiple designs.

#  As a general best practice, it is good to remove all objects in the global environment just to make sure they are not inadvertently used.
#  The only object that is needed is the cSimulation object and gDebug, gnPrintDetail.
rm( list=(ls()[ls()!="cSimulation" ]))



# Declare global variable (prefix with g to make it clear)
gDebug        <- FALSE   # Can be useful to set if( gDebug ) statements when developing new functions
gnPrintDetail <- 0       # Higher number cause more printing to be done during the simulation.  A value of 0 prints almost nothing and should be used when running
                         # large scale simulations.
bDebug2 <- FALSE
# Files specific for this project that were added and are not available in OCTOPUS.
# These files create new generic functions that are utilized during the simulation.
source( 'RunAnalysis.TTestOneSided.R' )
source( 'SimPatientOutcomes.Normal.R' )  # This will add the new outcome

# UPDATE: Make sure to source the new patient simulator or it will not work, you will get an error about the default sim patient outcomes
source( 'SimPatientOutcomes.NormalWithPointMass.R' )  # This will add the new outcome
source( "BinaryFunctions.R" )

# The next line will execute the simulations
t1 <- Sys.time()
RunSimulation( cSimulation )
t2 <- Sys.time()
t2 - t1


# If running on a single instance (computer) you could just increase the nQtyReps above and use code as is up to the RunSimulation() line.
# However, to "simulate" running this on the grid and getting multiple output files, combining them
# then creating an R markdown document the following loop could be executed

# vSGETasks <- 2:20  # This will give us 100 reps (20 * 5)
# for ( nSGETask in vSGETasks )
# {
#     gDebug <- FALSE
#     Sys.setenv(SGE_TASK_ID= nSGETask )
#     print( paste( "Simulating task ", nSGETask, " of ", length( vSGETasks ), "..."))
#     RunSimulation( cSimulation )
# }

# Post Process ####
# Create .RData sets of the simulation results
# simsCombined.Rdata - This will have the main results about the platform and decisions made for each ISA
#
#mSimRes <- OCTOPUS::BuildSimulationResultsDataSet( )



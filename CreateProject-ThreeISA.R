# The purpose of this file is to provide examples of how to create new R Studio projects utilizing
# CreateProject() from the OCTOPUS package.  See ?OCTOPUS::CreateProject for more details on the function.
# This file was used to create the project in the folder CategoricalOutcome.
#rm(list=ls())

library( OCTOPUS )

# Example: 
# 1st ISA with 50 Patients on Control and 100 on treatment
# Analysis: Create a new analysis called BetaBinom - The function will only provide example code and the function outline
# Patient outcome: Binary
# Borrowing - All controls, since there is only 1 ISA this is not relevant
# Number of Reps to simulate each trial: 100
# Each patient if followed up for 6 months to get the binary outcome

#Basic setup about the project info for creating the project
bCreateProjectSubdirectory <- TRUE
strProjDir                 <- ""   # Since this is not a complete path, directory is created relative to working directory
strProjName                <- "ThreeISA.EUPEARL"

# Start of info for th platform trial. 
strAnalysis                <- "BetaBinomial"
strSimPatOutcome           <- "Binary"
strBorrowing               <- "AllControls"

# The matrix  mQtyPats contains the number of patients in each arm in each ISA.  Each row represents an ISA, each column is
# a treatment with the first column the number of patients in control.  The first ISA (row 1) has 50 patients on control
# 100 on treatment 2.  The second ISA (row 2) has 25 patients on control and 125 on treatment 2
# the third ISA has 25 on control and 125 on treatment.  
mQtyPats                   <- matrix( c( 50, 100,
                                         25, 125,
                                         25, 125), byrow=TRUE, ncol=2 )
dQtyMonthsFU               <- 6
nQtyReps                   <- 150
vISAStartTimes             <- c( 0, 6, 12  )

strResult <- CreateProject( strProjectDirectory        = strProjDir,
                            strProjectName             = strProjName,
                            strAnalysisName            = strAnalysis,
                            strSimPatientOutcomeName   = strSimPatOutcome,
                            strBorrowing               = strBorrowing,
                            nQtyReps                   = nQtyReps,
                            mQtyPatientsPerArm         = mQtyPats,
                            dQtyMonthsFU               = dQtyMonthsFU,
                            vISAStartTimes             = vISAStartTimes,
                            bCreateProjectSubdirectory = bCreateProjectSubdirectory)

cat( strResult)



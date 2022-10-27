# This file will process the simulation results and create several .RData files containing ISA results and the trial results


library( OCTOPUS )
library( dplyr ) 
library( ggplot )
source( "PostProcess.R")

dfSimRes <- BuildSimulationResultsDataSet( )


unique( dfSimRes$iScen)
vNumberOfSites               <- seq( 30, 100, 10 )
vAverageEnrollementTimeISA1  <- rep( NA, 8 )
vAverageEnrollementTimeISA2  <- rep( NA, 8 )
vAverageEnrollementTimeISA3  <- rep( NA, 8 )

for( i in 1:length(vNumberOfSites) )
{
    dfScen <- dplyr::filter( dfSimRes, iScen == i )
    print( paste( "Qty Reps ", nrow( dfScen )))
    vAverageEnrollementTimeISA1[ i ] <- mean( dfScen$FinalPatientEnrolledTimeISA1 - dfScen$ISAStart1 )
    vAverageEnrollementTimeISA2[ i ] <- mean( dfScen$FinalPatientEnrolledTimeISA2 - dfScen$ISAStart2 )
    vAverageEnrollementTimeISA3[ i ] <- mean( dfScen$FinalPatientEnrolledTimeISA3 - dfScen$ISAStart3 )
}



dfResPlatform <- data.frame( NumberOfSites          = rep( vNumberOfSites, 3 ) , 
                             AverageEnrollementTime = c( vAverageEnrollementTimeISA1, vAverageEnrollementTimeISA2, vAverageEnrollementTimeISA3 ),
                             ISA                    = factor( rep( c(1, 2, 3), rep( length( vNumberOfSites), 3 ) ) ) )


# Note: The tile was set for the example, if the ISA entery times are updated in the simulation then the title should be changed.

ggplot( dfResPlatform, aes( x = NumberOfSites, AverageEnrollementTime, group = ISA, colour = ISA ) ) + 
    geom_line( ) +
    geom_point() +
    theme_bw()  + 
    xlab("Number of Sites") + 
    ylab( "Duration of Accrual (Months) ") +
    ggtitle( paste0( "4 Month Delay Between ISAs\n Randomization 2:1")) + 
    theme(plot.title =element_text(hjust=0.5) ) +
    scale_y_continuous(breaks=seq(0, 36,by=6), minor_breaks=seq( 0, 36,by=3),limit=c(0,36) )


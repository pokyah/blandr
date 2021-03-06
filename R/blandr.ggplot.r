#' @title Bland-Altman plotting function, using ggplot2
#'
#' @description Draws a Bland-Altman plot using data calculated using the other functions, using ggplot2
#'
#' @author Deepankar Datta <deepankardatta@nhs.net>
#'
#' @param statistics.results A list of statistics generated by the blandr.statistics function: see the function's return list to see what variables are passed to this function
#' @param y.plot.mode (Optional) Switch to change y-axis from being plotted by difference (="difference") or by proportion magnitude of measurements (="proportion"). Default is "difference". Anything other than "proportional" will switch to default mode.
#' @param method1name (Optional) Plotting name for 1st method, default "Method 1"
#' @param method2name (Optional) Plotting name for 2nd method, default "Method 2"
#' @param plotTitle (Optional) Title name, default "Bland-Altman plot for comparison of 2 methods"
#' @param ciDisplay (Optional) TRUE/FALSE switch to plot confidence intervals for bias and limits of agreement, default=TRUE
#' @param ciShading (Optional) TRUE/FALSE switch to plot confidence interval shading to plot, default=TRUE
#' @param normalLow (Optional) If there is a normal range, entering a continuous variable will plot a vertical line on the plot to indicate its lower boundary
#' @param normalHigh (Optional) If there is a normal range, entering a continuous variable will plot a vertical line on the plot to indicate its higher boundary
#' @param overlapping (Optional) TRUE/FALSE switch to increase size of plotted point if multiple values using ggplot's geom_count, deafult=FALSE. Not currently recommend until I can tweak the graphics to make them better
#'
#' @return ba.plot Returns a ggplot data set that can then be plotted
#'
#' @import ggplot2
#'
#' @examples
#' # Generates two random measurements
#' measurement1 <- rnorm(100)
#' measurement2 <- rnorm(100)
#'
#' # Generates a ggplot
#' # Do note the ggplot function wasn't meant to be used on it's own
#' # and is generally called via the bland.altman.display.and.draw function
#'
#' # Passes data to the blandr.statistics function to generate Bland-Altman statistics
#' statistics.results <- blandr.statistics( measurement1 , measurement2 )
#'
#' # Generates a ggplot, with no optional arguments
#' blandr.ggplot( statistics.results )
#'
#' # Generates a ggplot, with title changed
#' blandr.ggplot( statistics.results , plotTitle = "Bland-Altman example plot" )
#'
#' # Generates a ggplot, with title changed, and confidence intervals off
#' blandr.ggplot( statistics.results , plotTitle = "Bland-Altman example plot" ,
#' ciDisplay = FALSE , ciShading = FALSE )
#'
#' @export

blandr.ggplot <- function ( statistics.results ,
                            y.plot.mode = "difference" ,
                            method1name = "Method 1" ,
                            method2name = "Method 2" ,
                            plotTitle = "Bland-Altman plot for comparison of 2 methods" ,
                            ciDisplay = TRUE ,
                            ciShading = TRUE ,
                            normalLow = FALSE ,
                            normalHigh = FALSE ,
                            overlapping = FALSE ) {

  # Selects if uses differences (traditional) or proportions (non-traditional BA)
  if( y.plot.mode == "proportion" ) {
    plot.data <- data.frame( statistics.results$means , statistics.results$proportion )
  } else {
    plot.data <- data.frame( statistics.results$means , statistics.results$differences )
  }

  # Rename to allow plotting
  colnames(plot.data)[1] <- "x.axis"
  colnames(plot.data)[2] <- "y.axis"

  # Plot using ggplot
  ba.plot <- ggplot( plot.data , aes( x = plot.data$x.axis , y = plot.data$y.axis ) ) +
    geom_point() +
    theme(plot.title = element_text(hjust = 0.5)) +
    geom_hline( yintercept = 0 , linetype = 1 ) + # "0" line
    geom_hline( yintercept = statistics.results$bias , linetype = 2 ) + # Bias
    geom_hline( yintercept = statistics.results$bias + ( statistics.results$biasStdDev * statistics.results$sig.level.convert.to.z ) , linetype = 2 ) + # Upper limit of agreement
    geom_hline( yintercept = statistics.results$bias - ( statistics.results$biasStdDev * statistics.results$sig.level.convert.to.z ) , linetype = 2 ) + # Lower limit of agreement
    ggtitle( plotTitle ) +
    xlab( "Means" )

  # Re-titles the y-axis dependent on which plot option was used
  if ( y.plot.mode == "proportion" ) {
    ba.plot <- ba.plot + ylab( "Difference / Average %" )
  } else {
    ba.plot <- ba.plot + ylab( "Differences" )
  }

  # Drawing confidence intervals (OPTIONAL)
  if( ciDisplay == TRUE ) {
    ba.plot <- ba.plot +
    geom_hline( yintercept = statistics.results$biasUpperCI , linetype = 3 ) + # Bias - upper confidence interval
    geom_hline( yintercept = statistics.results$biasLowerCI , linetype = 3 ) + # Bias - lower confidence interval
    geom_hline( yintercept = statistics.results$upperLOA_upperCI , linetype = 3 ) + # Upper limit of agreement - upper confidence interval
    geom_hline( yintercept = statistics.results$upperLOA_lowerCI , linetype = 3 ) + # Upper limit of agreement - lower confidence interval
    geom_hline( yintercept = statistics.results$lowerLOA_upperCI , linetype = 3 ) + # Lower limit of agreement - upper confidence interval
    geom_hline( yintercept = statistics.results$lowerLOA_lowerCI , linetype = 3 ) # Lower limit of agreement - lower confidence interval

    # Shading areas for 95% confidence intervals (OPTIONAL)
    # This needs to be nested into the ciDisplay check
    if( ciShading == TRUE ) {
      ba.plot <- ba.plot +
        annotate( "rect", xmin = -Inf , xmax = Inf , ymin = statistics.results$biasLowerCI , ymax = statistics.results$biasUpperCI , fill="blue" , alpha=0.3 ) + # Bias confidence interval shading
        annotate( "rect", xmin = -Inf , xmax = Inf , ymin = statistics.results$upperLOA_lowerCI , ymax = statistics.results$upperLOA_upperCI , fill="green" , alpha=0.3 ) + # Upper limits of agreement confidence interval shading
        annotate( "rect", xmin = -Inf , xmax = Inf , ymin = statistics.results$lowerLOA_lowerCI , ymax = statistics.results$lowerLOA_upperCI , fill="red" , alpha=0.3 ) # Lower limits of agreement confidence interval shading
    }

  }

  # If a normalLow value has been sent, plots this line
  if( normalLow != FALSE ) {
      ba.plot <- ba.plot + geom_vline( xintercept = normalLow , linetype = 4 , col=6 )
    }

  # If a normalHighvalue has been sent, plots this line
  if( normalHigh != FALSE ) {
      ba.plot <- ba.plot + geom_vline( xintercept = normalHigh , linetype = 4 , col=6 )
    }

  # If overlapping=TRUE uses geom_count
  if( overlapping == TRUE ) {
    ba.plot <- ba.plot + geom_count()
  }

  return(ba.plot)

  #END OF FUNCTION
}


# Developing Data Products Final Project
# Coursera JHU Data Science Specialization
# github.com/sylvest00
#
# Project: Visualizing Capital Bike Share Data
# server.R file
# Janurary 29, 2017

library(shiny)
library(stringr)
library(ggplot2)

df <- read.csv('2016-Q2-Trips-History-Data.csv', header = TRUE)
colnames(df) <- c('duration_ms','start_dateTime','end_dateTime','startStationNum','startStation','endStationNum','endStation','bikeNum','acct_type')
df$start_dateTime2 <- strptime(df$start_dateTime,'%m/%d/%Y %H:%M')


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    #output$dateRangeText <- renderPrint({ input$dateRange })
    output$plotTitle <- renderText({
        paste("Bike Share Data from ", format(as.Date(input$dateRange[1]),"%B %d, %Y"),
              "to ", format(as.Date(input$dateRange[2]),"%B %d, %Y"))
    })
    
    dfFin <- reactive({
        # Subset for dates
        df2 <- subset(df,format.Date(start_dateTime2,'%Y-%m-%d') >= input$dateRange[1] & format.Date(start_dateTime2,'%Y-%m-%d') <= input$dateRange[2])
        
        
        # Sum of time and riders over date range
        dateSpan <- unique(format.Date(df2$start_dateTime2,'%Y-%m-%d'))
        totalRiders_casual <- 0
        totalDuration_casual <- 0
        totalRiders_reg <- 0
        totalDuration_reg <- 0
        
        for (i in 1:length(dateSpan)){
            # casual riders
            idx <- which(format.Date(df2$start_dateTime2,'%Y-%m-%d') == dateSpan[i] & df2$acct_type == 'Casual')
            totalRiders_casual[i] <- length(idx)
            totalDuration_casual[i] <- sum(as.numeric(df2$duration_ms[idx])) / 1000 / 60 / 60 # hours
            
            # registered riders
            idx <- which(format.Date(df2$start_dateTime2,'%Y-%m-%d') == dateSpan[i] & df2$acct_type == 'Registered')
            totalRiders_reg[i] <- length(idx)
            totalDuration_reg[i] <- sum(as.numeric(df2$duration_ms[idx])) / 1000 / 60 / 60 # hours
        }
        
        df3 <- data.frame(dates = as.Date(rep(dateSpan,2)),
                          riderTotals = c(totalRiders_casual,totalRiders_reg),
                          durationTotals = c(totalDuration_casual,totalDuration_reg),
                          riderType = c(rep('Casual',length(dateSpan)), rep('Registered',length(dateSpan))))    
    
        return(df3)
    })
    
    output$dfSize <- renderText(dim(dfFin)[1])
   
    output$totalRiders_linePlot <- renderPlot({
        if (dim(dfFin())[1] > 8){
        d1 <- ggplot(dfFin(), aes(x = dates, y = riderTotals,
                              group = riderType, colour = factor(riderType)))
        d1 + geom_line(size = 2) + guides(color=guide_legend("Account Type")) +
            xlab('Date') +
            ylab('Total Number of Bike Rentals') +
            ggtitle('Total Bike Rentals Per Day') +
            scale_x_date(date_labels = "%b %d", date_minor_breaks = "1 day", date_breaks = "2 day") +
            theme(axis.text.x=element_text(angle=45, hjust=1))
        } else{
            t1 <- ggplot(dfFin(), aes(x = dates, y = riderTotals, fill = factor(riderType)))
            t1 + geom_bar(stat = 'identity', position="dodge") +
                scale_fill_discrete(name="Account Type") +
                xlab('Date') +
                ylab('Total Number of Bike Rentals') +
                ggtitle('Total Bike Rentals Per Day')
        }
    })
   
    
   output$duration_linePlot <- renderPlot({
       if (dim(dfFin())[1] > 8){
        d2 <- ggplot(dfFin(), aes(x = dates, y = durationTotals,
                              group = riderType, colour = factor(riderType)))
        d2 + geom_line(size = 2) + guides(color=guide_legend("Account Type")) +
            xlab('Date') +
            ylab('Total Duration (Hours)') +
            ggtitle('Total Rental Hours Per Day') +
            scale_x_date(date_labels = "%b %d", date_minor_breaks = "1 day", date_breaks = "2 day") +
            theme(axis.text.x=element_text(angle=45, hjust=1))
       } else{
           t2 <- ggplot(dfFin(), aes(x = dates, y = durationTotals, fill = factor(riderType)))
           t2 + geom_bar(stat = 'identity', position="dodge") +
               scale_fill_discrete(name="Account Type") +
               xlab('Date') +
               ylab('Total Duration (Hours)') +
               ggtitle('Total Rental Hours Per Day')
       }
   })
})
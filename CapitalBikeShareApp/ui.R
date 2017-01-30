# Developing Data Products Final Project
# Coursera JHU Data Science Specialization
# github.com/sylvest00
#
# Project: Visualizing Capital Bike Share Data
# ui.R file
# Janurary 29, 2017


library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel(paste("Capital Bike Share Data:",
                "Visualize the Number of Bike Rentals & Rental Hours by Account Type",
                sep = "\n")),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
        helpText("INSTRUCTIONS: To visualize the number of bike rentals and total rent time, choose a 
                range of dates (between April 1, 2016 and June 30, 2016) that 
                 you would like to inspect below. Press the \"RUN!\" button
                 when you are ready to plot the data."),
        helpText("A bar plot will be displayed if the number of days selected is
                 less than or equal to 4, and a line plot will be displayed if
                 the number of days selected exceeds 4."),
        helpText("Note: The data set is large. Date ranges greater than 15 days
                will run slowly."),
        
       # Input date ranges for data
       dateRangeInput('dateRange',
                 label = h3('Select Date(s)'),
                 start = '4/1/2016', end = '4/15/2016',
                 min = '4/1/2016', max = '6/30/2016',
                 separator = ' - ',
                 format = 'MM dd, yyyy',
                 startview = 'year'),
       submitButton('Run!')
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
        textOutput("plotTitle"),
        tags$head(tags$style("#plotTitle{color: black;
                                 font-size: 20px;
                             font-style: italic;}"
                             )
                  ),
        
        fluidRow(splitLayout(cellWidths = c("50%", "50%"),
                             plotOutput("totalRiders_linePlot"),
                             plotOutput("duration_linePlot")
                             )
                 )
    )
  )
))
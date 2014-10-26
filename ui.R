library(shiny)
library(rCharts)


# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Stocks Time Series Analysis"),
  
  # Sidebar with controls to select the variable to plot against mpg
  # and to specify whether outliers should be included
  sidebarPanel(
    radioButtons("tickers_box", "Tickers:",
                  c("AAPL" = "AAPL", "SPY" = "SPY", "GLD" = "GLD", "Other" = "-1")),
    textInput("ticker", "Other", ""),
    dateRangeInput("dates", "Date Range", start="2010-01-01", end=as.character(Sys.Date())),
    br(),
    
    conditionalPanel(
      'input.tabs === "Returns"',
      radioButtons("returns_plot_type", "Show Returns as:",
                   c("Time Series" = "ts", "Histogram" = "hist")),
      br()
    )
    
#    conditionalPanel(
#      'input.tabs === "Analysis"',
#      radioButtons("process_type", "Returns Process:",
#                   c("AR(1)" = "ar1", "GARCH(1,1)" = "garch11"))
#    )
  ),
  
  mainPanel(
    tabsetPanel(id = 'tabs',
        tabPanel('Time Series', 
                 textOutput('companyName1'),
                 plotOutput('tsPlot')),
        tabPanel('Returns',
          textOutput('companyName2'),
          plotOutput('retPlot')),
#          conditionalPanel('input.process_type === "ar1"',
#                           textOutput('ar1.ar'),
#                           plotOutput('ar1.resid_qq'))),         
        tabPanel('Autocorrelations',
          textOutput('companyName3'),
          plotOutput('acfPlot')),

        tabPanel('Documentation',
                 includeHTML('Documentation.html'))
        
    )
  )
))

library(shiny)
library(quantmod)
library(rCharts)


# Define server logic required to plot various variables against mpg
shinyServer(function(input, output) {
  
  tkr <- reactive({
    if (input$tickers_box == "-1") input$ticker else input$tickers_box
  })
  
  companyName <- reactive({
    sym <- tkr()
    if (is.null(sym)) NULL
    else {
      try(compName <- getQuote(sym, what=yahooQF("Name")), TRUE)
      if (exists("compName")) paste(compName[,2]) else ""
    }
  })
    
  tkrData <- reactive({
    try(dt <- getSymbols(tkr(), src="yahoo", auto.assign = FALSE,
                         from = input$dates[1], to = input$dates[2]))
    if (exists("dt")) dt else NULL
  })
  
  tkrReturns <- reactive({
    dt <- tkrData()
    if (is.null(dt)) NULL
    else {
      tckRet <- ROC(dt)
      tckRet[complete.cases(tckRet)]    
    }
  })
  
  tkrDataFrame <- reactive({
    dt <- tkrData()
    if (is.null(dt)) NULL
    else data.frame(date = index(dt), date.char = as.character(index(dt)), coredata(dt))
  })
  
  retDataFrame <- reactive({
    dt <- tkrReturns()
    if (is.null(dt)) NULL
    else data.frame(date = index(dt), date.char = as.character(index(dt)), coredata(dt))
  })
  
  output$companyName1 <- renderText(companyName())
  output$companyName2 <- renderText(companyName()) 
  output$companyName3 <- renderText(companyName())
  
  output$tsPlot <- renderPlot({
    df <- tkrDataFrame()
    if (is.null(df)) NULL
    else {
#      m1 <- mPlot(x="date", y=colnames(df)[7], type="Line", data=df)
#      m1$set(pointSize=0, lineWidth=1)
#      m1$set(dom = 'tsPlot')
#      return(m1)
      plot(df$date, df[,8], type="l", xlab="Date", ylab="Adjusted Price", 
           main = paste0("Time Series for ", tkr()))
    }
  })

  output$retPlot <- renderPlot({
    df <- retDataFrame()
    if (is.null(df)) return(NULL)
  
    if (input$returns_plot_type == "ts") {
      plot(df$date, df[,8], type="l", xlab="Date", ylab="Relative Returns", yaxt="n",
           main=paste0("Relative Returns of ", tkr()))
      axis(2, at=pretty(df[,8]), lab= paste0(pretty(df[,8]) * 100, "%"), las=TRUE)  
    }
    else if (input$returns_plot_type == "hist") {
      hist(df[,8], breaks = 20, xlab="Relative Returns", xaxt="n", 
           main=paste0("Distribution of Relative Returns for ", tkr()))
      axis(1, at=pretty(df[,8]), lab= paste0(pretty(df[,8]) * 100, "%"), las=TRUE)  
    }
    else 
      NULL
  })

  output$acfPlot <- renderPlot({
    df <- retDataFrame()
    if (is.null(df)) NULL
    else {
      acorr <- acf(df[,8], plot=FALSE)
      plot(acorr, main="Autocorrelation of daily returns", xlab="Lag", ylab="Autocorrelation")
    }
  })
  
  
# Autoregressive (1) calcualtions (not included in the final app)
#  ar1 <- reactive({
#    df <- retDataFrame()
#    if (is.null(df)) NULL else ar(df[,8], FALSE, 1)
#  })

#  output$ar1.ar <- reactive({
#    ar1.res <- ar1()
#    if (is.null(ar1.res)) NULL else ar1.res$ar
#  })
  
#  output$ar2.resid_qq <- renderPlot({
#    ar1.res <- ar1()
#    if (is.null(ar1.res)) NULL 
#    else
#      qqplot(ar()$resid, main = "Normal Q-Q Plot for AR(1) residuals",
#             xlab = "Theoretical Normal Quantiles",
#             ylab = "Actual Quantiles of Returns")
#  })
})
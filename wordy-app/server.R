#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(wordcloud)
source('predict.R')


shinyServer(function(input, output, session) {
  observeEvent(input$predict_next, {
    dbout <- reactive({predictNext(input$text)})
    
    output$sentence <- renderText({input$text})
    output$predicted <- renderText({
      out <- dbout()
      return(out[1,keyword])
    })
    output$top_results <- renderTable({dbout()})
    
    output$option_1 <- renderUI({
      out <- dbout()
      actionButton("action1", label = out[1,keyword])
    })
    observeEvent(input$action1, {
      out <- dbout()
      updateTextInput(session, "text", value = paste(input$text, out[1,keyword]))
    })
    
    output$option_2 <- renderUI({
      out <- dbout()
      actionButton("action2", label = out[2,keyword])
    })
    observeEvent(input$action2, {
      out <- dbout()
      updateTextInput(session, "text", value = paste(input$text, out[2,keyword]))
    })
    
    output$option_3 <- renderUI({
      out <- dbout()
      actionButton("action3", label = out[3,keyword])
    })
    observeEvent(input$action3, {
      out <- dbout()
      updateTextInput(session, "text", value = paste(input$text, out[3,keyword]))
    })
    
  })
})

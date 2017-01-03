#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Next Word Prediction using Backoff Model"),
  h4("B. Porter's Coursera Data Science Capstone App", style="color:gray"),
  hr(),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    # Show the prediction
    mainPanel(
      textInput("text", label = h3("Input Text"), value = "how are"),
      helpText("Type your input text above and start by clicking the Predict! button."),
      actionButton("predict_next", "Predict!"),
      hr()
    ),
    sidebarPanel(
      h3("Your Input"),
      p(textOutput("sentence")),
      hr(),
      h3("Prediction Options"),
      helpText("Click prediction to append to input text"),
      div(uiOutput("option_1"),br(), uiOutput("option_2"), br(), uiOutput("option_3")),
      hr(),
      h4("Top Possibilities:", align="center"),
      div(tableOutput("top_results"), align="center")
    )
  )
))

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
  titlePanel("Next Word Prediction using the Backoff Model"),
  h4("B. Porter's Coursera Data Science Capstone App", style="color:gray"),
  hr(),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      textInput("text", label = h3("Input"), value = "how are"),
      helpText("Type in text above. "),
      submitButton("Predict next"),
      hr()
    ),
    
    # Show the prediction
    mainPanel(
      br(),
      h2(textOutput("sentence"), align="center"),
      h1(textOutput("predicted"), align="center", style="color:blue"),
      hr(),
      h3("Top 3 Possibilities:", align="center"),
      div(tableOutput("alts"), align="center"),
      div(plotOutput("wordCloud", align="center"))
    )
  )
))

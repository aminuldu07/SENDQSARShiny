# inst/app/ui.R
library(shiny)

ui <- fluidPage(
  titlePanel("QSAR and Toxicity Prediction"),
  sidebarLayout(
    sidebarPanel(
      helpText("This is a simple QSAR and Toxicity prediction app.")
    ),
    mainPanel(
      textOutput("text")
    )
  )
)

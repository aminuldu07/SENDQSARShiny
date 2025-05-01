# inst/app/server.R
library(shiny)

server <- function(input, output) {
  output$text <- renderText({
    "Welcome to the QSAR and Toxicity Prediction app!"
  })
}

#' Launch the Shiny App
#'
#' This function launches the QSAR Shiny application.
#' @export
run_app <- function() {
  shiny::runApp(system.file("app", package = "SENDQSARShiny"))
}





#
# # R/run_app.R
# run_app <- function() {
#   shiny::runApp(system.file("app", package = "SENDQSARShiny"))
# }

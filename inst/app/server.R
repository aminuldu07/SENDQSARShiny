# library(shiny)
# library(shinydashboard)
# library(SENDQSAR)
library(shiny)
library(shinydashboard)
library(SENDQSAR)

# Function metadata (input parameters for each function)
function_metadata <- list(
  "get_compile_data" = list(inputs = c("studyid" = "studyid", "path_db" = "path_db",
                                       "fake_study" = "checkbox", "use_xpt_file" = "checkbox")),
  "get_bw_score" = list(inputs = c("studyid" = "studyid", "path_db" = "path_db",
                                   "fake_study" = "checkbox", "use_xpt_file" = "checkbox",
                                   "master_compiledata" = "null_or_file",
                                   "return_individual_scores" = "checkbox",
                                   "return_zscore_by_USUBJID" = "checkbox")),
  "get_livertobw_score" = list(inputs = c("studyid" = "studyid", "path_db" = "path_db",
                                          "fake_study" = "checkbox", "use_xpt_file" = "checkbox",
                                          "master_compiledata" = "null_or_file",
                                          "bwzscore_BW" = "file_or_text",
                                          "return_individual_scores" = "checkbox",
                                          "return_zscore_by_USUBJID" = "checkbox")),
  "get_lb_score" = list(inputs = c("studyid" = "studyid", "path_db" = "path_db",
                                   "fake_study" = "checkbox", "use_xpt_file" = "checkbox",
                                   "master_compiledata" = "null_or_file",
                                   "return_individual_scores" = "checkbox",
                                   "return_zscore_by_USUBJID" = "checkbox")),
  "get_mi_score" = list(inputs = c("studyid" = "studyid",
                                   "path_db" = "path_db",
                                   "fake_study" = "checkbox",
                                   "use_xpt_file" = "checkbox",
                                   "master_compiledata" = "null_or_file",
                                   "return_individual_scores" = "checkbox",
                                   "return_zscore_by_USUBJID" = "checkbox")),
  "get_liver_om_lb_mi_tox_score_list" = list(inputs = c("studyid_or_studyids" = "studyid_or_studyids",
                                                        "path_db" = "path_db",
                                                        "fake_study" = "checkbox",
                                                        "use_xpt_file" = "checkbox",
                                                        "output_individual_scores" = "checkbox",
                                                        "output_zscore_by_USUBJID" = "checkbox")),
  "get_col_harmonized_scores_df" = list(inputs = c("liver_score_data_frame" = "file_or_text",
                                                   "Round" = "checkbox")),
  "get_ml_data_and_tuned_hyperparameters" = list(inputs = c("Data" = "file_or_text",
                                                            "studyid_metadata" = "file_or_text",
                                                            "Impute" = "checkbox",
                                                            "Round" = "checkbox",
                                                            "reps" = "numeric",
                                                            "holdback" = "numeric",
                                                            "Undersample" = "checkbox",
                                                            "hyperparameter_tuning" = "checkbox",
                                                            "error_correction_method" = "text")),
  "get_rf_model_with_cv" = list(inputs = c("scores_data_df" = "scores_data_df",
                                           "Undersample" = "checkbox",
                                           "best.m" = "numeric",
                                           "testReps" = "numeric",
                                           "Type" = "text")) #??????????????????
)

server <- function(input, output, session) {

  output$dynamic_inputs <- renderUI({
    req(input$selected_function)

    function_inputs <- function_metadata[[input$selected_function]]$inputs
    input_ui <- lapply(names(function_inputs), function(param) {
      input_type <- function_inputs[[param]]

      switch(input_type,
             "studyid" = div(textInput(param, label = param, value = "")),
             "path_db" = div(textInput(param, label = paste(param, "(Manual Path)"), value = "")),
             "null_or_file" = div(
               radioButtons(inputId = paste0(param, "_source"),
                            label = paste(param, "Source"),
                            choices = c("Use Default (NULL)" = "null", "Upload File" = "upload"),
                            selected = "null"),
               conditionalPanel(condition = paste0("input.", param, "_source == 'upload'"),
                                fileInput(inputId = paste0(param, "_file"), label = paste(param, "(Upload File)")))
             ),
             "file" = div(fileInput(param, label = paste(param, "(Upload File)"))),
             "checkbox" = div(checkboxInput(param, label = param, value = FALSE)),
             "numeric" = div(numericInput(param, label = param, value = 1, min = 0))
      )
    })

    do.call(tagList, input_ui)
  })

  observeEvent(input$run_btn, {
    req(input$selected_function)

    function_inputs <- function_metadata[[input$selected_function]]$inputs
    args <- list()

    for (param in names(function_inputs)) {
      input_type <- function_inputs[[param]]

      if (input_type == "studyid") {
        args[[param]] <- input[[param]]
      } else if (input_type == "path_db") {
        args[[param]] <- input[[param]]
      } else if (input_type == "null_or_file") {
        source_input <- input[[paste0(param, "_source")]]
        if (source_input == "null") {
          args[[param]] <- NULL
        } else {
          uploaded_file <- input[[paste0(param, "_file")]]
          args[[param]] <- if (!is.null(uploaded_file)) uploaded_file$datapath else NULL
        }
      } else if (input_type == "file") {
        uploaded_file <- input[[param]]
        args[[param]] <- if (!is.null(uploaded_file)) uploaded_file$datapath else NULL
      } else if (input_type == "checkbox") {
        args[[param]] <- input[[param]]
      } else if (input_type == "numeric") {
        args[[param]] <- input[[param]]
      }
    }

    result <- tryCatch({
      do.call(get(input$selected_function, envir = asNamespace("SENDQSAR")), args)
    }, error = function(e) {
      paste("Error:", e$message)
    })

    output$result <- renderPrint({ result })
  })

  output$ml_plot <- renderPlot({
    if (input$selected_function == "get_rf_model_with_cv") {
      tryCatch({
        auc_plot <- get_auc_curve_with_rf_model(output$result())
        print(auc_plot)
      }, error = function(e) {
        plot(0, 0, main = "No Plot Available", type = "n")
        text(0, 0, "Error: Unable to generate plot")
      })
    }
  })
}

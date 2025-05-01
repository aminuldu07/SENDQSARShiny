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

ui <- dashboardPage(
  dashboardHeader(title = "SENDQSAR App"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Function Execution", tabName = "execution", icon = icon("play")),
      menuItem("ML Workflow", tabName = "ml_workflow", icon = icon("chart-line"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "execution",
              fluidRow(
                box(title = "Select Function", width = 4, status = "primary",
                    selectInput("selected_function", "Choose a function:", choices = names(function_metadata)),
                    uiOutput("dynamic_inputs"),
                    actionButton("run_btn", "Run Function")
                ),
                box(title = "Results", width = 8, status = "success",
                    verbatimTextOutput("result")
                )
              )
      ),
      tabItem(tabName = "ml_workflow",
              fluidRow(
                box(title = "ML Model Visualization", width = 12, status = "info",
                    plotOutput("ml_plot")
                )
              )
      )
    )
  )
)


## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, eval=FALSE--------------------------------------------------------
# library(shiny)
# library(shiny.telemetry)
# 
# # Initialize telemetry
# telemetry <- Telemetry$new()
# 
# ui <- fluidPage(
#   use_telemetry(), # Add telemetry JavaScript
# 
#   titlePanel("Sales Dashboard"),
#   sidebarLayout(
#     sidebarPanel(
#       selectInput(
#         "region",
#         "Region:",
#         choices = c("North", "South", "East", "West")
#       ),
#       dateRangeInput("date_range", "Date Range:"),
#       selectInput(
#         "product_category",
#         "Product Category:",
#         choices = c("All", "Electronics", "Clothing", "Food")
#       ),
#       actionButton("refresh", "Refresh Data")
#     ),
#     mainPanel(
#       tabsetPanel(
#         tabPanel("Overview", plotOutput("overview_plot")),
#         tabPanel("Details", dataTableOutput("details_table")),
#         tabPanel("Settings", uiOutput("settings_ui"))
#       )
#     )
#   )
# )
# 
# server <- function(input, output, session) {
#   # Start telemetry tracking
#   telemetry$start_session()
# 
#   # Your app logic here...
# }
# 
# shinyApp(ui, server)

## ----basic_usage, eval=FALSE--------------------------------------------------
# library(bidux)
# 
# # Analyze telemetry from SQLite database (default)
# issues <- bid_ingest_telemetry("telemetry.sqlite")
# 
# # Or from JSON log file
# issues <- bid_ingest_telemetry("telemetry.log", format = "json")
# 
# # Review identified issues
# length(issues)
# names(issues)

## ----unused_inputs, eval=FALSE------------------------------------------------
# # Example: Region filter is never used
# issues$unused_input_region
# #> BID Framework - Notice Stage
# #> Problem: Users are not interacting with the 'region' input control
# #> Theory: Hick's Law (auto-suggested)
# #> Evidence: Telemetry shows 0 out of 847 sessions where 'region' was changed

## ----delayed_interaction, eval=FALSE------------------------------------------
# issues$delayed_interaction
# #> BID Framework - Notice Stage
# #> Problem: Users take a long time before making their first interaction with the dashboard
# #> Theory: Information Scent (auto-suggested)
# #> Evidence: Median time to first input is 45 seconds, and 10% of sessions had no interactions at all

## ----error_patterns, eval=FALSE-----------------------------------------------
# issues$error_1
# #> BID Framework - Notice Stage
# #> Problem: Users encounter errors when using the dashboard
# #> Theory: Norman's Gulf of Evaluation (auto-suggested)
# #> Evidence: Error 'Data query failed' occurred 127 times in 15.0% of sessions (in output 'overview_plot'), often after changing 'date_range'

## ----navigation_dropoff, eval=FALSE-------------------------------------------
# issues$navigation_settings_tab
# #> BID Framework - Notice Stage
# #> Problem: The 'settings_tab' page/tab is rarely visited by users
# #> Theory: Information Architecture (auto-suggested)
# #> Evidence: Only 42 sessions (5.0%) visited 'settings_tab', and 90% of those sessions ended there

## ----confusion_pattern, eval=FALSE--------------------------------------------
# issues$confusion_date_range
# #> BID Framework - Notice Stage
# #> Problem: Users show signs of confusion when interacting with 'date_range'
# #> Theory: Feedback Loops (auto-suggested)
# #> Evidence: 8 sessions showed rapid repeated changes (avg 6 changes in 7.5 seconds), suggesting users are unsure about the input's behavior

## ----custom_thresholds, eval=FALSE--------------------------------------------
# issues <- bid_ingest_telemetry(
#   "telemetry.sqlite",
#   thresholds = list(
#     unused_input_threshold = 0.1, # Flag if <10% of sessions use input
#     delay_threshold_seconds = 60, # Flag if >60s before first interaction
#     error_rate_threshold = 0.05, # Flag if >5% of sessions have errors
#     navigation_threshold = 0.3, # Flag if <30% visit a page
#     rapid_change_window = 5, # Look for 5 changes within...
#     rapid_change_count = 3 # ...3 seconds
#   )
# )

## ----bid_workflow, eval=FALSE-------------------------------------------------
# # Take the most critical issue
# critical_issue <- issues$error_1
# 
# # Start with interpretation
# interpret_result <- bid_interpret(
#   central_question = "How can we prevent data query errors?",
#   data_story = list(
#     hook = "15% of users encounter errors",
#     context = "Errors occur after date range changes",
#     tension = "Users lose trust when queries fail",
#     resolution = "Implement robust error handling and loading states"
#   )
# )
# 
# # Notice the specific problem
# notice_result <- bid_notice(
#   previous_stage = interpret_result,
#   problem = critical_issue$problem,
#   evidence = critical_issue$evidence
# )
# 
# # Anticipate user behavior and biases
# anticipate_result <- bid_anticipate(
#   previous_stage = notice_result,
#   bias_mitigations = list(
#     anchoring = "Show loading states to set proper expectations",
#     confirmation_bias = "Display error context to help users understand issues"
#   )
# )
# 
# # Structure improvements
# structure_result <- bid_structure(
#   previous_stage = anticipate_result
# )
# 
# # Validate and provide next steps
# validate_result <- bid_validate(
#   previous_stage = structure_result,
#   summary_panel = "Error handling improvements with clear user feedback",
#   next_steps = c(
#     "Implement loading states",
#     "Add error context",
#     "Test with users"
#   )
# )

## ----complete_example, eval=FALSE---------------------------------------------
# # 1. Ingest telemetry
# issues <- bid_ingest_telemetry("telemetry.sqlite")
# 
# # 2. Prioritize issues by impact
# critical_issues <- list(
#   unused_inputs = names(issues)[grepl("unused_input", names(issues))],
#   errors = names(issues)[grepl("error", names(issues))],
#   delays = "delayed_interaction" %in% names(issues)
# )
# 
# # 3. Create a comprehensive improvement plan
# if (length(critical_issues$unused_inputs) > 0) {
#   # Address unused inputs following the updated BID workflow
#   unused_issue <- issues[[critical_issues$unused_inputs[1]]]
# 
#   improvement_plan <- bid_interpret(
#     central_question = "Which filters actually help users find insights?",
#     data_story = list(
#       hook = "Several filters are never used by users",
#       context = "Dashboard has 5 filter controls",
#       tension = "Too many options create choice overload",
#       resolution = "Show only relevant filters based on user tasks"
#     )
#   ) |>
#     bid_notice(
#       problem = unused_issue$problem,
#       evidence = unused_issue$evidence
#     ) |>
#     bid_anticipate(
#       bias_mitigations = list(
#         choice_overload = "Hide advanced filters until needed",
#         default_effect = "Pre-select most common filter values"
#       )
#     ) |>
#     bid_structure() |>
#     bid_validate(
#       summary_panel = "Simplified filtering with progressive disclosure",
#       next_steps = c(
#         "Remove unused filters",
#         "Implement progressive disclosure",
#         "Add contextual help",
#         "Re-test with telemetry after changes"
#       )
#     )
# }
# 
# # 4. Generate report
# improvement_report <- bid_report(improvement_plan, format = "html")

## ----verify_improvements, eval=FALSE------------------------------------------
# # Before changes
# issues_before <- bid_ingest_telemetry("telemetry_before.sqlite")
# 
# # After implementing improvements
# issues_after <- bid_ingest_telemetry("telemetry_after.sqlite")
# 
# # Compare issue counts
# cat("Issues before:", length(issues_before), "\n")
# cat("Issues after:", length(issues_after), "\n")

## ----document_patterns, eval=FALSE--------------------------------------------
# # Save recurring patterns for future reference
# telemetry_patterns <- list(
#   date_filter_confusion = "Users often struggle with date range inputs - consider using presets",
#   tab_discovery = "Secondary tabs have low discovery - consider better visual hierarchy",
#   error_recovery = "Users abandon after errors - implement graceful error handling"
# )


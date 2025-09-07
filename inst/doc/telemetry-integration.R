## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----modern_api, eval=FALSE---------------------------------------------------
# library(bidux)
# library(dplyr)
# 
# # Modern approach: get tidy issues tibble
# issues <- bid_telemetry("telemetry.sqlite")
# print(issues)  # Shows organized issue summary
# 
# # Triage critical issues
# critical <- issues |>
#   filter(severity == "critical") |>
#   slice_head(n = 3)
# 
# # Convert to Notice stages with bridge functions
# notices <- bid_notices(
#   issues = critical,
#   previous_stage = interpret_result
# )
# 
# # Extract telemetry flags for layout optimization
# flags <- bid_flags(issues)
# structure_result <- bid_structure(
#   previous_stage = anticipate_result,
#   telemetry_flags = flags
# )

## ----legacy_compat, eval=FALSE------------------------------------------------
# # Legacy approach still works exactly as before
# legacy_notices <- bid_ingest_telemetry("telemetry.sqlite")
# length(legacy_notices)  # Behaves like list of Notice stages
# legacy_notices[[1]]     # Access individual Notice objects
# 
# # But now also provides enhanced functionality
# as_tibble(legacy_notices)  # Get tidy issues view
# bid_flags(legacy_notices)  # Extract global telemetry flags

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

## ----bridge_individual, eval=FALSE--------------------------------------------
# # Process a single high-priority issue
# priority_issue <- issues |>
#   filter(severity == "critical") |>
#   slice_head(n = 1)
# 
# # Create Notice directly from issue
# notice_result <- bid_notice_issue(
#   issue = priority_issue,
#   previous_stage = interpret_result,
#   override = list(
#     problem = "Custom problem description if needed"
#   )
# )
# 
# # Sugar function for quick addressing
# notice_sugar <- bid_address(
#   issue = priority_issue,
#   previous_stage = interpret_result
# )

## ----bridge_batch, eval=FALSE-------------------------------------------------
# # Process multiple issues at once
# high_priority <- issues |>
#   filter(severity %in% c("critical", "high"))
# 
# # Convert all to Notice stages
# notice_list <- bid_notices(
#   issues = high_priority,
#   previous_stage = interpret_result,
#   filter = function(x) x$severity == "critical"  # Additional filtering
# )
# 
# # Pipeline approach - process first N issues
# pipeline_notices <- bid_pipeline(
#   issues = high_priority,
#   previous_stage = interpret_result,
#   max = 3  # Limit to 3 most critical issues
# )

## ----telemetry_structure, eval=FALSE------------------------------------------
# # Extract global flags from telemetry data
# flags <- bid_flags(issues)
# #> List includes: has_navigation_issues, high_error_rate, user_confusion_patterns
# 
# # Use flags to inform layout selection
# structure_result <- bid_structure(
#   previous_stage = anticipate_result,
#   telemetry_flags = flags  # Influences layout choice and suggestion scoring
# )
# 
# # The layout selection will avoid problematic patterns based on your data
# # e.g., if flags$has_navigation_issues == TRUE, tabs layout gets lower priority

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

## ----telemetry-diagnosis, eval=FALSE------------------------------------------
# # Analyze 3 months of user behavior data
# issues <- bid_telemetry("ecommerce_dashboard_telemetry.sqlite")
# 
# # Review the systematic analysis
# print(issues)
# #> # BID Telemetry Issues: 8 issues identified
# #> # Severity breakdown: 2 critical, 3 high, 2 medium, 1 low
# #> #
# #> # Critical Issues:
# #> # 1. delayed_interaction: Users take 47 seconds before first interaction
# #> # 2. unused_input_advanced_filters: Only 3% of users interact with advanced filter panel
# #> #
# #> # High Priority Issues:
# #> # 3. error_data_loading: 23% of sessions encounter "Data query failed" error
# #> # 4. navigation_settings_tab: Only 8% visit settings, 85% of those sessions end there
# #> # 5. confusion_date_range: Rapid repeated changes suggest user confusion
# 
# # Examine the most critical issue in detail
# critical_issue <- issues |>
#   filter(severity == "critical") |>
#   slice_head(n = 1)
# 
# print(critical_issue$evidence)
# #> "Median time to first input is 47 seconds, and 12% of sessions had no interactions at all.
# #>  This suggests users are overwhelmed by the initial interface or unclear about where to start."

## ----ecommerce-bid-analysis, eval=FALSE---------------------------------------
# # Start with interpretation of the business context
# interpret_stage <- bid_interpret(
#   central_question = "How can we make e-commerce insights more accessible to busy stakeholders?",
#   data_story = list(
#     hook = "Business teams struggle to get quick insights from our analytics dashboard",
#     context = "Stakeholders have 10-15 minutes between meetings to check performance",
#     tension = "Current interface requires 47+ seconds just to orient and start using",
#     resolution = "Provide immediate value with progressive disclosure for deeper analysis"
#   ),
#   user_personas = list(
#     list(
#       name = "Marketing Manager",
#       goals = "Quick campaign performance insights",
#       pain_points = "Too much information, unclear where to start",
#       technical_level = "Intermediate"
#     ),
#     list(
#       name = "Executive",
#       goals = "High-level business health check",
#       pain_points = "Gets lost in technical details",
#       technical_level = "Basic"
#     )
#   )
# )
# 
# # Convert telemetry issues to BID Notice stages using bridge functions
# notice_stages <- bid_notices(
#   issues = critical_issue,
#   previous_stage = interpret_stage
# )
# 
# # Apply behavioral science to anticipate user behavior
# anticipate_stage <- bid_anticipate(
#   previous_stage = notice_stages[[1]],
#   bias_mitigations = list(
#     choice_overload = "Reduce initial options, use progressive disclosure",
#     attention_bias = "Use visual hierarchy to guide user focus",
#     anchoring = "Lead with most important business metric"
#   )
# )
# 
# # Use telemetry flags to inform structure decisions
# flags <- bid_flags(issues)
# structure_stage <- bid_structure(
#   previous_stage = anticipate_stage,
#   telemetry_flags = flags  # This influences layout selection
# )
# 
# # Define success criteria and validation approach
# validate_stage <- bid_validate(
#   previous_stage = structure_stage,
#   summary_panel = "Executive summary with key insights and trend indicators",
#   collaboration = "Enable stakeholders to share insights and add context",
#   next_steps = c(
#     "Implement simplified landing page with key metrics",
#     "Add progressive disclosure for detailed analytics",
#     "Create role-based views for different user types",
#     "Set up telemetry tracking to measure improvement"
#   )
# )

## ----ecommerce-improvements, eval=FALSE---------------------------------------
# # Before: Information overload (what telemetry revealed users struggled with)
# ui_before <- dashboardPage(
#   dashboardHeader(title = "E-commerce Analytics"),
#   dashboardSidebar(
#     # 15+ filter options immediately visible
#     selectInput("date_range", "Date Range", choices = date_options),
#     selectInput("product_category", "Category", choices = categories, multiple = TRUE),
#     selectInput("channel", "Sales Channel", choices = channels, multiple = TRUE),
#     selectInput("region", "Region", choices = regions, multiple = TRUE),
#     selectInput("customer_segment", "Customer Type", choices = segments, multiple = TRUE),
#     # ... 10 more filters
#     actionButton("apply_filters", "Apply Filters")
#   ),
#   dashboardBody(
#     # 12 value boxes competing for attention
#     fluidRow(
#       valueBoxOutput("revenue"), valueBoxOutput("orders"),
#       valueBoxOutput("aov"), valueBoxOutput("conversion"),
#       valueBoxOutput("traffic"), valueBoxOutput("bounce_rate"),
#       # ... 6 more value boxes
#     ),
#     # Multiple complex charts
#     fluidRow(
#       plotOutput("revenue_trend"), plotOutput("category_performance"),
#       plotOutput("channel_analysis"), plotOutput("customer_segments")
#     )
#   )
# )
# 
# # After: BID-informed design addressing telemetry insights
# ui_after <- page_fillable(
#   theme = bs_theme(version = 5, preset = "bootstrap"),
# 
#   # Address delayed interaction issue: Immediate value on landing
#   layout_columns(
#     col_widths = c(8, 4),
# 
#     # Primary business health (addresses anchoring bias)
#     card(
#       card_header("🎯 Business Performance", class = "bg-primary text-white"),
#       layout_columns(
#         col_widths = c(6, 6),
#         value_box(
#           "Revenue Today",
#           "$47.2K",
#           "vs. $43.1K yesterday (+9.5%)",
#           showcase = bs_icon("graph-up"),
#           theme = "success"
#         ),
#         div(
#           h5("Key Insights", style = "margin-bottom: 15px;"),
#           tags$ul(
#             tags$li("Mobile traffic up 15%"),
#             tags$li("Electronics category leading"),
#             tags$li("⚠️ Cart abandonment rate increased")
#           ),
#           actionButton("investigate_abandonment", "Investigate",
#                       class = "btn btn-warning btn-sm")
#         )
#       )
#     ),
# 
#     # Quick actions (addresses choice overload)
#     card(
#       card_header("⚡ Quick Actions"),
#       div(
#         actionButton(
#           "todays_performance",
#           "Today's Performance",
#           class = "btn btn-primary btn-block mb-2"
#         ),
#         actionButton(
#           "weekly_trends",
#           "Weekly Trends",
#           class = "btn btn-secondary btn-block mb-2"
#         ),
#         actionButton(
#           "campaign_results",
#           "Campaign Results",
#           class = "btn btn-info btn-block mb-2"
#         ),
#         hr(),
#         p(
#           "Need something specific?",
#           style = "font-size: 0.9em; color: #666;"
#         ),
#         actionButton(
#           "show_filters",
#           "Custom Analysis",
#           class = "btn btn-outline-secondary btn-sm"
#         )
#       )
#     )
#   ),
# 
#   # Advanced options hidden by default (progressive disclosure)
#   conditionalPanel(
#     condition = "input.show_filters",
#     card(
#       card_header("🔍 Custom Analysis"),
#       p("Filter and explore your data:", style = "margin-bottom: 15px;"),
#       layout_columns(
#         col_widths = c(3, 3, 3, 3),
#         selectInput(
#           "time_period",
#           "Time Period",
#           choices = c("Today", "This Week", "This Month"),
#           selected = "Today"
#         ),
#         selectInput(
#           "focus_area",
#           "Focus Area",
#           choices = c("Revenue", "Traffic", "Conversions", "Customers")
#         ),
#         selectInput(
#           "comparison",
#           "Compare To",
#           choices = c("Previous Period", "Same Period Last Year", "Target")
#         ),
#         actionButton("apply_custom", "Analyze", class = "btn btn-primary")
#       )
#     )
#   ),
# 
#   # Results area appears based on user choices
#   div(id = "results_area", style = "margin-top: 20px;")
# )

## ----measure-impact, eval=FALSE-----------------------------------------------
# # After implementing changes, collect new telemetry data
# issues_after <- bid_telemetry(
#   "ecommerce_dashboard_telemetry_after_changes.sqlite"
# )
# 
# # Compare before/after metrics
# improvement_metrics <- tibble(
#   metric = c(
#     "Time to first interaction",
#     "Session abandonment rate",
#     "User satisfaction score",
#     "Task completion rate"
#   ),
#   before = c("47 seconds", "12%", "6.2/10", "68%"),
#   after = c("8 seconds", "3%", "8.1/10", "87%"),
#   improvement = c("-83%", "-75%", "+31%", "+28%")
# )
# 
# print(improvement_metrics)

## ----complete_example, eval=FALSE---------------------------------------------
# # 1. Modern telemetry ingestion
# issues <- bid_telemetry("telemetry.sqlite")
# 
# # 2. Triage issues using tidy workflow
# print(issues)  # Review issue summary
# 
# # Focus on critical issues
# critical_issues <- issues |>
#   filter(severity == "critical") |>
#   arrange(desc(user_impact))
# 
# # 3. Create a comprehensive improvement plan using bridge functions
# if (nrow(critical_issues) > 0) {
#   # Address top critical issue
#   top_issue <- critical_issues |> slice_head(n = 1)
# 
#   # Start BID workflow
#   interpret_stage <- bid_interpret(
#     central_question = "How can we address the most critical UX issue?",
#     data_story = list(
#       hook = "Critical issues identified from user behavior data",
#       context = "Telemetry reveals specific friction points",
#       tension = "Users struggling with core functionality",
#       resolution = "Data-driven improvements to user experience"
#     )
#   )
# 
#   # Use bridge function to convert issue to Notice
#   notice_stage <- bid_notice_issue(
#     issue = top_issue,
#     previous_stage = interpret_stage
#   )
# 
#   improvement_plan <- notice_stage |>
#     bid_anticipate(
#       bias_mitigations = list(
#         choice_overload = "Hide advanced filters until needed",
#         default_effect = "Pre-select most common filter values"
#       )
#     ) |>
#     bid_structure(telemetry_flags = bid_flags(issues)) |>
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


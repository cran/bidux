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
# 
# # Print method shows prioritized triage view
# print(issues)
# #> # BID Telemetry Issues Summary
# #> Found 8 issues from 847 sessions
# #> Critical: 2 issues
# #> High: 3 issues
# #> Medium: 2 issues
# #> Low: 1 issue
# 
# # Use tidy data operations for filtering
# critical <- issues |>
#   filter(severity == "critical") |>
#   arrange(desc(impact_rate))
# 
# # Access as regular tibble columns
# high_impact <- issues |>
#   filter(impact_rate > 0.2) |>
#   select(issue_id, issue_type, severity, problem)

## ----legacy_compat, eval=FALSE------------------------------------------------
# # Legacy approach returns hybrid object
# legacy_result <- bid_ingest_telemetry("telemetry.sqlite")
# 
# # 1. LEGACY LIST INTERFACE (backward compatible)
# length(legacy_result) # Number of issues as named list
# names(legacy_result) # Issue IDs: "unused_input_region", "error_1", etc.
# legacy_result[[1]] # Access individual bid_stage Notice objects
# legacy_result$unused_input_region # Access by name
# 
# # 2. ENHANCED TIBBLE INTERFACE (new in 0.3.1)
# as_tibble(legacy_result) # Convert to tidy tibble view
# print(legacy_result) # Pretty-printed triage summary
# 
# # 3. FLAGS EXTRACTION (new in 0.3.1)
# flags <- bid_flags(legacy_result) # Extract global telemetry flags
# flags$has_critical_issues # Boolean flag
# flags$has_navigation_issues # Boolean flag
# flags$session_count # Integer metadata

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
# # Modern approach: returns tibble
# issues <- bid_telemetry("telemetry.sqlite")
# 
# # Legacy approach: returns hybrid object
# issues_legacy <- bid_ingest_telemetry("telemetry.sqlite")
# 
# # Or from JSON log file (both functions support this)
# issues <- bid_telemetry("telemetry.log", format = "json")
# 
# # Review identified issues
# nrow(issues) # Modern: tibble row count
# print(issues) # Both show formatted triage summary

## ----presets_overview, eval=FALSE---------------------------------------------
# # Get preset configurations
# strict_thresholds <- bid_telemetry_presets("strict")
# moderate_thresholds <- bid_telemetry_presets("moderate")
# relaxed_thresholds <- bid_telemetry_presets("relaxed")
# 
# # View what each preset contains
# str(strict_thresholds)
# #> List of 6
# #>  $ unused_input_threshold: num 0.02
# #>  $ delay_threshold_secs  : num 20
# #>  $ error_rate_threshold  : num 0.05
# #>  $ navigation_threshold  : num 0.1
# #>  $ rapid_change_window   : num 15
# #>  $ rapid_change_count    : num 4

## ----preset_strict, eval=FALSE------------------------------------------------
# # Strict preset detects issues early
# strict_issues <- bid_telemetry(
#   "telemetry.sqlite",
#   thresholds = bid_telemetry_presets("strict")
# )
# 
# # What makes it strict:
# # - Flags inputs used by < 2% of sessions (vs 5% moderate)
# # - Flags delays > 20 seconds (vs 30 seconds moderate)
# # - Flags errors in > 5% of sessions (vs 10% moderate)
# # - Flags pages visited by < 10% (vs 20% moderate)
# # - More sensitive to confusion patterns (4 changes in 15s vs 5 in 10s)

## ----preset_moderate, eval=FALSE----------------------------------------------
# # Moderate preset is the default
# moderate_issues <- bid_telemetry("telemetry.sqlite")
# 
# # Or explicitly specify it
# moderate_issues <- bid_telemetry(
#   "telemetry.sqlite",
#   thresholds = bid_telemetry_presets("moderate")
# )
# 
# # Balanced thresholds:
# # - Flags inputs used by < 5% of sessions
# # - Flags delays > 30 seconds
# # - Flags errors in > 10% of sessions
# # - Flags pages visited by < 20%
# # - Standard confusion detection (5 changes in 10s)

## ----preset_relaxed, eval=FALSE-----------------------------------------------
# # Relaxed preset for mature applications
# relaxed_issues <- bid_telemetry(
#   "telemetry.sqlite",
#   thresholds = bid_telemetry_presets("relaxed")
# )
# 
# # Only flags major issues:
# # - Flags inputs used by < 10% of sessions (vs 5% moderate)
# # - Flags delays > 60 seconds (vs 30 seconds moderate)
# # - Flags errors in > 20% of sessions (vs 10% moderate)
# # - Flags pages visited by < 30% (vs 20% moderate)
# # - Less sensitive to confusion (7 changes in 5s vs 5 in 10s)

## ----custom_thresholds, eval=FALSE--------------------------------------------
# # Start with moderate preset but customize specific thresholds
# custom_issues <- bid_telemetry(
#   "telemetry.sqlite",
#   thresholds = c(
#     bid_telemetry_presets("moderate"),
#     list(
#       unused_input_threshold = 0.03, # Override: flag if < 3% use
#       error_rate_threshold = 0.15 # Override: flag if > 15% errors
#     )
#   )
# )
# 
# # Or build completely custom thresholds
# fully_custom <- bid_telemetry(
#   "telemetry.sqlite",
#   thresholds = list(
#     unused_input_threshold = 0.1, # Flag if <10% of sessions use input
#     delay_threshold_secs = 60, # Flag if >60s before first interaction
#     error_rate_threshold = 0.05, # Flag if >5% of sessions have errors
#     navigation_threshold = 0.3, # Flag if <30% visit a page
#     rapid_change_window = 5, # Look for changes within 5 seconds
#     rapid_change_count = 3 # Flag if 3+ changes in window
#   )
# )

## ----preset_comparison, eval=FALSE--------------------------------------------
# # Analyze same data with all three presets
# strict <- bid_telemetry("telemetry.sqlite",
#   thresholds = bid_telemetry_presets("strict")
# )
# moderate <- bid_telemetry("telemetry.sqlite",
#   thresholds = bid_telemetry_presets("moderate")
# )
# relaxed <- bid_telemetry("telemetry.sqlite",
#   thresholds = bid_telemetry_presets("relaxed")
# )
# 
# # Compare issue counts
# comparison <- data.frame(
#   preset = c("Strict", "Moderate", "Relaxed"),
#   issues_found = c(nrow(strict), nrow(moderate), nrow(relaxed)),
#   critical = c(
#     sum(strict$severity == "critical"),
#     sum(moderate$severity == "critical"),
#     sum(relaxed$severity == "critical")
#   )
# )
# 
# print(comparison)
# #>     preset issues_found critical
# #> 1   Strict           12        3
# #> 2 Moderate            8        2
# #> 3  Relaxed            4        1

## ----unused_inputs_example, eval=FALSE----------------------------------------
# # Using modern API
# issues <- bid_telemetry("telemetry.sqlite")
# 
# # Filter for unused input issues
# unused <- issues |> filter(issue_type == "unused_input")
# 
# # Example issue details
# unused[1, ]
# #> issue_id: unused_input_region
# #> severity: high
# #> problem: Users are not interacting with the 'region' input control
# #> evidence: Only 25 out of 847 sessions (3.0%) interacted with 'region'
# #> affected_sessions: 822
# #> impact_rate: 0.97

## ----delayed_interaction_example, eval=FALSE----------------------------------
# issues <- bid_telemetry("telemetry.sqlite")
# 
# delayed <- issues |> filter(issue_type == "delayed_interaction")
# 
# delayed[1, ]
# #> issue_id: delayed_interaction
# #> severity: critical
# #> problem: Users take a long time before making their first interaction
# #> evidence: Median time to first input is 47 seconds, and 12% had no interactions
# #> affected_sessions: 254
# #> impact_rate: 0.30

## ----error_patterns_example, eval=FALSE---------------------------------------
# issues <- bid_telemetry("telemetry.sqlite")
# 
# errors <- issues |> filter(issue_type == "error_pattern")
# 
# errors[1, ]
# #> issue_id: error_1
# #> severity: high
# #> problem: Users encounter errors when using the dashboard
# #> evidence: Error 'Data query failed' occurred 127 times in 15.0% of sessions
# #> affected_sessions: 127
# #> impact_rate: 0.15

## ----navigation_dropoff_example, eval=FALSE-----------------------------------
# issues <- bid_telemetry("telemetry.sqlite")
# 
# nav_issues <- issues |> filter(issue_type == "navigation_dropoff")
# 
# nav_issues[1, ]
# #> issue_id: navigation_settings_tab
# #> severity: medium
# #> problem: The 'settings_tab' page/tab is rarely visited by users
# #> evidence: Only 42 sessions (5.0%) visited 'settings_tab'
# #> affected_sessions: 805
# #> impact_rate: 0.95

## ----confusion_pattern_example, eval=FALSE------------------------------------
# issues <- bid_telemetry("telemetry.sqlite")
# 
# confusion <- issues |> filter(issue_type == "confusion_pattern")
# 
# confusion[1, ]
# #> issue_id: confusion_date_range
# #> severity: medium
# #> problem: Users show signs of confusion when interacting with 'date_range'
# #> evidence: 8 sessions showed rapid repeated changes (avg 6 changes in 7.5s)
# #> affected_sessions: 8
# #> impact_rate: 0.01

## ----bridge_individual, eval=FALSE--------------------------------------------
# # Get telemetry issues
# issues <- bid_telemetry("telemetry.sqlite")
# 
# # Create interpret stage
# interpret_result <- bid_interpret(
#   central_question = "How can we reduce user friction?"
# )
# 
# # Convert highest impact issue to Notice
# priority_issue <- issues |>
#   filter(severity == "critical") |>
#   arrange(desc(impact_rate)) |>
#   slice_head(n = 1)
# 
# notice_result <- bid_notice_issue(
#   issue = priority_issue,
#   previous_stage = interpret_result
# )
# 
# # The Notice stage now contains the telemetry problem and evidence
# print(notice_result)
# 
# # Optional: Override specific fields
# notice_custom <- bid_notice_issue(
#   issue = priority_issue,
#   previous_stage = interpret_result,
#   override = list(
#     problem = "Custom problem description based on deeper analysis"
#   )
# )

## ----bridge_batch, eval=FALSE-------------------------------------------------
# # Get high-priority issues
# issues <- bid_telemetry("telemetry.sqlite")
# high_priority <- issues |> filter(severity %in% c("critical", "high"))
# 
# interpret_result <- bid_interpret(
#   central_question = "How can we systematically address UX issues?"
# )
# 
# # Convert all high-priority issues to Notice stages
# notice_list <- bid_notices(
#   issues = high_priority,
#   previous_stage = interpret_result,
#   max_issues = 3 # Limit to top 3 issues
# )
# 
# # Result is a named list of bid_stage objects
# length(notice_list) # Number of Notice stages created
# notice_list[[1]] # Access individual Notice stage
# 
# # Continue BID workflow with first issue
# anticipate_result <- bid_anticipate(
#   previous_stage = notice_list[[1]],
#   bias_mitigations = list(
#     choice_overload = "Simplify interface",
#     anchoring = "Set appropriate defaults"
#   )
# )

## ----bridge_sugar, eval=FALSE-------------------------------------------------
# # Quick single-issue addressing
# issues <- bid_telemetry("telemetry.sqlite")
# interpret <- bid_interpret("How can we improve user experience?")
# 
# # Address the highest impact issue
# top_issue <- issues[which.max(issues$impact_rate), ]
# notice <- bid_address(top_issue, interpret)
# 
# # Equivalent to bid_notice_issue()
# # but more concise for quick workflows

## ----bridge_pipeline, eval=FALSE----------------------------------------------
# issues <- bid_telemetry("telemetry.sqlite")
# interpret <- bid_interpret("How can we systematically improve UX?")
# 
# # Create pipeline for top 3 issues (sorted by severity then impact)
# notice_pipeline <- bid_pipeline(issues, interpret, max = 3)
# 
# # Process each issue through the BID framework
# for (i in seq_along(notice_pipeline)) {
#   cli::cli_h2("Addressing Issue {i}")
# 
#   notice <- notice_pipeline[[i]]
# 
#   anticipate <- bid_anticipate(
#     previous_stage = notice,
#     bias_mitigations = list(
#       confirmation_bias = "Show contradicting data",
#       anchoring = "Provide context"
#     )
#   )
# 
#   structure <- bid_structure(previous_stage = anticipate)
# 
#   validate <- bid_validate(
#     previous_stage = structure,
#     next_steps = c("Implement changes", "Collect new telemetry")
#   )
# }

## ----telemetry_flags, eval=FALSE----------------------------------------------
# # Analyze telemetry
# issues <- bid_telemetry("telemetry.sqlite")
# 
# # Extract flags
# flags <- bid_flags(issues)
# 
# # Available flags:
# str(flags)
# #> List of 11
# #>  $ has_issues             : logi TRUE
# #>  $ has_critical_issues    : logi TRUE
# #>  $ has_input_issues       : logi TRUE
# #>  $ has_navigation_issues  : logi TRUE
# #>  $ has_error_patterns     : logi TRUE
# #>  $ has_confusion_patterns : logi FALSE
# #>  $ has_delay_issues       : logi TRUE
# #>  $ session_count          : int 847
# #>  $ analysis_timestamp     : POSIXct
# #>  $ unused_input_threshold : num 0.05
# #>  $ delay_threshold_seconds: num 30
# 
# # Use flags to inform BID workflow
# if (flags$has_navigation_issues) {
#   cli::cli_alert_warning("Navigation issues detected - avoid tab-heavy layouts")
# }
# 
# # Pass flags to structure stage
# structure_result <- bid_structure(
#   previous_stage = anticipate_result,
#   telemetry_flags = flags # Influences layout selection and suggestions
# )
# 
# # Flags also work with legacy hybrid objects
# legacy_result <- bid_ingest_telemetry("telemetry.sqlite")
# legacy_flags <- bid_flags(legacy_result) # Same flags interface

## ----hybrid_demo, eval=FALSE--------------------------------------------------
# # Create hybrid object
# hybrid <- bid_ingest_telemetry("telemetry.sqlite")
# 
# # INTERFACE 1: Legacy List (backward compatible)
# # - Behaves exactly like pre-0.3.1 versions
# class(hybrid)
# #> [1] "bid_issues" "list"
# 
# length(hybrid) # Number of issues
# #> [1] 8
# 
# names(hybrid) # Issue IDs
# #> [1] "unused_input_region"      "delayed_interaction"
# #> [3] "error_1"                  "navigation_settings_tab"
# 
# hybrid[[1]] # First issue as bid_stage object
# #> BID Framework - Notice Stage
# #> Problem: Users are not interacting with the 'region' input control
# #> Evidence: Only 25 out of 847 sessions (3.0%) interacted with 'region'
# 
# hybrid$error_1 # Access by name
# #> BID Framework - Notice Stage
# #> Problem: Users encounter errors when using the dashboard
# 
# # INTERFACE 2: Tibble View (enhanced in 0.3.1)
# # - Convert to tibble for tidy operations
# issues_tbl <- as_tibble(hybrid)
# class(issues_tbl)
# #> [1] "tbl_df"     "tbl"        "data.frame"
# 
# nrow(issues_tbl) # Same count as length(hybrid)
# #> [1] 8
# 
# # Filter and manipulate as tibble
# critical <- issues_tbl |> filter(severity == "critical")
# 
# # INTERFACE 3: Flags Extraction
# flags <- bid_flags(hybrid)
# flags$has_critical_issues
# #> [1] TRUE
# 
# # INTERFACE 4: Pretty Printing
# print(hybrid)
# #> # BID Telemetry Issues Summary
# #> Found 8 issues from 847 sessions
# #> Critical: 2 issues
# #> High: 3 issues
# #> ...
# 
# # All interfaces work on the same object!

## ----bid_workflow, eval=FALSE-------------------------------------------------
# # Analyze telemetry
# issues <- bid_telemetry("telemetry.sqlite")
# 
# # Get top critical issue
# critical_issue <- issues |>
#   filter(severity == "critical") |>
#   slice_head(n = 1)
# 
# # Start BID workflow
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
# # Convert telemetry issue to Notice stage
# notice_result <- bid_notice_issue(
#   issue = critical_issue,
#   previous_stage = interpret_result
# )
# 
# # Or use the problem/evidence directly
# notice_result_manual <- bid_notice(
#   previous_stage = interpret_result,
#   problem = critical_issue$problem,
#   evidence = critical_issue$evidence
# )
# 
# # Continue through BID stages
# anticipate_result <- bid_anticipate(
#   previous_stage = notice_result,
#   bias_mitigations = list(
#     anchoring = "Show loading states to set proper expectations",
#     confirmation_bias = "Display error context to help users understand issues"
#   )
# )
# 
# # Extract flags for structure decisions
# flags <- bid_flags(issues)
# 
# structure_result <- bid_structure(
#   previous_stage = anticipate_result,
#   telemetry_flags = flags
# )
# 
# validate_result <- bid_validate(
#   previous_stage = structure_result,
#   summary_panel = "Error handling improvements with clear user feedback",
#   next_steps = c(
#     "Implement loading states",
#     "Add error context",
#     "Test with users",
#     "Re-run telemetry analysis"
#   )
# )

## ----telemetry-diagnosis, eval=FALSE------------------------------------------
# # Analyze 3 months of user behavior data
# issues <- bid_telemetry("ecommerce_dashboard_telemetry.sqlite")
# 
# # Review the systematic analysis
# print(issues)
# #> # BID Telemetry Issues Summary
# #> Found 8 issues from 847 sessions
# #>
# #> Critical: 2 issues
# #> High: 3 issues
# #> Medium: 2 issues
# #> Low: 1 issue
# #>
# #> Top Priority Issues:
# #> ! delayed_interaction: 30.0% impact (254 sessions)
# #>    Problem: Users take a long time before making their first interaction
# #> ! unused_input_advanced_filters: 97.0% impact (822 sessions)
# #>    Problem: Users are not interacting with the 'advanced_filters' input
# #> ! error_1: 15.0% impact (127 sessions)
# #>    Problem: Users encounter errors when using the dashboard
# 
# # Examine the most critical issue in detail
# critical_issue <- issues |>
#   filter(severity == "critical") |>
#   arrange(desc(impact_rate)) |>
#   slice_head(n = 1)
# 
# print(critical_issue)
# #> # A tibble: 1 × 10
# #>   issue_id    issue_type  severity affected_sessions impact_rate problem
# #>   <chr>       <chr>       <chr>                <int>       <dbl> <chr>
# #> 1 delayed_in… delayed_in… critical               254        0.30 Users take…

## ----ecommerce-bid-analysis, eval=FALSE---------------------------------------
# # Start with interpretation of the business context
# interpret_stage <- bid_interpret(
#   central_question = "How can we make e-commerce insights more accessible?",
#   data_story = list(
#     hook = "Business teams struggle to get quick insights from our dashboard",
#     context = "Stakeholders have 10-15 minutes between meetings to check performance",
#     tension = "Current interface requires 47+ seconds just to orient and start using",
#     resolution = "Provide immediate value with progressive disclosure"
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
# # Convert critical issue to Notice stage
# notice_stage <- bid_notice_issue(
#   issue = critical_issue,
#   previous_stage = interpret_stage
# )
# 
# # Apply behavioral science
# anticipate_stage <- bid_anticipate(
#   previous_stage = notice_stage,
#   bias_mitigations = list(
#     choice_overload = "Reduce initial options, use progressive disclosure",
#     attention_bias = "Use visual hierarchy to guide user focus",
#     anchoring = "Lead with most important business metric"
#   )
# )
# 
# # Use telemetry flags to inform structure
# flags <- bid_flags(issues)
# structure_stage <- bid_structure(
#   previous_stage = anticipate_stage,
#   telemetry_flags = flags
# )
# 
# # Define validation
# validate_stage <- bid_validate(
#   previous_stage = structure_stage,
#   summary_panel = "Executive summary with key insights and trend indicators",
#   next_steps = c(
#     "Implement simplified landing page with key metrics",
#     "Add progressive disclosure for detailed analytics",
#     "Create role-based views for different user types",
#     "Set up telemetry tracking to measure improvement"
#   )
# )

## ----ecommerce-improvements, eval=FALSE---------------------------------------
# # Before: Information overload (what telemetry revealed)
# ui_before <- dashboardPage(
#   dashboardHeader(title = "E-commerce Analytics"),
#   dashboardSidebar(
#     # 15+ filter options immediately visible
#     selectInput("date_range", "Date Range", choices = date_options),
#     selectInput("product_category", "Category", choices = categories, multiple = TRUE),
#     selectInput("channel", "Sales Channel", choices = channels, multiple = TRUE),
#     # ... 12 more filters
#     actionButton("apply_filters", "Apply Filters")
#   ),
#   dashboardBody(
#     # 12 value boxes competing for attention
#     fluidRow(
#       valueBoxOutput("revenue"), valueBoxOutput("orders"),
#       valueBoxOutput("aov"), valueBoxOutput("conversion"),
#       # ... 8 more value boxes
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
#   # Address delayed interaction: Immediate value on landing
#   layout_columns(
#     col_widths = c(8, 4),
# 
#     # Primary business health (addresses anchoring bias)
#     card(
#       card_header("Business Performance Today", class = "bg-primary text-white"),
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
#             tags$li("Cart abandonment rate increased")
#           ),
#           actionButton("investigate_abandonment", "Investigate",
#             class = "btn btn-warning btn-sm"
#           )
#         )
#       )
#     ),
# 
#     # Quick actions (addresses choice overload)
#     card(
#       card_header("Quick Actions"),
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
#         p("Need something specific?", style = "font-size: 0.9em; color: #666;"),
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
#       card_header("Custom Analysis"),
#       layout_columns(
#         col_widths = c(3, 3, 3, 3),
#         selectInput("time_period", "Time Period",
#           choices = c("Today", "This Week", "This Month")
#         ),
#         selectInput("focus_area", "Focus Area",
#           choices = c("Revenue", "Traffic", "Conversions")
#         ),
#         selectInput("comparison", "Compare To",
#           choices = c("Previous Period", "Same Period Last Year")
#         ),
#         actionButton("apply_custom", "Analyze", class = "btn btn-primary")
#       )
#     )
#   )
# )

## ----measure-impact, eval=FALSE-----------------------------------------------
# # After implementing changes, collect new telemetry
# issues_after <- bid_telemetry(
#   "ecommerce_dashboard_telemetry_after_changes.sqlite"
# )
# 
# # Compare metrics
# improvement_metrics <- tibble::tibble(
#   metric = c(
#     "Time to first interaction",
#     "Session abandonment rate",
#     "Critical issues found",
#     "User satisfaction score"
#   ),
#   before = c("47 seconds", "12%", "2 issues", "6.2/10"),
#   after = c("8 seconds", "3%", "0 issues", "8.1/10"),
#   improvement = c("-83%", "-75%", "-100%", "+31%")
# )
# 
# print(improvement_metrics)

## ----complete_example, eval=FALSE---------------------------------------------
# library(bidux)
# library(dplyr)
# 
# # 1. Analyze telemetry with appropriate sensitivity
# issues <- bid_telemetry(
#   "telemetry.sqlite",
#   thresholds = bid_telemetry_presets("moderate")
# )
# 
# # 2. Review and triage issues
# print(issues)
# 
# # Focus on high-impact issues
# critical_issues <- issues |>
#   filter(severity %in% c("critical", "high")) |>
#   arrange(desc(impact_rate))
# 
# # 3. Address top issue through BID framework
# if (nrow(critical_issues) > 0) {
#   top_issue <- critical_issues |> slice_head(n = 1)
# 
#   # Interpret
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
#   # Notice (using bridge function)
#   notice_stage <- bid_notice_issue(
#     issue = top_issue,
#     previous_stage = interpret_stage
#   )
# 
#   # Anticipate
#   anticipate_stage <- bid_anticipate(
#     previous_stage = notice_stage,
#     bias_mitigations = list(
#       choice_overload = "Hide advanced filters until needed",
#       default_effect = "Pre-select most common filter values"
#     )
#   )
# 
#   # Structure (with telemetry flags)
#   flags <- bid_flags(issues)
#   structure_stage <- bid_structure(
#     previous_stage = anticipate_stage,
#     telemetry_flags = flags
#   )
# 
#   # Validate
#   validate_stage <- bid_validate(
#     previous_stage = structure_stage,
#     summary_panel = "Simplified filtering with progressive disclosure",
#     next_steps = c(
#       "Remove unused filters",
#       "Implement progressive disclosure",
#       "Add contextual help",
#       "Re-test with telemetry after changes"
#     )
#   )
# 
#   # 4. Generate report
#   improvement_report <- bid_report(validate_stage, format = "html")
# }

## ----verify_improvements, eval=FALSE------------------------------------------
# # Before changes
# issues_before <- bid_telemetry(
#   "telemetry_before.sqlite",
#   thresholds = bid_telemetry_presets("moderate")
# )
# 
# # After implementing improvements
# issues_after <- bid_telemetry(
#   "telemetry_after.sqlite",
#   thresholds = bid_telemetry_presets("moderate") # Use same thresholds!
# )
# 
# # Compare issue counts
# comparison <- tibble::tibble(
#   period = c("Before", "After"),
#   total_issues = c(nrow(issues_before), nrow(issues_after)),
#   critical = c(
#     sum(issues_before$severity == "critical"),
#     sum(issues_after$severity == "critical")
#   ),
#   high = c(
#     sum(issues_before$severity == "high"),
#     sum(issues_after$severity == "high")
#   )
# )
# 
# print(comparison)

## ----document_patterns, eval=FALSE--------------------------------------------
# # Save recurring patterns for future reference
# telemetry_patterns <- tibble::tibble(
#   pattern = c(
#     "date_filter_confusion",
#     "tab_discovery",
#     "error_recovery"
#   ),
#   description = c(
#     "Users often struggle with date range inputs",
#     "Secondary tabs have low discovery",
#     "Users abandon after errors"
#   ),
#   solution = c(
#     "Use date presets (Today, This Week, This Month)",
#     "Improve visual hierarchy and navigation cues",
#     "Implement graceful error handling with recovery options"
#   )
# )


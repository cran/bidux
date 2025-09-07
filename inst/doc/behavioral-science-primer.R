## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----setup--------------------------------------------------------------------
# library(bidux)
# library(dplyr)

## ----analytical-mindset, eval=FALSE-------------------------------------------
# # Your typical approach to data exploration
# data |>
#   filter(multiple_conditions) |>
#   group_by(several_dimensions) |>
#   summarize(
#     metric_1 = mean(value_1, na.rm = TRUE),
#     metric_2 = sum(value_2),
#     metric_3 = median(value_3),
#     .groups = "drop"
#   ) |>
#   arrange(desc(metric_1))

## ----cognitive-load-example---------------------------------------------------
# # Explore cognitive load concepts
# cognitive_concepts <- bid_concepts("cognitive")
# 
# cognitive_concepts |>
#   select(concept, description, implementation_tips) |>
#   head(3)

## ----cognitive-load-dashboard, eval=FALSE-------------------------------------
# # Instead of showing all 12 KPIs at once:
# # kpi_grid <- layout_columns(
# #   value_box("Revenue", "$1.2M", icon = "currency-dollar"),
# #   value_box("Customers", "15,432", icon = "people"),
# #   # ... 10 more value boxes
# # )
# 
# # Show key metrics first, details on demand:
# kpi_summary <- layout_columns(
#   col_widths = c(8, 4),
#   card(
#     card_header("Key Performance Summary"),
#     value_box("Primary Goal", "$1.2M Revenue", icon = "target"),
#     p("vs. $980K target (+22%)")
#   ),
#   card(
#     card_header("Details"),
#     actionButton(
#       "show_details",
#       "View All Metrics",
#       class = "btn-outline-primary"
#     )
#   )
# )

## ----anchoring-example--------------------------------------------------------
# # Learn about anchoring
# bid_concept("anchoring") |>
#   select(description, implementation_tips)

## ----anchoring-solution, eval=FALSE-------------------------------------------
# # Provide context and reference points
# sales_card <- card(
#   card_header("Monthly Sales Performance"),
#   layout_columns(
#     value_box(
#       title = "This Month",
#       value = "$87K",
#       showcase = bs_icon("graph-up"),
#       theme = "success"
#     ),
#     div(
#       p("Previous month: $65K", style = "color: #666; margin: 0;"),
#       p("Target: $80K", style = "color: #666; margin: 0;"),
#       p(strong("vs. Target: +9%"), style = "color: #28a745;")
#     )
#   )
# )

## ----framing-concepts---------------------------------------------------------
# # Explore framing concepts
# bid_concept("framing") |>
#   select(description, implementation_tips)

## ----framing-examples, eval=FALSE---------------------------------------------
# # Negative frame (emphasizes problems)
# satisfaction_negative <- value_box(
#   "Customer Issues",
#   "27% Unsatisfied",
#   icon = "exclamation-triangle",
#   theme = "danger"
# )
# 
# # Positive frame (emphasizes success)
# satisfaction_positive <- value_box(
#   "Customer Satisfaction",
#   "73% Satisfied",
#   icon = "heart-fill",
#   theme = "success"
# )
# 
# # Balanced frame (shows progress)
# satisfaction_balanced <- card(
#   card_header("Customer Satisfaction Progress"),
#   value_box("Current Level", "73%"),
#   p("Improvement needed: 17 percentage points to reach 90% target")
# )

## ----choice-reduction, eval=FALSE---------------------------------------------
# # Instead of 15 filters visible at once
# ui_complex <- div(
#   selectInput("region", "Region", choices = regions),
#   selectInput("product", "Product", choices = products),
#   selectInput("channel", "Channel", choices = channels),
#   # ... 12 more filters
# )
# 
# # Use progressive disclosure
# ui_simple <- div(
#   # Show only the most common filters first
#   selectInput("time_period", "Time Period", choices = time_options),
#   selectInput("metric", "Primary Metric", choices = key_metrics),
# 
#   # Advanced filters behind a toggle
#   accordion(
#     accordion_panel(
#       "Advanced Filters",
#       icon = bs_icon("sliders"),
#       selectInput("region", "Region", choices = regions),
#       selectInput("product", "Product", choices = products)
#       # Additional filters here
#     )
#   )
# )

## ----ux-testing-mindset, eval=FALSE-------------------------------------------
# # Your typical A/B test
# results <- t.test(
#   treatment_group$conversion_rate,
#   control_group$conversion_rate
# )
# 
# # UX equivalent: Test interface variations
# dashboard_test <- list(
#   control = "Current 5-chart overview page",
#   treatment = "Redesigned with progressive disclosure"
# )
# 
# # Measure: task completion time, user satisfaction, error rates
# # Analyze: same statistical rigor you'd apply to any experiment

## ----mental-model-validation--------------------------------------------------
# # Document user mental models like you document data assumptions
# user_assumptions <- bid_interpret(
#   central_question = "How do sales managers think about performance?",
#   data_story = list(
#     hook = "Sales managers need quick performance insights",
#     context = "They have 15 minutes between meetings",
#     tension = "Current reports take too long to interpret",
#     resolution = "Provide immediate visual context with drill-down capability"
#   )
# )
# 
# # Validate these assumptions like you'd validate data quality
# summary(user_assumptions)

## ----next-steps---------------------------------------------------------------
# # Explore available concepts by category
# all_concepts <- bid_concepts()
# table(all_concepts$category)
# 
# # Start with these fundamental concepts for data dashboards
# starter_concepts <- c(
#   "Cognitive Load Theory",
#   "Anchoring Effect",
#   "Processing Fluency",
#   "Progressive Disclosure"
# )
# 
# for (concept in starter_concepts) {
#   cat("\n### ", concept, "\n")
#   info <- bid_concept(concept)
#   cat(info$description[1], "\n")
#   cat("Implementation:", info$implementation_tips[1], "\n")
# }


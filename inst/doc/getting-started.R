## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----setup--------------------------------------------------------------------
# library(bidux)
# library(dplyr)

## ----concepts-----------------------------------------------------------------
# # List all concepts
# all_concepts <- bid_concepts()
# head(dplyr::select(all_concepts, concept, category, description), 3)
# 
# # Search for specific concepts
# bid_concepts("cognitive") |>
#   dplyr::select(concept, description, implementation_tips)

## ----concept_detail-----------------------------------------------------------
# # Get information about a specific concept
# bid_concept("Processing Fluency") |>
#   dplyr::select(concept, description, implementation_tips)

## ----concept_matching---------------------------------------------------------
# # Case-insensitive matching
# bid_concept("hick's law") |>
#   dplyr::select(concept, description)
# 
# # Partial matching
# bid_concept("proximity") |>
#   dplyr::select(concept, description)

## ----new_concepts-------------------------------------------------------------
# # Explore new concepts from user-centric design
# bid_concepts("visual hierarchy|breathable|gherkin") |>
#   dplyr::select(concept, description)

## ----interpret----------------------------------------------------------------
# # Document the user's need
# interpret_result <- bid_interpret(
#   central_question = "How are our marketing campaigns performing across different channels?",
#   data_story = list(
#     hook = "Recent campaign performance varies significantly across channels",
#     context = "We've invested in 6 different marketing channels over the past quarter",
#     tension = "ROI metrics show inconsistent results, with some channels underperforming",
#     resolution = "Identify top-performing channels and key performance drivers",
#     audience = "Marketing team and executives",
#     metrics = c("Channel ROI", "Conversion Rate", "Cost per Acquisition"),
#     visual_approach = "Comparative analysis with historical benchmarks"
#   ),
#   user_personas = list(
#     list(
#       name = "Marketing Manager",
#       goals = "Optimize marketing spend across channels",
#       pain_points = "Difficulty comparing performance across different metrics",
#       technical_level = "Intermediate"
#     ),
#     list(
#       name = "CMO",
#       goals = "Strategic oversight of marketing effectiveness",
#       pain_points = "Needs high-level insights without technical details",
#       technical_level = "Basic"
#     )
#   )
# )
# 
# interpret_result |>
#   dplyr::select(central_question, hook, tension, resolution)

## ----notice-------------------------------------------------------------------
# # Document the problem
# notice_result <- bid_notice(
#   previous_stage = interpret_result,
#   problem = "Users are overwhelmed by too many filter options and struggle to find relevant insights",
#   evidence = "User testing shows 65% of first-time users fail to complete their intended task within 2 minutes"
# )
# 
# notice_result |>
#   dplyr::select(problem, theory, evidence)

## ----anticipate---------------------------------------------------------------
# # Document bias mitigation strategies
# anticipate_result <- bid_anticipate(
#   previous_stage = notice_result,
#   bias_mitigations = list(
#     anchoring = "Include previous period performance as reference points",
#     framing = "Provide toggle between ROI improvement vs. ROI gap views",
#     confirmation_bias = "Highlight unexpected patterns that contradict common assumptions"
#   )
# )
# 
# anticipate_result |>
#   dplyr::select(bias_mitigations)

## ----structure----------------------------------------------------------------
# # Document the dashboard structure
# structure_result <- bid_structure(
#   previous_stage = anticipate_result
# )
# 
# structure_result |>
#   dplyr::select(layout, concepts, suggestions)

## ----validate-----------------------------------------------------------------
# # Document validation approach
# validate_result <- bid_validate(
#   previous_stage = structure_result,
#   summary_panel = "Executive summary highlighting top and bottom performers, key trends, and recommended actions for the next marketing cycle",
#   collaboration = "Team annotation capability allowing marketing team members to add context and insights to specific data points",
#   next_steps = c(
#     "Review performance of bottom 2 channels",
#     "Increase budget for top-performing channel",
#     "Schedule team meeting to discuss optimization strategy",
#     "Export findings for quarterly marketing review"
#   )
# )
# 
# validate_result |>
#   dplyr::select(summary_panel, collaboration, next_steps)

## ----suggestions--------------------------------------------------------------
# # Get {bslib} component suggestions
# bid_suggest_components(structure_result, package = "bslib") |>
#   dplyr::select(component, description) |>
#   head(2)
# 
# # Get {reactable} suggestions for showing data
# bid_suggest_components(structure_result, package = "reactable") |>
#   dplyr::select(component, description) |>
#   head(2)
# 
# # Get suggestions from all supported packages
# all_suggestions <- bid_suggest_components(validate_result, package = "all")
# table(all_suggestions$package)

## ----report, eval=FALSE-------------------------------------------------------
# # Generate a text report (default)
# report <- bid_report(validate_result)
# cat(report)
# 
# # Generate an HTML report
# html_report <- bid_report(
#   validate_result,
#   format = "html"
# )
# 
# # Generate a markdown report
# md_report <- bid_report(validate_result, format = "markdown")


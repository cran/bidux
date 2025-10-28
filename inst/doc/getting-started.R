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
# head(select(all_concepts, concept, category, description), 3)
# 
# # Search for specific concepts
# bid_concepts("cognitive") |>
#   select(concept, description, implementation_tips)

## ----concept_detail-----------------------------------------------------------
# # Get information about a specific concept
# bid_concept("Processing Fluency") |>
#   select(concept, description, implementation_tips)

## ----concept_matching---------------------------------------------------------
# # Case-insensitive matching
# bid_concept("hick's law") |>
#   select(concept, description)
# 
# # Partial matching
# bid_concept("proximity") |>
#   select(concept, description)

## ----new_concepts-------------------------------------------------------------
# # Explore new concepts from user-centric design
# bid_concepts("visual hierarchy|breathable|gherkin") |>
#   select(concept, description)

## ----interpret----------------------------------------------------------------
# # Document the user's need using new_data_story() with flat API (recommended)
# interpret_result <- bid_interpret(
#   central_question = "How are our marketing campaigns performing across different channels?",
#   data_story = new_data_story(
#     hook = "Recent campaign performance varies significantly across channels",
#     context = "We've invested in 6 different marketing channels over the past quarter",
#     tension = "ROI metrics show inconsistent results, with some channels underperforming",
#     resolution = "Identify top-performing channels and key performance drivers",
#     audience = "Marketing team and executives",
#     metrics = "Channel ROI, Conversion Rate, Cost per Acquisition",
#     visual_approach = "Comparative analysis with historical benchmarks"
#   ),
#   # Recommended: use data.frame for personas (cleaner, more explicit)
#   user_personas = data.frame(
#     name = c("Marketing Manager", "CMO"),
#     goals = c(
#       "Optimize marketing spend across channels",
#       "Strategic oversight of marketing effectiveness"
#     ),
#     pain_points = c(
#       "Difficulty comparing performance across different metrics",
#       "Needs high-level insights without technical details"
#     ),
#     technical_level = c("intermediate", "basic"),
#     stringsAsFactors = FALSE
#   )
# )
# 
# interpret_result |>
#   select(central_question, hook, tension, resolution)

## ----notice-------------------------------------------------------------------
# # Document the problem
# notice_result <- bid_notice(
#   previous_stage = interpret_result,
#   problem = "Users are overwhelmed by too many filter options and struggle to find relevant insights",
#   evidence = "User testing shows 65% of first-time users fail to complete their intended task within 2 minutes"
# )
# 
# notice_result |>
#   select(problem, theory, evidence)

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
#   select(bias_mitigations)

## ----structure----------------------------------------------------------------
# # Document the dashboard structure
# structure_result <- bid_structure(previous_stage = anticipate_result)
# 
# structure_result |>
#   select(layout, concepts, suggestions)

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
#   select(summary_panel, collaboration, next_steps)

## ----suggestions--------------------------------------------------------------
# # Get {bslib} component suggestions
# bid_suggest_components(structure_result, package = "bslib") |>
#   select(component, description) |>
#   head(2)
# 
# # Get {reactable} suggestions for showing data
# bid_suggest_components(structure_result, package = "reactable") |>
#   select(component, description) |>
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
# html_report <- bid_report(validate_result, format = "html")
# 
# # Generate a markdown report
# md_report <- bid_report(validate_result, format = "markdown")

## ----telemetry_presets--------------------------------------------------------
# # STRICT: Detects even minor issues - use for critical applications
# strict_issues <- bid_telemetry(
#   "path/to/telemetry.sqlite",
#   thresholds = bid_telemetry_presets("strict")
# )
# # - Flags inputs used by < 2% of sessions
# # - Flags delays > 20 seconds to first action
# # - Flags errors in > 5% of sessions
# # - Flags pages visited by < 10% of users
# 
# # MODERATE: Balanced default - appropriate for most applications
# moderate_issues <- bid_telemetry(
#   "path/to/telemetry.sqlite",
#   thresholds = bid_telemetry_presets("moderate")
# )
# # - Flags inputs used by < 5% of sessions (default)
# # - Flags delays > 30 seconds to first action (default)
# # - Flags errors in > 10% of sessions (default)
# # - Flags pages visited by < 20% of users (default)
# 
# # RELAXED: Only detects major issues - use for mature, stable dashboards
# relaxed_issues <- bid_telemetry(
#   "path/to/telemetry.sqlite",
#   thresholds = bid_telemetry_presets("relaxed")
# )
# # - Flags inputs used by < 10% of sessions
# # - Flags delays > 60 seconds to first action
# # - Flags errors in > 20% of sessions
# # - Flags pages visited by < 30% of users

## ----preset_comparison--------------------------------------------------------
# # Analyze with all three presets
# strict <- bid_telemetry(
#   "path/to/telemetry.sqlite",
#   thresholds = bid_telemetry_presets("strict")
# )
# 
# moderate <- bid_telemetry(
#   "path/to/telemetry.sqlite",
#   thresholds = bid_telemetry_presets("moderate")
# )
# 
# relaxed <- bid_telemetry(
#   "path/to/telemetry.sqlite",
#   thresholds = bid_telemetry_presets("relaxed")
# )
# 
# # Compare issue counts
# data.frame(
#   preset = c("strict", "moderate", "relaxed"),
#   total_issues = c(nrow(strict), nrow(moderate), nrow(relaxed)),
#   critical_issues = c(
#     sum(strict$severity == "critical"),
#     sum(moderate$severity == "critical"),
#     sum(relaxed$severity == "critical")
#   )
# )
# 
# # Strict preset typically finds 2-3x more issues than relaxed
# # Use strict during initial development, relaxed for stable dashboards

## ----telemetry_workflow_modern------------------------------------------------
# # 1. Analyze telemetry with appropriate sensitivity
# issues <- bid_telemetry(
#   "path/to/telemetry.sqlite",
#   thresholds = bid_telemetry_presets("moderate")
# )
# 
# # 2. Triage and review issues (returns organized summary)
# print(issues)
# 
# # 3. Filter to high-priority issues using dplyr
# library(dplyr)
# critical_issues <- issues |>
#   filter(severity %in% c("critical", "high")) |>
#   arrange(desc(impact_rate))
# 
# # 4. Convert top issues to Notice stages for BID workflow
# notices <- bid_notices(
#   issues = critical_issues,
#   previous_stage = interpret_result,
#   max_issues = 3
# )
# 
# # 5. Extract telemetry flags for informed decisions
# flags <- bid_flags(issues)
# flags$has_critical_issues  # TRUE/FALSE
# flags$has_navigation_issues  # TRUE/FALSE
# flags$session_count  # Number of sessions analyzed
# 
# # 6. Use flags to inform Structure stage
# structure_result <- bid_structure(
#   previous_stage = anticipate_result,
#   telemetry_flags = flags
# )

## ----telemetry_workflow_legacy------------------------------------------------
# # Returns hybrid object that works as both list and enhanced object
# legacy_issues <- bid_ingest_telemetry(
#   "path/to/telemetry.sqlite",
#   thresholds = bid_telemetry_presets("moderate")
# )
# 
# # Legacy list interface (backward compatible)
# length(legacy_issues)  # Number of issues as list length
# legacy_issues[[1]]  # First issue as bid_stage object
# names(legacy_issues)  # Issue identifiers
# 
# # Enhanced features (new in 0.3.1)
# as_tibble(legacy_issues)  # Get tidy issues view
# bid_flags(legacy_issues)  # Extract global flags
# print(legacy_issues)  # Shows organized triage summary
# 
# # Both interfaces work on same object

## ----complete_telemetry_example-----------------------------------------------
# # Step 1: Analyze telemetry to identify friction points
# issues <- bid_telemetry(
#   "path/to/telemetry.sqlite",
#   thresholds = bid_telemetry_presets("strict")  # Catch everything during development
# )
# 
# # Step 2: Start BID workflow with central question
# interpret_result <- bid_interpret(
#   central_question = "How can we reduce user friction identified in telemetry?",
#   data_story = new_data_story(
#     hook = "Telemetry shows multiple UX friction points",
#     context = glue::glue("Analysis of {bid_flags(issues)$session_count} user sessions"),
#     tension = "Users struggling with specific UI elements and workflows",
#     resolution = "Systematically address high-impact issues using BID framework"
#   )
# )
# 
# # Step 3: Address highest-impact issue first
# top_issue <- issues |>
#   arrange(desc(impact_rate)) |>
#   slice(1)
# 
# notice_result <- bid_notices(
#   issues = top_issue,
#   previous_stage = interpret_result
# )[[1]]
# 
# # Step 4: Anticipate biases related to the issue
# anticipate_result <- bid_anticipate(
#   previous_stage = notice_result,
#   bias_mitigations = list(
#     anchoring = "Provide clear default values based on common use cases",
#     confirmation_bias = "Show data that challenges user assumptions"
#   )
# )
# 
# # Step 5: Structure with telemetry-informed decisions
# structure_result <- bid_structure(
#   previous_stage = anticipate_result,
#   telemetry_flags = bid_flags(issues)  # Informs layout selection
# )
# 
# # Step 6: Validate with telemetry references
# validate_result <- bid_validate(
#   previous_stage = structure_result,
#   summary_panel = "Dashboard improvements based on analysis of real user behavior patterns",
#   next_steps = c(
#     "Address remaining high-severity telemetry issues",
#     "Re-run telemetry analysis after changes to measure improvement",
#     "Monitor key metrics: time-to-first-action, error rates, navigation patterns"
#   )
# )


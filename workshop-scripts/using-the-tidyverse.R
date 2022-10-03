# Law and Courts Immersion: Working with Large Databases
# Using the tidyverse
# Joshua C. Fjelstul, Ph.D.

# Packages
library(tidyverse)
library(lubridate)

# Load EU infringement data ----------------------------------------------------

# We're going to use data on EU infringement cases from the European Union
# Infringements Procedure (EUIP) Database. This database has an R package that
# we can install from GitHub
devtools::install_github("jfjelstul/euip")

# Extract the decisions table from the `euip` package
decisions <- euip::decisions

# The unit of observation is a decision in an Commission infringement case

# This is an example of a "tidy" dataset:
# 1) Each variable has its own column
# 2) Each observation has its own row
# 3) Each value has its own cell

# All tools from the `tidyverse` are designed for "tidy" data

# About the EU infringement procedure ------------------------------------------

# You always want to start by making sure you understand the structure of your
# data and how to interpret it substantively

# The EU infringement procedure is a legal procedure by which the European
# Commission can bring a legal case against an EU member state for violating EU
# law. It is a pre-trial bargaining procedure, but the Commission can refer
# cases to the Court of Justice of the European Union (CJEU)

# There are 6 possible stages:
# 1. Letter of formal notice (Article 258 TFEU) = notice of a possible infringement
# 2. Reasoned opinion (Article 258 TFEU) = Commission lays out legal case
# 3. Referral to the Court (Article 258 TFEU) = Commission asks the Court to establish a violation
# 4. Letter of formal notice (Article 260 TFEU) = notice of possible noncompliance with a CJEU ruling
# 5. Reasoned opinion (Article 260 TFEU) = Commission lays out legal case
# 6. Referral to the Court (Article 260 TFEU) = Commission asks the Court to impose a fine

# The Commission can close a case or withdraw a decision at any time for any
# reason. Infringement cases are managed by Directorates-General (DGs) of the
# Commission, which are organized by policy area

# Pipes ------------------------------------------------------------------------

# Pipes are a programming technique that converts nested code to linear code.
# This makes your code a lot easier to read

# Let's make a short vector of random numbers between 0 and 10
set.seed(12345)
random_numbers <- runif(n = 10, min = 1, max = 10)

# Suppose we want to find the median integer. There are 4 basic ways of doing
# this in R

# Option 1: create a new object each time
# This quickly clutters up your R environment and the names aren't meaningful
x_1 <- round(random_numbers)
x_2 <- median(x_1)

# Option 2: overwrite the object
# This way, you have to rerun the code from the beginning
x <- round(random_numbers)
x <- median(x)

# Option 3: nest the functions
# Here, you have to think from the inside out
x <- median(round(random_numbers))
x <- median(
  round(random_numbers)
)

# Option 4: use a pipe
# This way, you can think linearly
x <- random_numbers |>
  round() |>
  median()

# Pipes are really useful when you need to do a lot of operations in sequence on
# the same dataset, like renaming variables, then selecting variables, then
# selecting observations, then grouping observations, then collapsing
# observations. But pipes usually aren't a good solution when the functions you
# need to use have multiple inputs or outputs

# Clean environment
rm(random_numbers, x, x_1, x_2)

# Sorting data ------------------------------------------------------------

# Example 1: sort data by date (ascending order)
decisions <- decisions |>
  arrange(decision_date)

# Example 2: sort data by date (descending order)
decisions <- decisions |>
  arrange(desc(decision_date))

# Example 3: sort data by member state, then date (ascending order)
decisions <- decisions |>
  arrange(member_state_id, decision_date)

# Example 4: sort data by member state, then date (descending order)
decisions <- decisions |>
  arrange(member_state_id, desc(decision_date))

# Example 5: sort by key_id
decisions <- decisions |>
  arrange(key_id)

# Filtering data ---------------------------------------------------------------

# Example 1: get ROs
# Example of the `==` operator
example <- decisions |>
  filter(stage_ro_258 == 1)

# Example 2: get decisions with a press release
# Example of the `!=` operator
example <- decisions |>
  filter(press_release == 1)
example <- decisions |>
  filter(press_release != 0)

# Example 3: get LFNs and ROs
# Example of the `|` operator
example <- decisions |>
  filter(stage_lfn_258 == 1 | stage_ro_258 == 1)

# Example 4: get ROs with a press release
# Example of the `&` operator
example <- decisions |>
  filter(stage_ro_258 == 1 & press_release == 1)

# Example 5: get LFNs and ROs with a press release
# Example of a compound logical condition
example <- decisions |>
  filter((stage_lfn_258 == 1 | stage_ro_258 == 1) & press_release == 1)

# Example 6: keep first round decisions
# Example of the `%in%` operator
example <- decisions |>
  filter(decision_stage %in% c(
    "Letter of formal notice (Article 258)",
    "Reasoned opinion (Article 258)",
    "Referral to the Court (Article 258)"
  ))
table(example$decision_stage)

# Example 7: drop closing and withdrawal
# Example of the `!` operator
example <- decisions |>
  filter(
    !(decision_stage %in% c("Closing", "Withdrawal"))
  )
table(example$decision_stage)

# Renaming variables -----------------------------------------------------------

# Rename the reasoned opinions variable
example <- decisions |>
  rename(reasoned_opinion = stage_ro_258)

# Check variable names
names(example)

# Rename multiple variables
example <- decisions |>
  rename(
    formal_notice = stage_lfn_258,
    reasoned_opinion = stage_ro_258,
    referral = stage_rf_258
  )

# Check variable names
names(example)

# Selecting variables ----------------------------------------------------------

# Example 1
# Select a subset of variables
example <- decisions |>
  select(decision_id, member_state, decision_stage)

# Example 2
# Code formatting for selecting a larger number of variables
example <- decisions |>
  select(
    decision_id, case_id,
    member_state_id, member_state, member_state_code,
    decision_stage_id, decision_stage
  )

# Example 3
# Get the member state and DG for reasoned opinions
example <- filter(decisions, stage_ro_258 == 1)
example <- select(
  example,
  decision_id,
  department_id, department,
  member_state_id, member_state, member_state_code
)

# Example 4
# Get the member state and DG for reasoned opinions (using a pipe)
example <- decisions |>
  filter(stage_ro_258 == 1) |>
  select(
    decision_id,
    department_id, department,
    member_state_id, member_state, member_state_code
  )

# Example 5
# Get the member state and DG for reasoned opinions in non-communication cases
example <- decisions |>
  filter(stage_ro_258 == 1 & noncommunication == 1) |>
  select(
    decision_id,
    department_id, department,
    member_state_id, member_state, member_state_code
  )

# Modifying data ---------------------------------------------------------------

# The standard way to modify variables is using the `$` notation
example <- decisions
example$reasoned_opinion <- as.numeric(example$decision_stage == "Reasoned opinion (Article 258)")
table(example$reasoned_opinion)

# The `tidyverse` approach is to use `mutate()` from `dplyr`
# `mutate()` lets us create a new variable in a pipe
example <- decisions |>
  mutate(
    reasoned_opinion = as.numeric(example$decision_stage == "Reasoned opinion (Article 258)")
  ) |>
  arrange(decision_date)
table(example$reasoned_opinion)

# We can use indexing to make categorical variables
example$stage_short <- "missing"
example$stage_short[example$decision_stage == "Letter of formal notice (Article 258)"] <- "LFN 258"
example$stage_short[example$decision_stage == "Reasoned opinion (Article 258)"] <- "RO 258"
example$stage_short[example$decision_stage == "Referral to the Court (Article 258)"] <- "RF 258"
example$stage_short[example$decision_stage == "Letter of formal notice (Article 260)"] <- "LFN 260"
example$stage_short[example$decision_stage == "Reasoned opinion (Article 260)"] <- "RO 260"
example$stage_short[example$decision_stage == "Referral to the Court (Article 260)"] <- "RF 260"
example$stage_short[example$decision_stage == "Closing"] <- "C"
example$stage_short[example$decision_stage == "Withdrawal"] <- "W"
table(example$stage_short)

# We also can use `mutate()` in combination with `case_when()`
example <- decisions |>
  mutate(
    stage_short = case_when(
      decision_stage == "Letter of formal notice (Article 258)" ~ "LFN 258",
      decision_stage == "Letter of formal notice (Article 258)" ~ "LFN 258",
      decision_stage == "Reasoned opinion (Article 258)" ~ "RO 258",
      decision_stage == "Referral to the Court (Article 258)" ~ "RF 258",
      decision_stage == "Letter of formal notice (Article 260)" ~ "LFN 260",
      decision_stage == "Reasoned opinion (Article 260)" ~ "RO 260",
      decision_stage == "Referral to the Court (Article 260)" ~"RF 260",
      decision_stage == "Closing" ~ "C",
      decision_stage == "Withdrawal" ~ "W"
    )
  )
table(example$stage_short)

# You can also specify a catch-all category by setting the condition to `TRUE`
example <- decisions |>
  mutate(
    stage_short = case_when(
      decision_stage == "Letter of formal notice (Article 258)" ~ "LFN 258",
      decision_stage == "Letter of formal notice (Article 258)" ~ "LFN 258",
      decision_stage == "Reasoned opinion (Article 258)" ~ "RO 258",
      decision_stage == "Referral to the Court (Article 258)" ~ "RF 258",
      decision_stage == "Letter of formal notice (Article 260)" ~ "LFN 260",
      decision_stage == "Reasoned opinion (Article 260)" ~ "RO 260",
      decision_stage == "Referral to the Court (Article 260)" ~"RF 260",
      TRUE ~ "other"
    )
  ) |>
  filter(stage_short != "other")
table(example$stage_short)

# Working with strings ---------------------------------------------------------

# The `stringr` package provides a suite of functions for working with strings

# All `stringr` functions are vectorized so you can use them on a tibble column

# Basic operations:
# Concatenating text: `str_c()`
# Removing text: `str_remove()`, `str_remove_all()`
# Replacing text: `str_replace()`, `str_replace_all()`
# Extracting text: `str_extract()`, `str_extract_all()`
# Detecting text: `str_detect()`, `str_detect_all()`, `str_count()`
# Removing white space: `str_trim()`, `str_squish()`
# Changing capitalization: `str_to_lower()`, `str_to_upper()`, `str_to_sentence()`, `str_to_title()`
# Wrapping text: `str_wrap()`

# Example 1: concatenating text
head(decisions$department_code)
example <- decisions |>
  mutate(
    department_code = str_c("DG ", department_code)
  )
head(example$department_code)

# Functions for removing, replacing, extracting, and detecting text work with
# exact matches or regular expressions. We'll focus on exact matches here, but
# regular expressions are a really useful tool to know

# Example 2: removing text
# `str_remove()` only removes the first occurrence
head(decisions$department)
example <- decisions |>
  mutate(
    department = str_remove(department, "Directorate-General for ")
  )
head(example$department)

# Example 3: removing text
# `str_remove_all()` removes all occurrences
head(decisions$decision_date)
example <- decisions |>
  mutate(
    decision_date = str_remove_all(decision_date, "-")
  )
head(example$decision_date)

# Example 4: replacing text
# `str_replace()` only replaces the first occurrence
head(decisions$department)
example <- decisions |>
  mutate(
    department = str_replace(department, "Directorate-General for", "DG")
  )
head(example$department)

# Example 5: replacing text
# `str_replace_all()` replaces all occurrences
head(decisions$decision_id)
example <- decisions |>
  mutate(
    decision_id = str_replace_all(decision_id, ":", "-")
  )
head(example$decision_id)

# Example 6: extracting text
# `str_extract()` extracts only the first match
# This is a good example of a pipe inside of a pipe
head(decisions$decision_id)
example <- decisions |>
  mutate(
    case_year = decision_id |>
      str_extract("[0-9]{4}") |>
      as.numeric(),
    case_number = decision_id |>
      str_extract("[0-9]{4}:[0-9]{4}") |>
      str_extract("[0-9]{4}$") |>
      as.numeric()
  )
head(decisions$decision_id)
head(example$case_year)
head(example$case_number)

# Example 7: extracting text
# `str_extract_all()` extracts all matches. It returns a list of character
# vectors, where each element in the list corresponds to an observation and each
# element in the vector corresponds to one match. This list can be stored as a
# column in a tibble. Generally, you want to avoid lists in tibble columns, but
# this is one example where it's useful
example <- decisions |>
  mutate(
    numbers = decision_date |>
      str_extract_all("[0-9]+")
  )
head(example$numbers)

# Example 8: detecting text
# `str_detect()` detects whether there is at least one match
# This is very useful for creating dummy variables
table(decisions$decision_stage)
example <- decisions |>
  mutate(
    article_258 = decision_stage |>
      str_detect("258") |>
      as.numeric()
  )
table(example$article_258)

# Example 9: removing white space
# `str_trim()` removes white space at the ends
# `str_squish()` also turns multiple interior spaces in a row into one space
head(decisions$department)
example <- decisions |>
  mutate(
    department = department |>
      str_remove("Directorate-General for")
  )
head(example$department)
example <- decisions |>
  mutate(
    department = department |>
      str_remove("Directorate-General for") |>
      str_trim()
  )
head(example$department)

# Example 10: changing capitalization
# This is especially useful for correctly formatting plot labels
example <- decisions |>
  mutate(
    department_lower = str_to_lower(department),
    department_upper = str_to_upper(department),
    department_sentence = str_to_sentence(department),
    department_title = str_to_title(department)
  )
head(example$department)
head(example$department_lower)
head(example$department_upper)
head(example$department_sentence)
head(example$department_title)

# example 11: wrapping text
# sometimes you want to wrap text for plot labels to they fit
# \n indicates a line break in a string
# it would display as a line break if you were to plot it
head(decisions$department)
example <- decisions |>
  mutate(
    department_labels = str_wrap(department, width = 20)
  )
head(example$department_labels)

# Working with factors ---------------------------------------------------------

# You can store categorical variables are strings or factors. Factors are one of
# the most confusing things about R. Factors are integers that map to "levels",
# which are basically labels. Factors have an order based on the underlying
# integer. You can make a factor out of an integer or a string if you use a
# string, the level will be the same as the string values

# Factors are efficient because each string label is only stored once and is
# represented by an integer every time it appears

# Generally, you want to store categorical variables as strings. Exception 1:
# when you need to include dummy variables in a regression. Exception 2: when
# you need to plot a categorical variables and you want the categories in a
# particular order

# Example 1: making a factor
x <- c(1, 2, 3, 2, 2, 3, 2, 3, 1, 2)
x <- factor(x)
levels(x)
x

# Example 2: adding levels
x <- c(1, 2, 3, 2, 2, 3, 2, 3, 1, 2)
x <- factor(
  x,
  levels = c(1, 2, 3), # this determines the order
  label = c("I", "II", "III") # this determines the name
)
levels(x)
x
# Notice that the output says the levels are I, II, and III. But we we call the
# `factor()` function the levels are 1, 2, 3 and the labels are I, II, and III.
# This is one reason why factors can be confusing. What the `factor()` function
# calls labels are actually levels

# Example 3: changing the order
x <- c(1, 2, 3, 2, 2, 3, 2, 3, 1, 2)
x <- factor(
  x,
  levels = c(3, 2, 1),
  label = c("III", "II", "I")
)
levels(x)
x

# Example 4: missing levels
x <- c(1, 2, 3, 2, 2, 3, 2, 3, 1, 2)
x <- factor(
  x,
  levels = c(1, 2, 3, 4),
  label = c("I", "II", "III", "IV")
)
levels(x)
x

# Get a table that shows how many times each level appears
fct_count(x)

# See all levels that actually appear
fct_unique(x)

# You can reorder factors. This is really important for plotting data. For
# example, if you want to make a bar plot where categories in are order, you
# have to reorder the factor

# Example 5: reordering a factor
x <- c(1, 2, 3, 2, 2, 3, 2, 3, 1, 2)
x <- factor(
  x,
  levels = c(1, 2, 3),
  label = c("I", "II", "III")
)

# Let's make a tibble with a factor and a numeric variable
example <- tibble(
  category = factor(c("a", "b", "c")),
  order = c(3, 2, 1)
)
levels(example$category)

# We can reorder `category` based on `order`
example$category <- fct_reorder(example$category, example$order)
levels(example$category)

# Here's an example in a pipe
example <- decisions |>
  mutate(
    decision_label = factor(decision_stage)
  )

# If we make a table, it looks like a string, but it isn't
# the categories are in alphabetical order
table(example$decision_label)

# We can coerce it to numeric to see the levels
table(as.numeric(example$decision_label))

# We can use the `level()` function to see the unique levels
levels(example$decision_label)

# We can also decide the order manually using the levels argument
example <- decisions |>
  mutate(
    decision_label = factor(
      decision_stage,
      levels = c(
        "Letter of formal notice (Article 258)",
        "Reasoned opinion (Article 258)",
        "Referral to the Court (Article 258)",
        "Letter of formal notice (Article 260)",
        "Reasoned opinion (Article 260)",
        "Referral to the Court (Article 260)",
        "Withdrawal",
        "Closing"
      )
    )
  )

# Now the order is what we want
table(example$decision_label)

# You can also set the levels and labels separately
example <- decisions |>
  mutate(
    decision_label = factor(
      decision_stage_id,
      levels = seq(1, 8, 1),
      labels = c(
        "Letter of formal notice (Article 258)",
        "Reasoned opinion (Article 258)",
        "Referral to the Court (Article 258)",
        "Letter of formal notice (Article 260)",
        "Reasoned opinion (Article 260)",
        "Referral to the Court (Article 260)",
        "Withdrawal",
        "Closing"
      )
    )
  )

# Now the order is what we want
table(example$decision_label)
levels(example$decision_label)

# Clean environment
rm(x)

# Working with dates -----------------------------------------------------------

# The `lubridate` package has a lot of great features. Here, we'll just focus on
# formatting dates correctly

# Dates in R use a `YYYY-MM-DD` format. You can store date columns using the
# character class or date class. You should ALWAYS store dates in a `YYYY-MM-DD`
# format. This is the standard in data science. Reason 1: it's unambiguous which
# number is the month and which is the day. Reason 2: dates in this format sort
# chronologically even when stored as text

# Storing a date in a different format for making plots is not a good reason not
# to use a `YYYY-MM-DD` format. There are better ways of formatting dates in
# specific ways for plots

# Why use date objects? Storing a date using the date class lets you do
# calculations (duration, overlaps, etc.). If you aren't doing calculations,
# storing dates as a string is just fine

# Example 1: MDY (American format)
example <- c("January 21, 2022", "January 22, 2022", "January 23, 2022")
example <- mdy(example)
class(example)
example

# Example 2: MDY (American format with ordinal numbers)
example <- c("January 21st, 2022", "January 22nd, 2022", "January 23rd, 2022")
example <- mdy(example)
class(example)
example

# Example 3: DMY (European format)
example <- c("21 January, 2022", "22 January, 2022", "23 January, 2022")
example <- dmy(example)
class(example)
example

# Example 4: YMD example
example <- c("2022-01-21", "2022-01-22", "2022-01-23")
example <- ymd(example)
class(example)
example

# Example 5: flexible formats
example <- c("21 Jan 2022", "22 Jan 2022", "23 Jan 2022")
example <- dmy(example)
class(example)
example

# Example 6: failed parsing
example <- c("21 January, 2022", "22 January, 2022", "23 January, 2022")
example <- ymd(example)
example

# Grouping data ----------------------------------------------------------------

# We can group the data by year and member state to create panel data

# Example 1: reasoned opinions per member state per year
example <- decisions |>
  filter(stage_lfn_258 == 1) |>
  group_by(decision_year, member_state) |>
  summarize(
    count = n()
  )

# Example 2: reasoned opinions per member state per year
example <- decisions |>
  filter(stage_lfn_258 == 1) |>
  group_by(decision_year, member_state) |>
  count()

# Example 3: list of case IDs for referrals by member state and year
example <- decisions |>
  filter(stage_rf_258 == 1) |>
  group_by(decision_year, member_state) |>
  summarize(
    case_ids = str_c(case_id, collapse = ", ")
  )

# Example 4: list of all decisions in each case
example <- decisions |>
  filter(stage_additional == 0) |>
  arrange(decision_date) |>
  group_by(case_id) |>
  summarize(
    history = str_c(decision_stage, collapse = ", ")
  )

# Example 5: grouping using `mutate()` instead of `summarize()`
# When you use `mutate()` remember to also use `ungroup()`
example <- decisions |>
  group_by(case_id) |>
  mutate(
    group_id = cur_group_id(), # a unique ID number for each group
    within_group_id = 1:n() # a counter within each group
  ) |>
  ungroup() |>
  arrange(group_id, within_group_id)

# Putting it all together ------------------------------------------------------

# Create a variable that records the history of UK internal market cases
# Example: "LFN 258 (2016-01-27), RO 258 (2016-07-22), Closing (2017-02-15)"
example <- decisions |>
  filter(stage_additional == 0) |>
  filter(
    department %in% c(
      "Directorate-General for Internal Market and Services",
      "Directorate-General for Internal Market, Industry, Entrepreneurship and SMEs"
    )
  ) |>
  filter(str_detect(case_id, "UK")) |>
  arrange(decision_date) |>
  mutate(
    stage = case_when(
      decision_stage == "Letter of formal notice (Article 258)" ~ "LFN 258",
      decision_stage == "Reasoned opinion (Article 258)" ~ "RO 258",
      decision_stage == "Referral to the Court (Article 258)" ~ "RF 258",
      decision_stage == "Letter of formal notice (Article 260)" ~ "LFN 260",
      decision_stage == "Reasoned opinion (Article 260)" ~ "RO 608",
      decision_stage == "Referral to the Court (Article 260)" ~ "RF 260",
      TRUE ~ decision_stage
    ),
    stage_date = str_c(stage, " (", decision_date, ")")
  ) |>
  group_by(case_id) |>
  summarize(
    stages = n(),
    history = str_c(stage_date, collapse = ", ")
  ) |>
  arrange(desc(stages), desc(case_id))

# Merging data -----------------------------------------------------------------

# We'll start by making a few tibbles we can merge together

# Make a list of all cases since 2010
cases <- decisions |>
  filter(case_year >= 2010) |>
  group_by(
    case_id, case_year, case_number,
    department, member_state
  ) |>
  summarize() |>
  ungroup()

# Make a list of all letters
letters <- decisions |>
  filter(stage_lfn_258 == 1) |>
  select(case_id, decision_id, decision_date)

# Make a list of all opinions
opinions <- decisions |>
  filter(stage_ro_258 == 1) |>
  select(case_id, decision_id, decision_date)

# Example 1: stack tables vertically
example <- bind_rows(letters, opinions)

# There is also a `bind_cols()` function, but this is rarely useful because the
# two tibbles have to have the same number of observations and they have to be
# in the same order. You almost always want to merge based on one or more
# uniquely identifying variables

# There are several options for merging tibbles, but `left_join()` is by far the
# most common

# Example 2: left join (all rows in x)
example <- left_join(cases, opinions, by = "case_id")

# Note that the number of observations increased because there can be multiple
# reasoned opinions per case. Always check the number of observations before and
# after merging to make sure it's what you expect

# There is also `right_join()`, `inner_join()`, and `full_join()` but the use
# cases for these functions are very specific. `left_join()` is almost always
# what you want

# Reshaping data ---------------------------------------------------------------

# Again, we'll start by making a few tibbles to work with

# The decisions in each case
cases <- decisions |>
  group_by(case_id) |>
  summarize(
    list_decisions = str_c(decision_stage, collapse = ", ")
  )

# The number of decisions per member state in 2018
# This tibble is already in a long format
frequencies_long <- decisions |>
  filter(str_detect(decision_stage, "258|260")) |>
  filter(decision_year == 2018) |>
  group_by(member_state, decision_stage) |>
  summarize(
    count = n()
  )

# Example 1: expanding data
# Sometimes you have multiple values stored as a string in a
# column of a tibble separated by a comma (or similar) and you want to separate
# these values out into separate observations
# `separate_rows()` lets you expand the number of observations
decisions_new <- cases |>
  separate_rows(
    list_decisions,
    sep = ","
  ) |>
  rename(
    decision_stage = list_decisions
  ) |>
  mutate(
    decision_stage = str_squish(decision_stage)
  )

# Example 2: long to wide
# `pivot_wider()` lets you convert long data to wide data
frequencies_wide <- frequencies_long |>
  mutate(
    var_name = case_when(
      decision_stage == "Letter of formal notice (Article 258)" ~ "lfn_258",
      decision_stage == "Reasoned opinion (Article 258)" ~ "ro_258",
      decision_stage == "Referral to the Court (Article 258)" ~ "rf_258",
      decision_stage == "Letter of formal notice (Article 260)" ~ "lfn_260",
      decision_stage == "Reasoned opinion (Article 260)" ~ "ro_260",
      decision_stage == "Referral to the Court (Article 260)" ~ "rf_260"
    )
  ) |>
  pivot_wider(
    id_cols = member_state,
    names_from = var_name,
    values_from = count,
    values_fill = 0
  )

# Example 3: long to wide with factors
# The same thing but including a column for every factor level
frequencies_wide <- frequencies_long |>
  mutate(
    var_name = case_when(
      decision_stage == "Letter of formal notice (Article 258)" ~ "lfn_258",
      decision_stage == "Reasoned opinion (Article 258)" ~ "ro_258",
      decision_stage == "Referral to the Court (Article 258)" ~ "rf_258",
      decision_stage == "Letter of formal notice (Article 260)" ~ "lfn_260",
      decision_stage == "Reasoned opinion (Article 260)" ~ "ro_260",
      decision_stage == "Referral to the Court (Article 260)" ~ "rf_260"
    ) |>
      factor()
  ) |>
  pivot_wider(
    id_cols = member_state,
    names_from = var_name,
    values_from = count,
    id_expand = TRUE,
    values_fill = 0
  )

# Example 4: going from wide to long
# `pivot_longer()` lets you convert wide data to long data
frequencies_long_new <- frequencies_wide |>
  pivot_longer(
    cols = matches("258|260"),
    names_to = "decision_stage",
    values_to = "count"
  ) |>
  mutate(
    decision_stage = case_when(
      decision_stage == "lfn_258" ~ "Letter of formal notice (Article 258)",
      decision_stage == "ro_258" ~ "Reasoned opinion (Article 258)",
      decision_stage == "rf_258" ~ "Referral to the Court (Article 258)",
      decision_stage == "lfn_260" ~ "Letter of formal notice (Article 260)",
      decision_stage == "ro_260" ~ "Reasoned opinion (Article 260)",
      decision_stage == "rf_260" ~ "Referral to the Court (Article 260)"
    )
  ) |>
  filter(count != 0)

# Clean environment
rm(cases, decisions_new, frequencies_long, frequencies_long_new, frequencies_wide)

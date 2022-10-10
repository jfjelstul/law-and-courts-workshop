# Law and Courts Immersion: Working with Large Databases
# Using the tidyverse
# Joshua C. Fjelstul, Ph.D.

# Packages
library(tidyverse)
library(lubridate)

# Load data
load("CJEU-database-platform-assignments-v-0-1.RData")
load("CJEU-database-platform-judgments-v-0-1.RData")

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
assignments <- assignments |>
  arrange(decision_date)

# Example 2: sort data by date (descending order)
assignments <- assignments |>
  arrange(desc(decision_date))

# Example 3: sort data by member state, then date (ascending order)
assignments <- assignments |>
  arrange(court_id, decision_date)

# Example 4: sort data by member state, then date (descending order)
assignments <- assignments |>
  arrange(court_id, desc(decision_date))

# Example 5: sort by key_id
assignments <- assignments |>
  arrange(key_id)

# Filtering data ---------------------------------------------------------------

# Example 1: get CJ decisions
# Example of the `==` operator
example <- assignments |>
  filter(court == "Court of Justice")

# Example 2: get Judge-Rapporteurs
# Example of the `!=` operator
example <- assignments |>
  filter(judge_rapporteur == 1)
example <- assignments |>
  filter(judge_rapporteur != 0)

# Example 3: get decisions at the CJ or GC
# Example of the `|` operator
example <- assignments |>
  filter(court == "Court of Justice" | court == "General Court")

# Example 4: get JRs at the CJ
# Example of the `&` operator
example <- assignments |>
  filter(court == "Court of Justice" & judge_rapporteur == 1)

# Example 5: get JRs at the CJ or the GC
# Example of a compound logical condition
example <- assignments |>
  filter((court == "Court of Justice" | court == "General Court") & judge_rapporteur == 1)

# Example 6: keep first round decisions
# Example of the `%in%` operator
example <- assignments |>
  filter(court %in% c(
    "Court of Justice",
    "General Court"
  ))
table(example$court)

# Example 7: drop closing and withdrawal
# Example of the `!` operator
example <- assignments |>
  filter(
    !(court %in% c("Court of Justice", "Civil Service Tribunal"))
  )
table(example$court)

# Renaming variables -----------------------------------------------------------

# Check variable names
names(example)

# Rename the reasoned opinions variable
example <- assignments |>
  rename(judge_name = judge)

# Check variable names
names(example)

# Rename multiple variables
example <- assignments |>
  rename(
    celex_number = celex,
    ecli_number = ecli
  )

# Check variable names
names(example)

# Selecting variables ----------------------------------------------------------

# Example 1
# Select a subset of variables
example <- assignments |>
  select(iuropa_decision_id, iuropa_proceeding_id, judge)

# Example 2
# Code formatting for selecting a larger number of variables
example <- assignments |>
  select(
    iuropa_decision_id, iuropa_proceeding_id,
    iuropa_judge_id, judge, judge_rapporteur
  )

# Example 3
# Get JRs at the CJ
example <- filter(assignments, court == "Court of Justice", judge_rapporteur == 1)
example <- select(
  example,
  iuropa_decision_id,
  court, judge
)

# Example 4
# Get the member state and DG for reasoned opinions (using a pipe)
example <- assignments |>
  filter(court == "Court of Justice" & judge_rapporteur == 1) |>
  select(
    iuropa_decision_id,
    court, judge
  )

# Modifying data ---------------------------------------------------------------

# The standard way to modify variables is using the `$` notation
example <- assignments
example$court_of_justice <- as.numeric(example$court == "Court of Justice")
table(example$court_of_justice)

# The `tidyverse` approach is to use `mutate()` from `dplyr`
# `mutate()` lets us create a new variable in a pipe
example <- assignments |>
  mutate(
    court_of_justice = as.numeric(court == "Court of Justice")
  ) |>
  arrange(decision_date)
table(example$court_of_justice)

# We can use indexing to make categorical variables
example$court_short <- "missing"
example$court_short[example$court == "Court of Justice"] <- "CJ"
example$court_short[example$court == "General Court"] <- "GC"
example$court_short[example$court == "Civil Service Tribunal"] <- "CST"
table(example$court_short)

# We also can use `mutate()` in combination with `case_when()`
example <- assignments |>
  mutate(
    court_short = case_when(
      court == "Court of Justice" ~ "CJ",
      court == "General Court" ~ "GC",
      court == "Civil Service Tribunal" ~ "CST",
    )
  )
table(example$court_short)

# You can also specify a catch-all category by setting the condition to `TRUE`
example <- assignments |>
  mutate(
    court_short = case_when(
      court == "Court of Justice" ~ "CJ",
      court == "General Court" ~ "GC",
      TRUE ~ "other"
    )
  ) |>
  filter(court_short != "other")
table(example$court_short)

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
example <- assignments |>
  mutate(
    court_label = factor(court)
  )

# If we make a table, it looks like a string, but it isn't
# the categories are in alphabetical order
table(example$court_label)

# We can coerce it to numeric to see the levels
table(as.numeric(example$court_label))

# We can use the `level()` function to see the unique levels
levels(example$court_label)

# We can also decide the order manually using the levels argument
example <- assignments |>
  mutate(
    court_label = factor(
      court,
      levels = c(
        "Court of Justice",
        "General Court",
        "Civil Service Tribunal"
      )
    )
  )

# Now the order is what we want
table(example$court_label)

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
example <- assignments |>
  filter(court == "Court of Justice") |>
  group_by(iuropa_decision_id) |>
  summarize(
    count_judges = n()
  )

# Example 2: list of judges by case
example <- assignments |>
  filter(court == "Court of Justice") |>
  arrange(iuropa_decision_id, judge) |>
  group_by(iuropa_decision_id) |>
  summarize(
    judges = str_c(judge, collapse = ", ")
  )

# Example 3: grouping using `mutate()` instead of `summarize()`
# When you use `mutate()` remember to also use `ungroup()`
example <- assignments |>
  group_by(iuropa_decision_id) |>
  mutate(
    group_id = cur_group_id(), # a unique ID number for each group
    within_group_id = 1:n(), # a counter within each group
    panel_size_2 = n()
  ) |>
  ungroup() |>
  arrange(group_id, within_group_id)

# Merging data -----------------------------------------------------------------

# We'll start by making a few tibbles we can merge together

# Get CJ decisions
judgments_core <- judgments |>
  filter(court == "Court of Justice") |>
  select(
    iuropa_decision_id, iuropa_proceeding_id, decision_date
  )

# Make a list of all letters
assignments_core <- assignments |>
  filter(court == "Court of Justice") |>
  select(
    iuropa_decision_id, formation, judge
  )

# Example 1: left join (all rows in x)
example <- left_join(
  assignments_core,
  judgments_core,
  by = "iuropa_decision_id"
)

# Always check the number of observations before and after merging to make sure
# it's what you expect

# There is also `right_join()`, `inner_join()`, and `full_join()` but the use
# cases for these functions are very specific. `left_join()` is almost always
# what you want

# Law and Courts Immersion: Working with Large Databases
# Using the iuropa package
# Joshua C. Fjelstul, Ph.D.

# Installation
install.packages("devtools")
devtools::install_github("jfjelstul/iuropa")

# Load package
library(iuropa)

# Authenticating with the IUROPA API
session <- authenticate(
  username = "USERNAME",
  password = "PASSWORD"
)

# Check authentication
check_authentication(session)

# Looking up IUROPA components
response <- list_components(session)

# Getting more info about each component
response <- describe_components(session)

# Looking up datasets
response <- list_datasets(
  session = session,
  component = "cjeu_database_platform"
)

# Getting more info about each dataset
response <- describe_datasets(
  session = session,
  component = "cjeu_database_platform"
)

# Checking the codebook
response <- list_variables(
  session = session,
  component = "cjeu_database_platform",
  dataset = "assignments"
)

# Getting variable descriptions
response <- describe_variables(
  session = session,
  component = "cjeu_database_platform",
  dataset = "assignments"
)

# Selecting data
list(
  court = "Court of Justice",
  decision_date_min = "2004-05-01"
)

# Downloading data
response <- download_data(
  session = session,
  component = "cjeu_database_platform",
  dataset = "assignments",
  filters = list(
    court = "Court of Justice",
    decision_date_min = "2004-05-01"
  ),
  variables = c(
    "iuropa_decision_id", "iuropa_proceeding_id",
    "iuropa_judge_id", "judge"
  )
)

# Law and Courts Immersion: Working with Large Databases
# An intro to text analysis in R
# Joshua C. Fjelstul, Ph.D.

# Install packages
install.packages("tidyverse")
install.packages("lubridate")
install.packages("ggplot2")
install.packages("patchwork")
devtools::install_github("jfjelstul/ggminimal")
devtools::install_github("jfjelstul/quanteda")
devtools::install_github("jfjelstul/quanteda.textstats")
devtools::install_github("jfjelstul/quanteda.textmodels")

# Load packages
library(tidyverse)
library(lubridate)
library(quanteda)
library(quanteda.textstats)
library(quanteda.textmodels)
library(seededlda)
library(ggplot2)
library(patchwork)
library(ggminimal)

# Read in data -----------------------------------------------------------------

# All judgments delivered by the Court of Justice between 1 January, 2019
# and 12 December, 2021
load("data/text_corpus.RData")

# Code the judge-rapporteur ----------------------------------------------------

# Let's try with a simple regular expression first
judge_rapporteurs <- text_corpus |>
  filter(str_detect(text, "^composed of")) |>
  mutate(
    judge_rapporteur = text |>
      str_extract("[A-Z]\\. [[:alpha:]]+ \\(Rapporteur\\)") |>
      str_remove("\\([Rr]apporteur\\)") |>
      str_remove("^[A-Z]\\.") |>
      str_squish()
  )

# Check how many are missing
table(is.na(judge_rapporteurs$judge_rapporteur))

# What are the problems?
# Some names have spaces
# One initial doesn't have a period after them
# One judgment has a comma before "(Rapporteur)"
# Some judgments have "(Rapporteure)"
# Some judges have ", President of the Chamber" before "Rapporteur"

# Now let's make it flexible enough to work for all judgments
judge_rapporteurs <- text_corpus |>
  filter(str_detect(text, "^composed of")) |>
  mutate(
    judge_rapporteur = text |>
      str_extract("[A-Z](\\.)? [[:alpha:]' ]+(, President of the Chamber)?,? *\\([Rr]apporteure?\\)") |>
      str_remove("\\([Rr]apporteure?\\)") |>
      str_remove(", President of the Chamber") |>
      str_remove("^[A-Z](\\.)?") |>
      str_remove(",") |>
      str_squish()
  )

# Check how many are missing
table(is.na(judge_rapporteurs$judge_rapporteur))

# Check values to make sure the names are clean
unique(judge_rapporteurs$judge_rapporteur)

# Prepare the text for analysis ------------------------------------------------

text_corpus <- text_corpus |>
  mutate(
    clean_text = text |>
      str_to_lower() |>
      str_replace_all("[[:punct:]]+", " ") |>
      str_replace_all("[[:digit:]]+", " ") |>
      str_squish()
  )

# Collapse by judgment
text_corpus <- text_corpus |>
  group_by(ecli, decision_date) |>
  summarize(
    text = str_c(clean_text, collapse = " ")
  )

# Now we can merge in the judge-rapporteurs based on the ECLI number
text_corpus <- left_join(
  text_corpus,
  judge_rapporteurs |>
    select(ecli, judge_rapporteur),
  by = "ecli"
)

# We'll drop the judgments where the judge-rapporteur is missing
text_corpus <- text_corpus |>
  filter(!is.na(judge_rapporteur))

# Create a corpus object
corpus <- corpus(
  text_corpus$text,
  docnames = text_corpus$ecli,
  docvars = text_corpus |>
    select(decision_date, judge_rapporteur)
)

# Document feature matrix ------------------------------------------------------

# Create a DFM
dfm <- corpus |>
  tokens() |> # Create tokens
  tokens_wordstem() |> # Stem words
  tokens_remove(stopwords("english")) |> # Remove stop words
  dfm()

# Let's check to see what the default stop words are
stopwords("english")

# Check the dimensions
dim(dfm)
# There are 1244 documents
# There are 28886 unique tokens

# Let's take a look at the first 100 tokens to make sure the
# lemmatization worked as expected
head(colnames(dfm), n = 100)

# We could also use ngrams
dfm_2 <- corpus |>
  tokens() |> # Create tokens
  tokens_ngrams(2) |> # Create bi-grams
  tokens_wordstem() |> # Stem words
  tokens_remove(stopwords("english")) |> # Remove stop words
  dfm()

# Check the dimensions again
dim(dfm_2)
# Now we have 493276 tokens

# Let's see what they look like
head(colnames(dfm_2), n = 100)

# We'll just use words (for computational efficiency)
rm(dfm_2)

# We don't usually want to keep all of the words
# We can "trim" the DFM by dropping really infrequent words
# We'll keep words that occur at least 50 times
dfm_trimmed <- dfm |>
  dfm_trim(min_termfreq = 500)

# Check the dimensions again
dim(dfm_trimmed)

head(dfm_trimmed)

# Topic model ------------------------------------------------------------------

# Estimate a model with 2 categories
topic_model_2 <- textmodel_lda(dfm_trimmed, k = 2)
save(topic_model_2, file = "models/topic_model_2.RData")
load("models/topic_model_2.RData")

# See the top 20 tokens that define each topic
terms(topic_model_2, n = 20)

# Estimate a model with 10 categories
topic_model_10 <- textmodel_lda(dfm_trimmed, k = 10)
save(topic_model_10, file = "models/topic_model_10.RData")
load("models/topic_model_10.RData")

# See the top 20 tokens that define each topic
terms(topic_model_10, n = 20)

length(topic_model_10$alpha)
length(topic_model_10$beta)
dim(topic_model_10$phi)
dim(topic_model_10$theta)

# Estimate a seeded model
dictionary <- dictionary(file = "code/topics.yml")
seeded_topic_model <- textmodel_seededlda(dfm_trimmed, dictionary, residual = TRUE)
save(seeded_topic_model, file = "models/seeded_topic_model.RData")
load("models/seeded_topic_model.RData")

# See the top 20 tokens that define each topic
terms(seeded_topic_model, n = 20)

# Interpret estimates ----------------------------------------------------------

# Make a tibble with estimates
topic_estimates <- seeded_topic_model$theta |>
  as_tibble() |>
  mutate(
    ecli = text_corpus$ecli,
    judge_rapporteur = text_corpus$judge_rapporteur
  ) |>
  group_by(judge_rapporteur) |>
  summarize(
    count = n(),
    economy = mean(economy),
    social = mean(social),
    tax = mean(tax),
    ip = mean(ip),
    competition = mean(competition)
  ) |>
  ungroup() |>
  mutate(
    judge_rapporteur = judge_rapporteur |>
      factor()
  )

# Plot average positions by judge-rapporteur for the taxation topic
panel_1 <- ggplot(topic_estimates, aes(x = tax, y = fct_reorder(judge_rapporteur, tax), size = count)) +
  geom_point() +
  scale_size_continuous(range = c(1, 4), guide = "none") +
  ggtitle("Taxation topic") +
  ylab(NULL) +
  xlab("Average estimated probability") +
  theme_minimal()

# Plot average positions by judge-rapporteur for the intellectual property topic
panel_2 <- ggplot(topic_estimates, aes(x = ip, y = fct_reorder(judge_rapporteur, ip), size = count)) +
  geom_point() +
  scale_size_continuous(range = c(1, 4), name = "Number of judgments") +
  ggtitle("Intellectual property topic") +
  ylab(NULL) +
  xlab("Average estimated probability") +
  theme_minimal()

# Combine panels
plot <- panel_1 + panel_2 + plot_layout(nrow = 1, ncol = 2)

# Save plot
ggsave(plot, filename = "plots/judge_topics.png", device = "png", width = 10, height = 6, scale = 1.25)

# Wordfish model ---------------------------------------------------------------

# Estimate model
wordfish_model <- textmodel_wordfish(dfm_trimmed)
save(wordfish_model, file = "models/wordfish_model.RData")
load("models/wordfish_model.RData")

# There are 4 parameters
# theta = estimated document positions (this is mainly what we're interested in)
# beta = estimated word positions
# alpha = estimated document fixed effect (some documents are just longer than others)
# psi = estimated word fixed effect (some words are just more common)

# Interpret word estimates -----------------------------------------------------

# List of procedure-oriented words
procedural_words <- c(
  "appeal", "appel", "plead", "unsuccess", "error", "plea", "unfound",
  "distort", "ineffect", "annulment", "infring"
)

# List of policy-oriented words
policy_words <- c(
  "worker", "social", "pension", "taxat", "incom", "credit", "employ",
  "contract", "person", "work", "tax", "servic"
)

# Make a tibble with the word parameters
word_estimates <- tibble(
  word = colnames(dfm_trimmed),
  position = wordfish_mod$beta,
  fixed_effect = wordfish_mod$psi,
)

# Word type
word_estimates <- word_estimates |>
  mutate(
    word_type = case_when(
      word %in% procedural_words ~ "Procedural word",
      word %in% policy_words ~ "Policy word",
      TRUE ~ "Other"
    ),
    word_type = factor(word_type, levels = c("Policy word", "Procedural word", "Other"))
  )

# We can graph these to interpret the latent dimension
plot <- ggplot(word_estimates, aes(x = position, y = fixed_effect, label = word, color = word_type, size = word_type)) +
  geom_text() +
  geom_vline(xintercept = 0, size = 0.5, linetype = "dashed") +
  scale_x_continuous(limits = c(-4, 4), breaks = seq(-4, 4, 1)) +
  scale_y_continuous(limits = c(-4, 4), breaks = seq(-4, 4, 1)) +
  scale_color_manual(values = c("#3498db", "#2ecc71", "gray70"), name = NULL) +
  scale_size_manual(values = c(4, 4, 2.5), guide = "none") +
  ggtitle("Wordfish estimates for the positions of words in CJEU judgments (2019-2021)") +
  ylab("Fixed effect") +
  xlab("Word position") +
  theme_minimal()
plot

# Save plot
ggsave(plot, filename = "plots/word_positions.png", device = "png", width = 10, height = 10, scale = 1)

# Interpret document estimates -------------------------------------------------

# Add estimates to text corpus
document_estimates <- text_corpus |>
  mutate(
    document = text_corpus$theta,
    judge_rapporteur = text_corpus$judge_rapporteur,
    position = wordfish_mod$theta
  )

# Collapse by judge
judge_estimates <- document_estimates |>
  group_by(judge_rapporteur) |>
  summarize(
    position = mean(position),
    count = n()
  ) |>
  ungroup() |>
  mutate(
    judge_rapporteur = judge_rapporteur |>
      factor() |>
      fct_reorder(position)
  )

# Plot average positions by judge-rapporteur
plot <- ggplot(judge_estimates, aes(x = position, y = judge_rapporteur, size = count, color = position)) +
  geom_point() +
  geom_vline(xintercept = 0, size = 0.5, linetype = "dashed") +
  scale_size_continuous(range = c(1, 4), name = "Number of judgments") +
  scale_color_gradient(low = "#3498db", high = "#2ecc71", guide = "none") +
  ggtitle("Wordfish estimates for the positions CJEU judges (2019-2021)") +
  ylab(NULL) +
  xlab("Average judge-rapporteur position") +
  theme_minimal()
plot

# Save plot
ggsave(plot, filename = "plots/judge_positions.png", device = "png", width = 10, height = 10, scale = 1)

# Law and Courts Immersion: Working with Large Databases
# Visualization using ggplot2
# Joshua C. Fjelstul, Ph.D.

# Packages
library(tidyverse)

# Install a dev package with a custom theme
devtools::install_github("jfjelstul/ggminimal")
library(ggminimal)

# Making good plots takes a lot of work and a lot of code. `ggplot2` is by far
# the best visualization tool for data science, but the default aesthetics
# aren't great. You have to do a lot of customization to get nice-looking plots

# Example 1: a bar graph with no customization
# LFNs per member state in 2018
plot <- decisions |>
  filter(stage_lfn_258 == 1, decision_year == 2018) |>
  group_by(member_state) |>
  summarize(count = n()) |>
  ggplot() +
  geom_bar(aes(x = member_state, y = count), stat = "identity")
plot

# Example 2: a bar graph with customization
# LFNs per member state in 2018
plot <- decisions |>
  filter(stage_lfn_258 == 1, decision_year == 2018) |>
  group_by(member_state) |>
  summarize(count = n()) |>
  mutate(
    member_state = fct_reorder(member_state, count)
  ) |>
  ggplot() +
  geom_bar(aes(x = member_state, y = count), stat = "identity", size = 0.5, color = "black", fill = "gray90", width = 0.7) +
  geom_hline(aes(yintercept = mean(count)), linetype = "dashed", size = 0.5) +
  scale_y_continuous(breaks = seq(0, 40, 5), expand = expansion(c(0, 0.1))) +
  ggtitle("Letters for formal notice (2018)") +
  xlab(NULL) +
  ylab("Number of decisions") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
plot

# Save plot
ggsave(plot, filename = "examples/bar-graph.pdf", device = "pdf", width = 10, height = 7, scale = 1.25)

# Example 3: a line graph
# Number of LFNs per year
plot <- decisions |>
  filter(stage_lfn_258 == 1 & decision_year >= 2004 & decision_year <= 2018) |>
  group_by(decision_year) |>
  summarize(count = n()) |>
  ggplot() +
  geom_point(aes(x = decision_year, y = count), size = 2) +
  geom_line(aes(x = decision_year, y = count), size = 0.5) +
  scale_y_continuous(breaks = seq(0, 2000, 100)) +
  scale_x_continuous(breaks = seq(2002, 2018, 1)) +
  ggtitle("Letters for formal notice by year") +
  xlab(NULL) +
  ylab("Number of decisions") +
  theme_minimal()
plot

# Example 4: a line graph with multiple lines
# Number of decisions per year
plot <- decisions |>
  filter(decision_stage_id %in% c(1, 2, 3) & decision_year >= 2004 & decision_year <= 2018) |>
  group_by(decision_year, decision_stage) |>
  summarize(count = n()) |>
  mutate(
    decision_stage = factor(decision_stage)
  ) |>
  ggplot() +
  geom_point(aes(x = decision_year, y = count, color = decision_stage), size = 2) +
  geom_line(aes(x = decision_year, y = count, color = decision_stage), size = 0.5) +
  scale_y_continuous(breaks = seq(0, 2000, 100)) +
  scale_x_continuous(breaks = seq(2002, 2018, 1)) +
  scale_color_discrete(name = "Stage") +
  ggtitle("Article 258 decisions by year") +
  xlab(NULL) +
  ylab("Number of decisions") +
  theme_minimal()
plot

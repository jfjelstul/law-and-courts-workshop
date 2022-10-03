# Law and Courts Immersion: Working with Large Databases
# Making maps using the eumaps package
# Joshua C. Fjelstul, Ph.D.

# Install packages
devtools::install_github("jfjelstul/eumaps")

# Libraries
library(eumaps)

# Basic example ----------------------------------------------------------------

# Example 1

data <- simulate_data()

geography <- create_geography()

palette <- create_palette(
  member_states = data$member_state,
  values = data$value,
  value_min = 0,
  value_max = 1,
  count_colors = 8,
  color_low = "#E74C3C",
  color_high = "#3498DB",
  color_mid = "#FFFFFF"
)

theme <- create_theme()

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme,
  title = "Example map"
)

map

ggplot2::ggsave(
  filename = "examples/example-1.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Example 2

data <- simulate_data(min = -1, max = 1, missing = "France")

map <- make_map(
  geography = create_geography(
    date = "2000-01-01"
  ),
  palette = create_palette(
    member_states = data$member_state,
    values = data$value,
    value_min = -1,
    value_max = 1,
    count_colors = 8,
    color_low = "#E74C3C",
    color_high = "#3498DB",
    color_mid = "#FFFFFF"
  ),
  theme = create_theme()
)

ggplot2::ggsave(
  filename = "examples/example-2.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Example 3

data <- simulate_data(
  min = -1,
  max = 1,
  missing = "Germany",
  seed = 1357
)

map <- make_map(
  geography = create_geography(
    insets = c("Luxembourg", "Cyprus", "Malta")
  ),
  palette = create_palette(
    member_states = data$member_state,
    values = data$value,
    not_applicable = c(
      "Bulgaria", "Croatia", "Czech Rebpulic",
      "Denmark", "Hungary", "Poland",
      "Romania", "Sweden"
    ),
    value_min = -1,
    value_max = 1,
    count_colors = 8,
    color_low = c(231, 76, 59),
    color_high = c(53, 151, 219),
    color_mid = c(255, 255, 255),
    label_not_applicable = "Not a member of the Eurozone"
  ),
  theme = create_theme()
)

ggplot2::ggsave(
  filename = "examples/example-3.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Example 4

data <- simulate_data(
  min = -1,
  max = 1,
  missing = "Germany",
  seed = 1357
)

map <- make_map(
  geography = create_geography(
    show_non_member_states = FALSE
  ),
  palette = create_palette(
    member_states = data$member_state,
    values = data$value,
    value_min = -1,
    value_max = 1,
    count_colors = 8,
    color_low = c(231, 76, 59),
    color_high = c(53, 151, 219),
    color_mid = c(255, 255, 255)
  ),
  theme = create_theme(
    color_map_border = c(1, 1, 1),
    width_map_border = 2,
    color_country_borders = c(1, 1, 1),
  )
)

ggplot2::ggsave(
  filename = "examples/example-4.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Example 5

data <- simulate_data(
  min = -1,
  max = 1,
  seed = 2468,
)

map <- make_map(
  geography = create_geography(),
  palette = create_palette(
    member_states = data$member_state,
    values = data$value,
    value_min = -1,
    value_max = 1,
    count_colors = 8,
    color_low = c(231, 76, 59),
    color_high = c(53, 151, 219),
    color_mid = c(255, 255, 255)
  ),
  theme = create_theme()
)

ggplot2::ggsave(
  filename = "examples/example-5.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Eurozone example -------------------------------------------------------------

data <- simulate_data(missing = "France")

eurozone <- c(
  "Austria", "Belgium", "Cyprus" ,"Estonia", "Finland",
  "France", "Germany", "Greece", "Ireland", "Italy",
  "Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands",
  "Portugal", "Slovakia", "Slovenia", "Spain"
)

geography <- create_geography(
  aspect_ratio = 1,
  insets = c("Luxembourg", "Cyprus", "Malta")
)

palette <- create_palette(
  member_states = data$member_state,
  values = data$value,
  not_applicable = setdiff(member_states$member_state, eurozone),
  value_min = 0,
  value_max = 1,
  count_colors = 8,
  color_low = "#E74C3C",
  color_high = "#3498DB",
  color_mid = "#FFFFFF",
  label_not_applicable = "Not a member of the Eurozone"
)

theme <- create_theme()

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme,
  title = "Eurozone map"
)

ggplot2::ggsave(
  filename = "examples/eurozone-map.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Choosing member states -------------------------------------------------------

# Example 1

geography <- create_geography()

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme
)

ggplot2::ggsave(
  filename = "examples/member-states-1.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Example 2

geography <- create_geography(
  date = "2000-01-01"
)

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme
)

ggplot2::ggsave(
  filename = "examples/member-states-2.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Example 3

geography <- create_geography(
  date = "1960-01-01"
)

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme
)

ggplot2::ggsave(
  filename = "examples/member-states-3.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Example 4

geography <- create_geography(
  subset = c(
    "France", "Germany", "Italy",
    "Belgium", "Netherlands", "Luxembourg"
  )
)

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme
)

ggplot2::ggsave(
  filename = "examples/member-states-4.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Aspect ratio -----------------------------------------------------------------

# Example 1

geography <- create_geography(
  aspect_ratio = 0.8
)

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme
)

ggplot2::ggsave(
  filename = "examples/aspect-ratio-1.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Example 2

geography <- create_geography(
  aspect_ratio = 1.2
)

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme
)

ggplot2::ggsave(
  filename = "examples/aspect-ratio-2.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Zooming ----------------------------------------------------------------------

# Example 1

geography <- create_geography(
  zoom = 0.8
)

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme
)

ggplot2::ggsave(
  filename = "examples/zoom-1.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Example 2

geography <- create_geography(
  zoom = 0.7
)

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme
)

ggplot2::ggsave(
  filename = "examples/zoom-2.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Non-member states ------------------------------------------------------------

# Example 1

geography <- create_geography(
  show_non_member_states = TRUE
)

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme
)

ggplot2::ggsave(
  filename = "examples/non-member-states-1.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Example 2

geography <- create_geography(
  show_non_member_states = FALSE
)

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme
)

ggplot2::ggsave(
  filename = "examples/non-member-states-2.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Insets -----------------------------------------------------------------------

# Example 1

geography <- create_geography(
  insets = c("Luxembourg", "Malta")
)

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme
)

ggplot2::ggsave(
  filename = "examples/insets-1.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Example 2

geography <- create_geography(
  insets = c("Luxembourg", "Cyprus", "Malta")
)

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme
)

ggplot2::ggsave(
  filename = "examples/insets-2.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Resolution -------------------------------------------------------------------

# Example 1

geography <- create_geography(
  resolution = "high"
)

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme
)

ggplot2::ggsave(
  filename = "examples/resolution-1.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Example 2

geography <- create_geography(
  resolution = "low"
)

map <- make_map(
  geography = geography,
  palette = palette,
  theme = theme
)

ggplot2::ggsave(
  filename = "examples/resolution-2.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Palette ----------------------------------------------------------------------

# Example 1

data <- simulate_data(
  min = 0,
  max = 1,
  missing = "Germany",
  seed = 1357
)

map <- make_map(
  geography = create_geography(
    insets = c("Luxembourg", "Cyprus", "Malta")
  ),
  palette = create_palette(
    member_states = data$member_state,
    values = data$value,
    not_applicable = c(
      "Bulgaria", "Croatia", "Czech Republic",
      "Denmark", "Hungary", "Poland",
      "Romania", "Sweden"
    ),
    value_min = 0,
    value_max = 1,
    count_colors = 8,
    color_low = c(226, 240, 249),
    color_high = c(53, 151, 219),
    label_not_applicable = "Not a member of the Eurozone"
  ),
  theme = create_theme()
)

ggplot2::ggsave(
  filename = "examples/palette-1.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Example 2

data <- simulate_data(
  min = -1,
  max = 1,
  missing = "Germany",
  seed = 1357,
)

map <- make_map(
  geography = create_geography(
    insets = c("Luxembourg", "Cyprus", "Malta")
  ),
  palette = create_palette(
    member_states = data$member_state,
    values = data$value,
    not_applicable = c(
      "Bulgaria", "Croatia", "Czech Republic",
      "Denmark", "Hungary", "Poland",
      "Romania", "Sweden"
    ),
    value_min = -1,
    value_max = 1,
    count_colors = 8,
    color_low = c(231, 76, 59),
    color_high = c(53, 151, 219),
    color_mid = c(255, 255, 255),
    label_not_applicable = "Not a member of the Eurozone"
  ),
  theme = create_theme()
)

ggplot2::ggsave(
  filename = "examples/palette-2.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Theme ------------------------------------------------------------------------

data <- simulate_data(
  min = -1,
  max = 1,
  seed = 1357
)

# Example 1

map <- make_map(
  geography = create_geography(),
  palette = create_palette(
    member_states = data$member_state,
    values = data$value,
    value_min = -1,
    value_max = 1,
    count_colors = 8,
    color_low = c(231, 76, 59),
    color_high = c(53, 151, 219),
    color_mid = c(255, 255, 255),
  ),
  theme = create_theme()
)

ggplot2::ggsave(
  filename = "examples/theme-1.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

# Example 2

map <- make_map(
  geography = create_geography(),
  palette = create_palette(
    member_states = data$member_state,
    values = data$value,
    value_min = -1,
    value_max = 1,
    count_colors = 8,
    color_low = c(231, 76, 59),
    color_high = c(53, 151, 219),
    color_mid = c(255, 255, 255),
    color_non_member_state = c(0.9, 0.9, 0.9)
  ),
  theme = create_theme(
    color_map_border = c(1, 1, 1),
    width_map_border = 2,
    color_country_borders = c(1, 1, 1),
    width_country_borders = 0.2,
    space_before_legend = 32,
    size_legend_keys = 18,
    space_between_legend_keys = 12
  )
)

ggplot2::ggsave(
  filename = "examples/theme-2.png",
  map,
  device = "png",
  scale = 1,
  height = 8,
  width = 10,
  units = "in"
)

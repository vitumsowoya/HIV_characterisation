library(readxl)

hiv <- read_excel("C:/Users/Vitumbiko Msowoya/OneDrive/Documents/Work/Malawi_HIV.xlsx")

library(ggplot2)
ggplot(hiv, aes(x = Year, y = Count + 1, fill = Subtype)) +
  geom_col(position = position_dodge(width = 0.8),
           colour = "black",
           linewidth = 0.25) +
  scale_y_log10(
    breaks = c(1, 10, 100, 1000, 10000),
    labels = c("0", "10", "100", "1,000", "10,000")
  ) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Distribution of HIV Subtypes Across Time in Malawi",
    x = "Sampling Period",
    y = "Number of Sequences (log10 scale)",
    fill = "Subtype"
  ) +
  theme_classic(base_size = 15) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "right"
  )
ggplot(hiv,
       aes(x = Year,
           y = Count + 1,
           group = Subtype,
           colour = Subtype)) +
  geom_line(linewidth = 1.4) +
  geom_point(size = 3.5) +
  scale_colour_brewer(palette = "Dark2") +
  scale_y_log10(
    breaks = c(1, 10, 100, 1000, 10000),
    labels = c("0", "10", "100", "1,000", "10,000")
  ) +
  labs(
    title = "Temporal Distribution of HIV Subtypes in Malawi",
    x = "Sampling Period",
    y = "Sequence Count (log10 scale)",
    colour = "Subtype"
  ) +
  theme_classic(base_size = 15) +
  theme(
    plot.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "right"
  )
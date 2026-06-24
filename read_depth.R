# Install ggplot2 if not already installed
install.packages("ggplot2")

# Load library
library(ggplot2)

# Read depth file
depth <- read.table("E:/HIV/depth.txt", header = FALSE)

# Rename columns
colnames(depth) <- c("Reference", "Position", "Depth")

# Check data imported correctly
head(depth)

# Basic summary statistics
summary(depth$Depth)
mean(depth$Depth)
median(depth$Depth)
min(depth$Depth)
max(depth$Depth)

# Percentage of genome covered at >=30x
percent_30x <- sum(depth$Depth >= 30) / nrow(depth) * 100
percent_30x

# Histogram of coverage distribution
ggplot(depth, aes(x = Depth)) +
  geom_histogram(bins = 50) +
  labs(
    title = "Coverage Distribution",
    x = "Read Depth",
    y = "Number of Positions"
  ) +
  theme_bw()

# Coverage across genome
ggplot(depth, aes(x = Position, y = Depth)) +
  geom_line() +
  labs(
    title = "Coverage Across HIV Genome",
    x = "Genome Position (bp)",
    y = "Read Depth"
  ) +
  theme_bw()

# Coverage across genome with 30x threshold
ggplot(depth, aes(x = Position, y = Depth)) +
  geom_line() +
  geom_hline(yintercept = 30, linetype = "dashed") +
  labs(
    title = "Coverage Across HIV Genome",
    x = "Genome Position (bp)",
    y = "Read Depth"
  ) +
  theme_bw()

# Log-scale coverage plot (useful if coverage varies greatly)
ggplot(depth, aes(x = Position, y = Depth + 1)) +
  geom_line() +
  scale_y_log10() +
  labs(
    title = "Log-Scaled Coverage Across HIV Genome",
    x = "Genome Position (bp)",
    y = "Read Depth (log10 scale)"
  ) +
  theme_bw()

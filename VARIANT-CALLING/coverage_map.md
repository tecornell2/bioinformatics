# BAM Coverage Map

```sh
library(tidyverse)

dat <- read_tsv(
  "CLPT1251_depth.txt",
  col_names = c("contig", "position", "depth"),
  show_col_types = FALSE
)


max(dat$depth)
min(dat$depth)

# number of positions with 0 depth
sum(dat$depth == 0, na.rm =T)

depth %>%
  summarise(
    pct_1x = mean(depth >= 1),
    pct_5x = mean(depth >= 5),
    pct_10x = mean(depth >= 10),
    pct_20x = mean(depth >= 20),
    pct_30x = mean(depth >= 30)
  )

# plot
ggplot(dat, aes(x = depth)) +
  geom_histogram(binwidth = 1, color = "black", fill = "steelblue") +
  labs(
    x = "Coverage (×)",
    y = "Number of positions",
    title = "Genome-wide coverage distribution"
  ) +
  theme_bw()
```

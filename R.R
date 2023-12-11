---
title: "Written Report Draft"
format: html
editor: source
author: "Prisha, Ilan, Felix"
date: "11/27/2023" 
execute: 
  warning: false
  message: false 
embed-resources: true
---




```{r load_packages}
#| message: false
#| warning: false
#| echo: false
# Load required libraries
library(tidyverse)  # Load the tidyverse package
library(tidymodels)
library(janitor)    # Load the janitor package 
library(vdemdata)   # Load the vdemdata package
library(readxl)     # Load the readxl 
library(ggplot2)    # Load the ggplot2 package 
library(infer)
library(knitr)
library(kableExtra)
library(png)

```



```{r load_data}
#| echo: false
#| warning: false
data("vdem")        # Load the 'vdem' dataset from the vdemdata package

# Read an Excel file
#whappy <- read_excel("wh_2023.xls")
whappy <- read_csv("data/wh_2023.csv") 
# Read data from the 'wh_2023.xls' Excel file and store it in the 'whappy' frame

# Clean up column names
whappy <- whappy %>%
  janitor::clean_names()  
# clean  column names using the janitor packages 
```


 

```{r tidy_whappy}
#| echo: false
#| warning: false


# Tidy and filter the data
# Selecting countries with the top and bottom 15%  median gdp per capita, 
#and tidying the world happiness dataset.
wh_tidy_upper <- whappy |>
  group_by(country_name) |> 
  summarise(median_gdp = median(log_gdp_per_capita),
            median_positive_affect = median(positive_affect, na.rm = TRUE)) |> 
  arrange(desc(median_gdp)) |> 
  mutate(country_name = if_else(country_name == "Hong Kong S.A.R. of China",
                                "China", country_name))

wh_tidy_upper <- wh_tidy_upper[1:25, ]
# splits the data so that we only have the top 15%

wh_tidy_lower <- whappy |>
  filter(!is.na(country_name) & !is.na(log_gdp_per_capita)) |>
  group_by(country_name) |> 
  summarise(median_gdp = median(log_gdp_per_capita),
            median_positive_affect = median(positive_affect)) |> 
  arrange(desc(median_gdp)) |> 
  mutate(country_name = if_else(country_name == "Hong Kong S.A.R. of China",
                                "China", country_name))

wh_tidy_lower <- tail(wh_tidy_lower, 25)
# splits the data so that we only have the bottom 15%
wh_tidy <- bind_rows(wh_tidy_upper, wh_tidy_lower)
# join the two data sets so that we have one data to work with

```
 
```{r tidy_vdem}
#| echo: false
#| warning: false

# Tidy and filter the V-Dem data
vdem_tidy <- vdem |>
# Select only the required variables from vdem
  select(  
    country_name, 
    year, 
    v2x_libdem
  ) |>
  filter(
    !is.na(year) &
    year >= 2007) |> 
  mutate(country_name = if_else(country_name == "United States of America", 
                                "United States", country_name))  
# for uniformity, United states of America was renamed to "United States" 


```

```{r join_data}
#| echo: false
#| warning: false
#| message: false

# Join the WHappiness and V-Dem datasets
joined_data <- left_join(wh_tidy, vdem_tidy, 
                         by = c("country_name"), 
                         relationship = "one-to-many") |>
  select(country_name, median_gdp, median_positive_affect, v2x_libdem)
# used left-join to retain only the countries we got from whappy 

# Rename the columns for consistency and readability
names(joined_data) <- c(
  "country_name",
 "median_gdp",
 "median_positive_affect", 
 "libdem"
)

# filtering joined data for only countries present in wh_tidy_upper
joined_upper <- filter(joined_data, country_name %in% wh_tidy_upper$country_name) |>
  group_by(country_name, median_gdp, median_positive_affect) |>
  summarise(median_libdem = median(libdem, na.rm = TRUE)) 

# filtering joined data for only countries present in wh_tidy_lower
joined_lower <- filter(joined_data, country_name %in% wh_tidy_lower$country_name) |>
  group_by(country_name, median_gdp, median_positive_affect) |>
  summarise(median_libdem = median(libdem, na.rm = TRUE)) |>
  filter(country_name != "Gambia") |>
  filter(country_name != "Congo (Kinshasa)") # removing countries with missing data

# bind the categorized dataframes vertically 
joined_median_data <- bind_rows(joined_upper, joined_lower)


# categorize median libdem and  median GDP per capita as high or low based on 
# defined conditions
final_data <- joined_median_data |>
  select(country_name, median_positive_affect, median_libdem) |>
  mutate(dem_index = if_else(median_libdem >= 0.5, "High", "Low"),
         dem_index = fct_relevel(dem_index, "High", "Low")) |>
  mutate(gdp_index = if_else(median_gdp >=10.64, "High", "Low"), 
         gdp_index = fct_relevel(gdp_index, "High", "Low"))

```

Calculating summary statistics for positive affect and liberal democracy index. 
```{r summary_stats}
#| echo: false
#| warning: false

# Define a function to generate summary statistics for a variable
gen_summary <- function(var) {
  joined_data |>
    # Group data by country
    group_by(country_name) |>
    # Calculate summary statistics for the specified variable
    summarise(
      min = min({{var}}, na.rm = TRUE),
      mean = mean({{var}}, na.rm = TRUE),
      median = median({{var}}, na.rm = TRUE),
      max = max({{var}}, na.rm = TRUE)
    ) |> 
    arrange(desc(mean))
}

# Generate summary statistics for various variables and store the results in separate data frames
positive_affect_summary <- gen_summary(median_positive_affect)
libdem_summary <- gen_summary(libdem)


# View the generated summary statistics
kable(positive_affect_summary, col.names = c("Country Name", "Min", "Mean", "Median", "Max")) |>
  kable_styling() |>
  scroll_box( height = "300px")

kable(libdem_summary, col.names = c("Country Name", "Min", "Mean", "Median", "Max")) |>
  kable_styling() |>
  scroll_box( height = "300px")

```



```{r positive_affect_vis}
#| message: false
#| eval: true
#| echo: false
#| warning: false
#| fig-cap: "A plot showing the variation of median positive affect accross 
#|           different countries. "
#| fig-alt: >
#|            " The first plot "A plot of median positive affect vs 
#|            country" displays the median positive affect scores for various 
#|            countries. Each bar represents a different country, color-coded 
#|            and labeled along the x-axis, with countries like Australia, 
#|            Bahrain, and China towards the left, and Sweden, Switzerland, and 
#|            the United States towards the right. The y-axis quantifies the 
#|            median positive affect, ranging from 0 to just over 0.8. The bars 
#|            seem to be ordered from the lowest to highest median positive 
#|            affect scores, illustrating a comparative view of these scores 
#|            across the countries displayed. The second plot "A plot of median 
#|            positive affect vs country," presents the median positive affect 
#|            scores for a selection of countries, predominantly from Africa, 
#|            with Afghanistan and Tajikistan also included. All bars are 
#|            uniformly colored in shades of red, despite the legend incorrectly 
#|            \indicating a 'yellow' fill. The bars represent countries listed on 
#|            the x-axis, such as Afghanistan, Burkina Faso, and Zimbabwe, among 
#|            others. The y-axis measures median positive affect, ranging from 0 
#|            to approximately 0.8. The chart allows for a visual comparison of 
#|            median positive affect across the countries shown."

  
  ggplot(wh_tidy_upper, mapping = aes(x = country_name, y = median_positive_affect, 
                                      fill = "color")) +
  geom_col() + 
  # to name the naming of countries in the y axis slant for easy readability
  scale_fill_manual(values = "#FFC107") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), 
                                   legend.position = "none") +
  labs(title = "A plot of median positive affect vs country", 
       x = "Country name", 
       y = " Median Positive affect")

  ggplot(wh_tidy_lower, mapping = aes(x = country_name, y = median_positive_affect, 
                                      fill = "color")) +
  geom_col() + 
  # to name the naming of countries in the y axis slant for easy readability
    scale_fill_manual(values = "#1E88E5") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), 
        legend.position = "none") +
  labs(title = "A plot of median positive affect vs country", 
       x = "Country name", 
       y = " Median Positive affect") +
    scale_color_viridis_d()

```

- A plot showing the distribution of median liberal democracy among the 
various countries 

```{r libdem_vis}
#| message: false
#| eval: true
#| echo: false
#| warning: false
#| fig-cap: "A plot of median libdem index vs country for high and low median 
#|           GDP per capita "
#| fig-alt: >
#|            " The first bar chart presented is titled "A plot of median libdem 
#|            vs country" and it shows the median liberal democracy index scores
#|             for various countries. The bars are color-coded, with each color 
#|             corresponding to a different country, as indicated in the legend 
#|             on the right. The x-axis lists the countries, which include 
#|             Australia, Austria, Bahrain, and others, extending to the United 
#|             Kingdom and the United States at the far right. The y-axis 
#|             represents the median liberal democracy index, ranging from 0 
#|             to just below 1. This visual representation allows for easy 
#|             comparison of the median libdem scores across the listed nations. 
#|             The second bar graph titled "A plot of median libdem vs country" 
#|             illustrates the median liberal democracy index scores for a range 
#|             of countries, primarily from Africa with the addition of 
#|             Afghanistan and Tajikistan. Each bar corresponds to a country, 
#|             with the color coding and names listed in the legend on the right 
#|             side of the graph. The countries, including Afghanistan, Benin, 
#|             and Zimbabwe, among others, are arrayed along the x-axis. The 
#|             y-axis measures the median liberal democracy index, ranging from 
#|             0 to just above 0.5. This visualization allows for a comparison o
#|             f the median libdem scores across the included countries."

  ggplot(joined_upper, mapping = aes(x = country_name, y = median_libdem, 
                                     fill = "color")) +
  geom_col() +
  scale_fill_manual(values = "#E66100") +
     # to name the naming of countries in the y axis slant for easy readability
  theme(axis.text.x = element_text(angle = 45, hjust = 1), 
        legend.position = "none") +
  labs(title = "A plot of median libdem index vs country", 
       x = "Country name", 
       y = " Median Libdem Index") +
  scale_color_viridis_d()
 
     ggplot(joined_lower, mapping = aes(x = country_name, y = median_libdem, 
                                     fill = "color")) +
  geom_col() +
  scale_fill_manual(values = "#1A85FF") +
     # to name the naming of countries in the y axis slant for easy readability
  theme(axis.text.x = element_text(angle = 45, hjust = 1), 
        legend.position = "none") +
  labs(title = "A plot of median libdem index vs country", 
       x = "Country name", 
       y = " Median Libdem Index") +
  scale_color_viridis_d()

```

```{r high_low_dem_index}
#| message: false
#| echo: false
#| eval: true
#| fig-cap: "No.of countries with low and high libdem"
#| fig-alt: >
#|            " The plot is a bar plot with the proportion of countries on the 
#|            y axis and the dem index categories on the x axis. From the plot, 
#|            among the 48 countries in the sample, a larger proportion of
#|             countries have had high liberal democrary throughout the years."
#|   
high_low_dem_index <- final_data |>
  group_by(dem_index) |> 
  filter(!is.na(dem_index)) |> # remove the NA values 
  count(dem_index) # count by dem_index for the plot 

ggplot(data = high_low_dem_index, mapping = aes(x = dem_index, 
                                                y = n, 
                                                fill = dem_index)) +
  geom_col() +
  scale_fill_viridis_d() +
  labs(title = "No.of countries with low and high libdem", 
       x = " Libdem index", 
       y = " Number of countries",
       fill = "Dem Index")
```


```{r dem_vis}
#| label: scatterplots
#| message: false
#| eval: true
#| echo: false
#| warning: false
#| fig-cap: "Median Libdem vs Median Positive Affect"
#| fig-alt: >
#|            " The scatter plot titled "Libdem" vs. Positive Affect displays 
#|            data points that represent the relationship between the liberal 
#|            democracy index (Libdem) and the positive affect index across 
#|            various countries. The x-axis labeled "Libdem" shows the liberal 
#|            democracy index scores ranging from 0 to around 0.8, and the y-axis 
#|            labeled "Positive Affect Index" shows scores from around 0.5 to 
#|            0.8. Each dot corresponds to a country's score, with the color of 
#|            the dot indicating the specific country, as referenced in the 
#|            legend on the right side of the graph. The spread and density of 
#|            dots across different levels of the Libdem index suggest variations 
#|            in how positive affect correlates with the level of liberal 
#|            democracy across these nations."

  # Create a scatter plot of libdem index vs positive affect 
  ggplot(data = joined_median_data,
         mapping = aes(x = median_libdem, y = median_positive_affect, colour = country_name)) +
    geom_point(na.rm = TRUE) +  # Add points to the plot
    labs(
      title = "Median Libdem vs Median Positive Affect",
      x = "Median Libdem", y = "Median Positive Affect",
      colour = "Country"
    ) +
    theme(legend.position = "NULL") +
    scale_color_viridis_d()  # Use the viridis color scale for the countries





```
## Results 

### Hypothesis Testing 

Null Hypothesis: There is no effect of liberal democracy index on positive
affect. $H_0: {d}^h = {d}^l$

Alternative Hypothesis: Higher liberal democracy indexes result in higher 
positive affect measures. $H_0: {d}^h > {d}^l$


```{r hypo_test}
#| echo: false
#| warning: false
#| message: false

# calculate the median positive affect and libdem for high and low GDP per 
# capita categories
 dem_median <- final_data |>
  group_by(dem_index, gdp_index) |>
  summarise(
    grouped_median_affect = median(median_positive_affect, na.rm = TRUE),
    grouped_median_libdem = median(median_libdem, na.rm = TRUE), 
    .groups = "keep"
  )

#find the observational statistic
low_gdp_stat = dem_median$grouped_median_affect[3] -
  dem_median$grouped_median_affect[1]

high_gdp_stat = dem_median$grouped_median_affect[4] -
  dem_median$grouped_median_affect[2]

include_graphics("/Users/prishas/Documents/CMPU144/Final-Project/Data analysis.png")

```
The observational statistic is calculated by subtracting the positive affect of 
countries with high median GDP per capita and high libdem from that of countries 
with low median GDP per capita and low libdem. The same is repeated for countries 
with low median GDP per capita.

The observational statistic for the high GDP per capita category is `r high_gdp_stat`. 

The observational statistic for the low GDP per capita category is `r low_gdp_stat`. 

```{r hypo_test_cont}
#| echo: false
#| warning: false
#| message: false

# Set a random seed for reproducibility
set.seed(142)
# Perform permutation testing to calculate the distribution of differences in medians for positive affect
# with dem_index as the explanatory variable
high_gdp_null_dem <- final_data %>%
  filter(!is.na(median_positive_affect) & !is.na(dem_index)) |> 
  filter(gdp_index == "High") |>
  specify(response = median_positive_affect, explanatory = dem_index) |> 
  hypothesize(null = "independence") |> 
  
  # Generate 1000 permutations of the data
  generate(reps = 1000, type = "permute") |> 
  
  # Calculate the statistic (difference in medians) for each permutation
  calculate(stat = "diff in medians", order = c("High", "Low")) 
# specifies order of dem_index factors


```

```{r low_null}
#| eval: false
#| echo: false
#| warning: false
#| message: false

# Set a random seed for reproducibility
set.seed(142)
# Perform permutation testing to calculate the distribution of differences in medians for positive affect
# with dem_index as the explanatory variable
low_gdp_null_dem <- final_data %>%
  filter(!is.na(median_positive_affect) & !is.na(dem_index)) |> 
  filter(gdp_index == "Low") |>
  specify(response = median_positive_affect, explanatory = dem_index) |>
  hypothesize(null = "independence") |>

   # Generate 1000 permutations of the data
  generate(reps = 1000, type = "permute") |>
   
  # Calculate the statistic (difference in medians) for each permutation
  calculate(stat = "diff in medians", order = c("High", "Low")) 
# specifies order of dem_index factors

```


```{r p_value }
#| echo: false
#| warning: false
#| message: false

p_val <- high_gdp_null_dem %>%
 filter(stat >= high_gdp_stat) %>%
#filter by values equal of greater than diff_med so that we see worst scenarios 
  summarise(p_value = n()/nrow(high_gdp_null_dem))

```
The p-value for high GDP per capita countries is `r p_val`. 

### Regression

#### Simple Regression
```{r simple_regression}
#| echo: false
#| warning: false
#| message: false

# simple regression between median positive affect and median libdem to show the main effect
# gdp_index is included to show any interaction effect 
simp_reg <- linear_reg() %>%
  set_engine("lm") %>%
  fit(median_positive_affect ~ gdp_index*median_libdem, data = final_data) %>%
  tidy()

kable(simp_reg, col.names = c("Term", "Estimate", "Std.Error", "Statistic", "p-value"))
```
#### Simple regression plot

```{r simp_reg_plot}
#| echo: false
#| warning: false
#| message: false
#| fig-cap: "Median Positive Affect vs Median Libdem Regression Plot"
#| fig-alt: >
#|            " The scatter plot visualizes the relationship between the median 
#|            liberal democracy index (median_libdem) on the x-axis and median
#|             positive affect on the y-axis, differentiated by GDP index levels. 
#|             Two distinct groups are represented by dots: those in the low GDP 
#|             index category (colored in orange) and those in the high GDP index
#|              category (colored in blue). Each dot represents a country's 
#|              median_libdem and median_positive_affect scores. Overlaid on 
#|              the scatter plot are two trend lines, one for each GDP category,
#|               indicating the direction of the relationship between median_libdem 
#|               and median_positive_affect. The blue line, representing high GDP 
#|               countries, shows a positive slope, suggesting that higher levels 
#|               of liberal democracy correlate with higher levels of positive 
#|               affect in these countries. The orange line, representing low GDP
#|                countries, has a flatter slope, indicating a weaker correlation
#|                 between liberal democracy and positive affect in this group."

# plotting a regression plot between median positive affect and median libdem, 
# colored by gdp index
ggplot(data = final_data, aes(x = median_libdem, y = median_positive_affect, color = factor(gdp_index))) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm", se = FALSE,
              fullrange = TRUE) +
  labs(
    title = "Median Positive Affect vs Median Libdem Regression Plot",
    x = "Median Libdem",
    y = "Median Positive Affect",
    color = "GDP index"
  ) +
  scale_color_manual(values = c("#E48957", "#071381")) 
```


### Multiple Regression

```{r multi_reg}
#| echo: false
#| warning: false
#| message: false

# regression between median positive affect and median libdem 
# with median GDP as an explanatory variable and dem_index for  
# possible interaction effect
multi_reg <- linear_reg() %>%
  set_engine("lm") %>%
  fit(median_positive_affect ~ dem_index*median_libdem + median_gdp, data = final_data) %>%
  tidy()

kable(multi_reg, col.names = c("Term", "Estimate", "Std.Error", "Statistic", "p-value"))
```

In order to analyse the effect of libdem index on positive affect within the high gdp and low gdp category, we calculated two observed statistics: one for each GDP category. The observed statistic was the difference in positive affect of High libdem countries and that of Low libdem countries within the high GDP (0.054) and low GDP category (-0.043), respectively. We then simulated null distributions of libdem index and positive affect within the two GDP categories; however, could only successfully do so for the high GDP category. This was due to the limited number of countries (n = 1) that were low GDP and high libdem. 

The p value for high GDP simulation is 0.002, allowing us to reject the null hypothesis. 

Upon conducting simple regression we found a positive main effect wherein for one unit increase in median libdem, positive affect increases by 0.036 when GDP index is constant. We also found an interaction effect where for one unit increase in median libdem, positive affect increases by 0.054 when GDP index is high.

Multiple regression analysis, where median GDP was an explanatory variable, revealed a main effect such that for one unit increase in median libdem, positive affect increased by 0.068 when libdem index and median GDP were constant. As well as an interaction effect where for one unit increase of median libdem, positive affect increased by 0.275 when libdem index was high. 





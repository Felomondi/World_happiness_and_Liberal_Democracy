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



## Methods 

### Load Packages 
```{r load_packages}
#| message: false
#| warning: false
# Load required libraries
library(tidyverse)  # Load the tidyverse package
library(janitor)    # Load the janitor package 
library(vdemdata)   # Load the vdemdata package
library(readxl)     # Load the readxl 
library(ggplot2)    # Load the ggplot2 package 
library(infer)
#library(colorblindr)


```


### Load Data 
```{r load_data}
data("vdem")        # Load the 'vdem' dataset from the vdemdata package

# Read an Excel file
#whappy <- read_excel("wh_2023.xls")
whappy <- read_excel("C:/Users/ilanb/OneDrive/Desktop/CMPU_144/data/wh_2023.xls") 
# Read data from the 'wh_2023.xls' Excel file and store it in the 'whappy' frame

# Clean up column names
whappy <- whappy %>%
  janitor::clean_names()  
# clean  column names using the janitor packages 
```


- We decided to go with the top 15 percentile (top 25) of countries with the 
highest median gdp for our project.  
```{r tidy_whappy}
# Tidy and filter the data

wh_tidy <- whappy |>
  group_by(country_name) |> 
  summarise(median_gdp = median(log_gdp_per_capita)) |> 
  arrange(desc(median_gdp)) |> 
  mutate(country_name = if_else(country_name == "Hong Kong S.A.R. of China",
                                "China", country_name))

wh_tidy <- wh_tidy[1:25, ]
# splits the data so that we only have the first 25 rows (top 15%)
#join the two data sets so that we have one data to work with 
wh_tidy <- left_join(wh_tidy, whappy, 
                     by = c("country_name"),
                     relationship = "one-to-many") |> 
  select(country_name, 
         year,
         median_gdp, 
         generosity, 
         positive_affect) #select the required variables 
wh_tidy



```
- Tidying the Vdem data 
```{r tidy_vdem}

# Tidy and filter the V-Dem data
vdem_tidy <- vdem |>
  # Select relevant columns for analysis
  select( #select only the required variables from vdem 
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

- We also joined the data so that we have a single uniform data set to work with 
```{r join_data}

# Join the WHappiness and V-Dem datasets
joined_data <- left_join(wh_tidy, vdem_tidy, 
                         by = c("country_name", "year"), 
                         relationship = "many-to-many")
# used left-join to retain only the countires we got from whappy 

  
# Rename the columns for consistency and readability
names(joined_data) <- c(
  "country_name",
  "year",
 "median_gdp",
  "generosity", 
 "positive_affect", 
 "libdem"
)

# View the joined and filtered data
joined_data

```


```{r summary_stats}
# Define a function to generate summary statistics for a variable
gen_summary <- function(var) {
  joined_data |>
    # Group data by country
    group_by(country_name) |>
    # Calculate summary statistics for the specified variable
    summarise(
      min_var = min({{var}}, na.rm = TRUE),
      mean_var = mean({{var}}, na.rm = TRUE),
      median_var = median({{var}}, na.rm = TRUE),
      max_var = max({{var}}, na.rm = TRUE)
    ) |> 
    arrange(desc(mean_var))
}

# Generate summary statistics for various variables and store the results in separate data frames
positive_affect_summary <- gen_summary(positive_affect)
generosity_summary <- gen_summary(generosity)
libdem_summary <- gen_summary(libdem)


# View the generated summary statistics
positive_affect_summary
generosity_summary
libdem_summary

```
- A plot to show the distribution of median positive affcet for each country. 

```{r positive_affect_vis}
#| message: false
#| eval: true
#| fig-cap: "A plot showing the variation of median positive affect accross 
#|           different countries. "
#| fig-alt: >
#|            " The plot is a scatterplot with county name in the x axis and the
#|             Median Positive Affect on the y axis. From the plot, we notice 
#|             that the countries with the highest positive affect seem to be 
#|             iceland, followed by Canada, Norway and Denmark. the countries
#|             with the lowest postive affect include Italy which has the lowest
#|             followed by Qatar, Singapore and China. "
#|  
positive_affect_summary |> 
  ggplot(mapping = aes(x = country_name, y = median_var, color = country_name)) +
  geom_point() + 
  # to name the naming of countries in the y axis slunt for easy readability
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "A plot of median positive affect vs country", 
       x = "Country name", 
       y = " Median Positive affect")

```
- A plot showing the distribution of generosity index levels among the countries. 

```{r generosity_vis}
#| message: false
#| eval: true
#| fig-cap: "A plot showing the variation median levels of generosity accross 
#|           different countries. "
#| fig-alt: >
#|            " The plot is a column plot with county name in the x axis and the
#|             Median generosity on the y axis. From the plot, we notice 
#|             that the countries with the highest levels of generosity seem to 
#|             be UK, Australia, netherlands and Iceland. the countries
#|             with the lowest generosity levels (negative levels) include 
#|             China, France, Saudi Arabia, Italy and Kuwait.  "
#|  
generosity_summary |> 
  ggplot(mapping = aes(x = country_name, y = median_var, fill = country_name)) +
  geom_col() + 
   # to name the naming of countries in the y axis slunt for easy readability
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  scale_color_viridis_d() + 
  labs(title = "A plot of Median generosity vs Country name", 
        x = "Country Name", 
       y = "Median Generosity")

```
- A plot showing the distribution of median liberal democracy among the 
various countries 

```{r libdem_vis}
#| message: false
#| eval: true
#| fig-cap: "A plot showing the variation median levels of liberal democracy accross 
#|           different countries. "
#| fig-alt: >
#|            " The plot is a column plot with county name in the x axis and the
#|             Median libdem on the y axis. From the plot, we notice 
#|             that the countries with the highest levels of libdem seem to 
#|             be Denmark, Sweden, Australia, Norway, US, and Switzerland. The countries
#|             with the lowest generosity levels (negative levels) include 
#|             Bahrain, China, Saudi Arabia, UAE, and Qatar "
#|  
libdem_summary |> 
  ggplot(mapping = aes(x = country_name, y = median_var, fill = country_name)) +
  geom_col() + 
     # to name the naming of countries in the y axis slunt for easy readability
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_color_viridis_d()

```


```{r dem_vis}
#| label: scatterplots
#| message: false
#| eval: true
#| fig-cap: "A plot to show the effect that democracy type has on the level of 
#|            happiness "
#| fig-alt: >
#|            " It is a scatterplot of Democracy type (libdem and Egaldem) vs the 
#|            positive Affect Index. The posotive affect Index is supposed to show     
#|            the level of happeniness of that specific country. 
#|            From the plot, we note that Countries with 
#|            moderate levele of Libdem have lower Positive affect Index, while 
#|            countries with high and low Libdem(China and Germany) have 
#|            relaitvely high positive affect. The same thing appplies for the 
#|            Egaldem vs Positive affect plot. 
#|            "

# Define a function to create scatter plots comparing a variable with the 
#Positive Affect Index
vdem_plots <- function(table, var) {
  # Remove rows where the variable of interest is missing
  table_filtered <- table |> 
    filter(!is.na(positive_affect))
 
  # Create a scatter plot
  ggplot(data = table_filtered,
         mapping = aes(x = .data[[var]], y = positive_affect, colour = country_name)) +
    geom_point(na.rm = TRUE) +  # Add points to the plot
    labs(
      title = paste0(str_to_title(deparse(substitute(var))), " vs. Positive Affect"),
      x = paste0(str_to_title(deparse(substitute(var)))), y = "Positive Affect Index",
      colour = "Country"
    ) +
    #facet_wrap("country_name") +
    scale_color_viridis_d()  # Use the viridis color scale for the countries
}

# Apply the vdem_plots function to the 'libdem' variable
vdem_plots(joined_data, "libdem")


```

## Hypothesis Testing 

```{r high_low}
final_data <- joined_data |>
  select(country_name, positive_affect, generosity, year, libdem) |>
  mutate(dem_index = if_else(libdem >= 0.5, "High", "Low")) 
# we decided to set the threshold to 0.5. Anything above that would be high 
# and vice versa. 

final_data
  
```

Null Hypothesis: There is no effect of liberal democracy index on positive
affect. $H_0: \hat{d}^h = \hat{d}^l$

Alternative Hypothesis: Higher liberal democracy indexes result in higher 
positive affect measures. $H_0: \hat{d}^h > \hat{d}^l$


```{r hypo_test}
# we first find the median of the positive effect and the median of libdem 
dem_median <- final_data |>
  filter(!is.na(positive_affect) & !is.na(libdem)) |> 
  group_by(dem_index) |>
  summarise(
    median_affect = median(positive_affect, na.rm = TRUE),
    median_dem = median(libdem, na.rm = TRUE)
  ) 
dem_median

# find the observational statistic 
obs_stat = dem_median$median_affect[dem_median$dem_index == "High"] -
  dem_median$median_affect[dem_median$dem_index == "Low"]
obs_stat
```

```{r hypo_test_cont}

# Set a random seed for reproducibility
set.seed(142)
# Perform permutation testing to calculate the distribution of differences in medians
null_dem <- final_data %>%
  filter(!is.na(positive_affect) & !is.na(dem_index)) |> 
  specify(response = positive_affect, explanatory = dem_index) |> 
  hypothesize(null = "independence") |> 
  
  # Generate 100 permutations of the data
  generate(reps = 1000, type = "permute") |> 
  
  # Calculate the statistic (difference in medians) for each permutation
  calculate(stat = "diff in medians", order = c("High", "Low")) # specifies order

# Display the results of the permutation test
null_dem
```

```{r p_value }
p_val <- null_dem %>%
 filter(stat >= obs_stat) %>%
#filter by values equal of greater than diff_med so that we see worst scenarios 
  summarise(p_value = n()/nrow(null_dem))
p_val
```
Since the p value is zero, it is less than our observational statistic, meaning
we are rejecting the null hypothesis. 

- A plot to show countries with high or low liberal democracy index according to 
our chosen threshold. 

```{r dem_index}
#| message: false
#| eval: true
#| fig-cap: "A bar plot showing the distribution of counties with high and low 
#|             libdem index according to ouyr threshold "
#| fig-alt: >
#|            " The plot is a bar plot with the country name on the y axis. The 
#|            plot if filled by dem_index indicating whether a country has 
#|            either low or high libdem index. From the distribution, we can see 
#|            that most countries have a high liberal democracy and just a few 
#|            do not. The few countries that have low liberal democracy include 
#|            UAE, Singapore, Saudi Arabia, Qatar, Kuwait, China and Bahrain."
#|    

dem_var <- final_data |>
select(country_name, dem_index) |>
    count(dem_index, country_name) |> #count by dem_index and country name
  filter(!is.na(dem_index)) # remove the missing values 

ggplot(dem_var, aes(y = country_name, fill = dem_index)) +
  geom_bar(na.rm = TRUE) +
  scale_fill_viridis_d() +
  labs(y = "Country",
    fill = "Democracy Type",
    title = "Democracy Variation per Country")
```
- The plot below is supposed to show the difference in the number of countries 
with high and low liberal democracy 

```{r high_low_dem_index}
#| message: false
#| eval: true
#| fig-cap: "A bar plot showing the proportions of countries with low and high 
#|            libdem index "
#| fig-alt: >
#|            " The plot is a bar plot with the proportion of countries on the 
#|            y axis and the dem index categories on the x axis. From the plot, 
#|            among the 25 countries that we worked with, more countries have 
#|            had high liberal democrary throughout the year and just a few did 
#|            not."
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
  labs(title = "A plot showing the count of countries with low and high libdem", 
       x = " libdem index", 
       y = " Number of countries")
```

# Results 

Our analysis of the 25 highest GDP countries revealed a notable positive correlation between the levels of liberal 
democracy and positive affect. Specifically, countries with higher liberal democracy indices generally exhibited greater positive affect. 
This correlation is statistically significant, as indicated by a p-value of 0, enabling us to confidently reject the null hypothesis. 
This suggests a strong relationship between higher liberal democracy indexes and increased levels of positive affect. Visual data analysis further 
supports these findings, with countries that have moderate to high liberal democracy ratings displaying a broader range of positive affect. 
This suggests a potential link between democratic freedom and individual well-being. However, it is important to note exceptions in the data, such as Bahrain, 
China, Qatar, Saudi Arabia, and the UAE. These countries, despite their lower liberal democracy scores, show varying levels of positive affect, 
indicating the influence of other factors besides democratic freedom.

# Discussion 

The scatter plot analysis of liberal democracy versus positive affect in our study demonstrated significant variability in positive affect at similar levels of democracy. 
This variability suggests that factors other than liberal democracy contribute to individual well-being. The broader implications of our findings suggest a 
complex interplay between democratic structures and societal happiness, especially in high GDP countries. While the study indicates a positive correlation between 
liberal democracy and positive affect, it also highlights the importance of considering other influences such as wealth inequality, cultural norms, and social policies.

However, our study is limited to high GDP countries and may not fully capture the dynamics present in lower-income nations. Future research could explore how the 
relationship between democracy and positive affect varies across different economic contexts, potentially offering a more comprehensive understanding of these dynamics. 
These findings could have practical applications in policy-making, emphasizing the importance of democratic structures in enhancing societal well-being. Nevertheless, 
it is crucial to approach these results with a critical perspective. While our findings suggest a correlation between liberal democracy and positive affect, 
it's important to acknowledge that correlation does not imply causation. Further longitudinal studies would be beneficial to understand the causality in this 
relationship more clearly. This reflection is vital for accurately interpreting the results and applying them in a broader societal context.

In light of this, however, it is important to remember that all of the countries in our sample are among the wealthiest, or at least display the highest GDPs. 
Additionally, it is important to keep in mind that the majority of high GDP countries possess a relatively high level of liberal democracy. It may be possible 
that this makes our results even more conclusive, but considering that our sample uses wealthy nations, it also may neglect to take into account the relationship 
between democracy and wealth inequality, which is likely another factor that affects an average citizen's ability to engage in altruistic behavior. 

Additionally, we must also keep in mind of the intangibility of the phenomena that the data attempts to quantify. It is important to remember that characteristics
such as altruism and democracy are very nuanced and difficult, if not impossible, to truly measure. Due to this, we question the World Happiness Study's ability to 
accurately represent the prevalence of altruism in different countries even though it may reveal some element of truth in its findings.  

The hypothesis testing we performed was appropriate, however, given these limitations. In running simulations, we sought to find the prevalence of our observed value 
across many hypothetical iterations of the data. In this, we got an idea of how connected positive affect and liberal democracy are in wealthy nations, and our P-value 
of 0 is significant. We have learned that it is possible that citizens of more democratic nations with high GDP are more likely to engage in altruistic behavior, which is not
an insignificant finding. We may also glean from this that the values of cultures which are more permissive of democracy may also be more likely to value altruism. However, 
we did not determine what exactly might lead to higher altruism in a culture- we have only provided one piece of the puzzle. 






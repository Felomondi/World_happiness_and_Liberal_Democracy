# World_happiness_and_Liberal_Democracy
Motivation and Context
The interplay between societal structures and individual well-being is a topic of growing interest within the social sciences. Recent studies, such as those published in the Journal of Positive Psychology, have begun to unravel how societal factors, including economic conditions and social support systems, influence personal happiness and altruism (Smith et al, 2022). This project aims to expand upon this existing research by specifically examining the relationship between the extent of a liberal democracy on positive affect.

Research Question and Expectations
The central research question of this study is: “Does the liberal democracy index of a country influence it’s positive affect?” We expect that countries with higher liberal democracy indexes will have higher median positive affect. This expectation is based on studies such as Potts (2016). It is also anticipated that factors such as a country’s economic status may affect these variables, correlating with higher or lower levels of positive affect.

Data Source, Collection, and Cases
The primary data sources are the World Happiness Report 2023 and the ‘vdemdata’ R package. The World Happiness Report, published by the United Nations Sustainable Development Solutions Network, gathers data annually through surveys conducted globally. It assesses individual well-being, considering factors like happiness, life evaluations, and emotional health. The survey methodology typically involves representative sampling in each country, ensuring that the data reflects a wide range of socio-economic and demographic groups.

The positive affect scores are determined by laugh, enjoyment, and engaging in interesting activities, and measured through the following questions from the Gallup World Poll: “Did you smile or laugh a lot yesterday?”, and “Did you experience the following feelings during A LOT OF THE DAY yesterday? How about Enjoyment?”, “Did you learn or do something interesting yesterday?”. The final score for each country is the national average of the self-reported responses.

The reported GDP per capita scores are from the World Development Indicators (WDI, version 17, metadata last updated on Jan 22, 2023). Since the GDP per capita in 2022 was not available at the time of publishing the GDP per capita scores from 2021 were extrapolated to 2022 based on forecasts from World Bank’s Global Economic Prospects.

The ‘vdemdata’ package offers comprehensive data on democratic structures, including detailed metrics on governance and economic indicators for various countries. This data is collated from multiple global sources, including government records, international organizations, and academic research. It undergoes rigorous quality checks and is updated regularly to reflect the most current information available. The variable in question for this study is the liberal democracy index.

Description of Relevant Variables
The outcome variable for this study is positive affect. Though there is a parameter called ‘Happiness score’ or ‘Subjective Well-Being’ in the report, positive affect was chosen for its direct, self-reported measurement of day-to-day happiness; on accounts of subjective well-being being possibly more dependent on personal factors than societal ones.

Key explanatory variables include:

Democracy Index: Liberal democracy index
GDP per capita
All observations comprise of data from the years 2007-2022.

Methods
Data Wrangling and Tidying
The data wrangling process involved several steps to prepare the datasets for analysis. We began by selecting countries with the top and bottom 15% GDP per capita as found in the World Happiness (whappy) dataset: categorized as ‘wh_tidy_upper’ and ‘wh_tidy_lower’. These countries were, later on, further categorized as “high” and “low” GDP countries wherein countries with a median GDP per capita higher than the lowest median GDP per capita value from the top 15% were considered “high” GDP, and all others “low”. We then calculated the median positive affect for each country during the time period of 2007-2022. We chose to use the median values for both explanatory variables as examining their relationship across a span of 15 years would require extensive analyses.

These dataframes were then combined with data from the ‘vdemdata’ package, ensuring alignment on country.The liberal democracy index variable (libdem), in the vdem dataset, was transformed to better suit the analytical approach, by categorizing countries as high or low libdem index based on the calculated median libdem index for each country for the time period 2007-2022; where a libdem index of 0.5 or higher was consider “high”, and all else “low”. This condition is due to the scale of measurement being 0-1, and wanting to choose the mid-point. Missing values were removed (e.g all observations for Gambia and Congo); column names and country names were corrected to be consistent (e.g USA and United States of America) and fit ‘tidy’ conventions.

Planned Analytical Approach and Variable Inclusion
The study aims to employ statistical models to scrutinize the relationship between liberal democracy index and positive affect in the countries with the world’s top and bottom 15% GDP per capita.

The rationale for including democracy index as a key explanatory variable stems from its theoretical significance, as substantiated in existing literature. Thus, this study will pay special attention to the liberal democracy index of each nation as estimated and collected by V-Dem.

Despite their similar trajectories in economic status, within the defined categories ‘wh_tidy_upper’ and ‘wh_tidy_lower’, these countries exhibit notable differences in their democratic structures. Given the established impact of economic status (Williams, 2021) on societal happiness, our research seeks to delve into how a country’s liberal democratic index, might influence it’s societal happiness within our defined categories of high and low GDP per capita.

Additionally, C. Williams’s 2021 research in the Economic Journal underscored the influence of GDP on societal happiness, a finding that has significantly informed our decision to focus on these varied GDP per capita countries. In doing so, we will be able to empirically explore the effect of GDP per capita on the relationship between libdem index and positive affect.

The analysis will encompass data spanning from 2007 to 2022, a period during which the selected countries have consistently participated in both the V-Dem and World Happiness surveys.

To address the research question, the study will conduct hypothesis testing regression analyses. The alternative hypothesis posits that countries with a higher liberal democracy index are likely to exhibit higher levels of median positive affect. This hypothesis is informed by findings from Ward’s 2019 study, which suggests that happier individuals are more inclined to participate in voting - a vital pillar of a liberal democracy.

In summary, this study aims to provide a comprehensive analysis of how liberal democracy indexes impact individual positive affect, utilizing a data-driven approach and robust, multidimensional datasets.

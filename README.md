# World_happiness_and_Liberal_Democracy


# Introduction and Data 

#### Introduction

#### Motivation and Context

The interplay between societal structures and individual well-being is a topic 
of growing interest within the social sciences. Recent studies, such as those 
published in the Journal of Positive Psychology, have begun to unravel how 
societal factors, including economic conditions and social support systems, 
influence personal happiness and altruism (Smith, A., & Johnson, B. (2022). 
Journal of Positive Psychology, 17(3), 234-245). This project aims to expand 
upon this existing research by specifically examining the effects of societal 
structures on positive affect, generosity, and social support.

#### Research Question and Expectations

The central research question of this study is: "Do societal structures 
influence positive affect, generosity, and social support in different 
countries?" It is anticipated that factors such as a country's economic status 
and its societal framework significantly affect these variables, correlating 
with higher or lower levels of positive affect and altruism.

#### Data Source, Collection, and Cases

The primary data sources are the World Happiness Report 2023 and the 'vdemdata' 
R package. The World Happiness Report, published by the United Nations 
Sustainable Development Solutions Network, gathers data annually through surveys
conducted globally. It assesses individual well-being, considering factors like
happiness, life evaluations, and emotional health. The survey methodology 
typically involves representative sampling in each country, ensuring that the 
data reflects a wide range of socio-economic and demographic groups.

The 'vdemdata' package offers comprehensive data on societal structures, 
including detailed metrics on governance and economic indicators for various 
countries. This data is collated from multiple global sources, including 
government records, international organizations, and academic research. 
It undergoes rigorous quality checks and is updated regularly to reflect the 
most current information available.

#### Description of Relevant Variables

The outcome variables for this study are:
- Positive affect
- Generosity
- Social support

These were chosen for their direct measurement of happiness and altruistic 
behavior. Key explanatory variables include:
- Country: Top 5 GDP countries (USA, China, Japan, Germany, India)
- Societal structure: Liberal democracy 
- Year: 2007 - 2022

#### Data Wrangling and Tidying

The data wrangling process involved several steps to prepare the datasets for 
analysis:
- Merging: Data from the World Happiness Report and 'vdemdata' package were 
combined, ensuring alignment on country and year.
- Cleaning: Missing values were addressed, and outliers were examined for 
validity.
- Standardization: Formats were standardized to enable accurate cross-country
comparisons.
- Transformation: Some variables were transformed to better suit the analytical
approach, such as categorizing countries based on income levels.

#### Planned Analytical Approach and Variable Inclusion

The study aims to employ statistical models to scrutinize the relationships 
between societal structures and specific outcome variables in the countries 
with the world's top five GDPs: the USA, China, Japan, Germany, and India. 
The rationale for including societal structure as a key explanatory variable 
stems from its theoretical significance, as substantiated in existing 
literature. Notably, C. Williams's 2021 research in the Economic Journal 
underscored the influence of GDP on societal happiness, a finding that has 
significantly informed our decision to focus on these top GDP countries. 
Additionally, this study will pay special attention to the  liberal democracy 
index of each nation as estimated and collected by V-Dem. Despite their similar 
trajectories in economic growth, these countries exhibit notable differences in 
their democratic structures. Given the established impact of economic success 
(GDP) on societal happiness, our research seeks to delve into how different 
societal structures, particularly democratic indices, might influence societal 
happiness.

The study will evaluate societal structure through various aspects, such as the
integrity of voting rights in free and fair elections, and the freedoms of 
association and expression, using expert assessments and data from the V-Dem 
index. The analysis will encompass data spanning from 2007 to 2022, a period 
during which the selected countries have consistently participated in both the
V-Dem and World Happiness surveys.

To address the research question, the study will conduct hypothesis testing. 
The alternative hypothesis posits that countries with a higher liberal democracy
index are likely to exhibit higher levels of median positive affect and 
generosity, in contrast to other forms of democracies. This hypothesis is 
informed by findings from Ward's 2019 study, which suggests that happier 
individuals are more inclined to participate in voting. 



In summary, this study aims to provide a comprehensive analysis of how societal
structures impact individual well-being and altruism, utilizing a data-driven 
approach and robust, multidimensional datasets.

# HDI Regression Analysis

A data-driven study of HDI beyond its core components using a linear regression model.

## Project Overview
This project explores how the Human Development Index (HDI) is influenced by various factors across most countries in 2020.  
The goal is to investigate whether additional variables (beyond those used in the official HDI calculation) can help explain differences in human development.

---

## Dataset Description
- **HDI data**: published annually by the United Nations Development Programme (UNDP). https://hdr.undp.org/data-center/documentation-and-downloads  
- **Global indicators**: collected from the World Bank database. https://datatopics.worldbank.org/world-development-indicators/

After cleaning, the dataset includes 177 countries. Some countries were removed due to excessive missing values, while others were completed using MissForest, a random forest-based imputation algorithm. Density checks before and after imputation showed no significant differences.

The dataset contains significantly fewer variables than the original dataset (see the preliminary analysis script). However, the final version ("Final Dataset") was obtained through additional reductions not documented in the script, and is therefore smaller than the dataset resulting from the preliminary analysis. 

---

## HDI Background
The Human Development Index (HDI) is the geometric mean of normalized indices across three dimensions:
- **Health**: life expectancy at birth  
- **Education**: mean years of schooling (25+) and expected years of schooling at school-entry age  
- **Standard of living**: gross national income per capita

---

## Methodology
- Examined potential predictors from education, health, social, economic, and environmental domains  
- Selected 10 relevant predictors to start the analysis  
- Applied linear regression models to study how these variables influence the HDI  

This project workflow includes:
1. Data cleaning  
2. Exploratory data analysis 
3. Data visualization  
4. Variable selection  
5. Regression analysis  

---
## Repository Structure:
In this repository you will find:
- R Markdown scripts containing all the necessary code to perform exploratory analysis, specify the model, carry out variable selection according to specific criteria, conduct result diagnostics, and generate plots and tables. Each script includes comments and interpretation of the results (mostly based on the graphical output, see the PDF for details).
- PDF report with the most relevant code excerpts, data visualizations, plots, and a detailed discussion of the findings.
- The dataset used to start the project
- Preliminary analysis to reduce the dataset's dimensionality (as the original dataset was very large), based on missing values and correlations. Additionally, some checks were performed after imputing missing values.
- README file providing an overview of the entire project.

## Requirements
Packages: `openxlsx`,`dplyr`, `ggplot2`, `gridExtra`, `GGally`, `leaps`, `knitr`, `kableExtra`, `car`, `tidygeocoder`, `sf`, `tibble`, `broom`, `effects`

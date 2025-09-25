library(tidyr)
library(dplyr)
library(naniar)
library(missForest)
library(car)
library(janitor)
library(corrplot)
library(writexl)
library(openxlsx)

data <- read.csv(file.choose(), sep = ";", header = TRUE) #world indicators dataset
data_cleaned <- data[, c("Country.Name", "Indicator.Name", "X2020")]

# Transform the dataset into wide format
data_transformed <- data_cleaned %>%
  pivot_wider(
    names_from = Indicator.Name,  # Indicators become headers
    values_from = X2020           # Data from column X2020 become the content
  )

# I excluded some countries because of an insufficient number of observations.
Excluded_countries <- c(
  "American Samoa", "Aruba", "Bermuda", "British Virgin Islands", "Cayman Islands", 
  "Channel Islands","Curacao", "Gibraltar", "Greenland", "Kosovo", "Macao SAR, China", 
  "New Caledonia", "Northern Mariana Islands", "Puerto Rico", "Turks and Caicos Islands"
)

data_filtered <- data_transformed %>%
  filter(!(Country.Name %in% Excluded_countries))
data_filtered[data_filtered == ""] <- NA

# Some checks of NAs 
na_counts <- colSums(is.na(data_filtered))
print(na_counts)
na_percent <- (na_counts / nrow(data_filtered)) * 100

na_summary <- data.frame(
  Column = names(na_counts),
  NA_Count = na_counts,
  NA_Percent = na_percent
)

na_summary <- na_summary[order(na_summary$NA_Count, decreasing = TRUE), ]
print(na_summary)

colnames(data_filtered) <- paste0(seq_along(colnames(data_filtered)), "_", colnames(data_filtered))
print(colnames(data_filtered))

data_filtered2 <- data_filtered[, -c(4,5,6,7,8,10,14,15,19,21,22,23,24,25,26,28,33,34,35,36,
                                      37,38,39,40,41,42,43,44,45,54,55,56,62,64,66,67,68,69,
                                      73, 78, 79, 87, 90, 91, 92, 97, 98, 105, 106, 107,
                                      108, 109, 110, 111, 112, 113, 114, 115, 117, 120,
                                      137, 138, 139, 140, 141, 142,143,144, 146, 148, 151,152)]

na_counts2 <- rowSums(is.na(data_filtered2))
print(na_counts2)

na_by_country<- rowSums(is.na(data_filtered2))
na_by_variables <- colSums(is.na(data_filtered2))

na_summary <- list(
  NA_Country = na_by_country,
  NA_Variables = na_by_variables
)
print(na_summary)
na_counts <- colSums(is.na(data_filtered2))
print(na_counts)
na_dataset <- data.frame(na_counts)
colnames(data_filtered2) <- paste0(seq_along(colnames(data_filtered2)), "_", colnames(data_filtered2))

data_filtered3 <- data_filtered2[, -c(2,4,6,7,8,10,13,14,15,16,24,27,29,30,33,35,36,37,40,41,42,43,44,
                                      45,49,51,53,54,55,56,57,62,63,64,65,66,72,74,76,78)]

na_counts_row <- rowSums(is.na(data_filtered3))
data.frame(Country = data_filtered3[[1]],
           NA_count = na_counts_row)

data_filtered4 <- data_filtered3[-c(4,55,68,91,101,110,114,116,123,134,147,160,
                                    163,181,190,192),]

# Following an assessment of the NA values, I excluded some countries and variables, 
# resulting in a dataset with 178 observations and 40 variables.

# Removing numbers, special characters, and spaces
colnames(data_filtered4) <- gsub("[0-9]+", "", colnames(data_filtered4))
colnames(data_filtered4) <- gsub("^[_]+", "", colnames(data_filtered4))
colnames(data_filtered4) <- gsub(" ", "_", colnames(data_filtered4))      

data_filtered4[, -1] <- lapply(data_filtered4[, -1], function(x) as.numeric(gsub(",", ".", as.character(x))))

# Some changes in the Dataset
# I have created food trade balance as the difference between food exports and food imports
data_filtered4$Food_trade_balance <- data_filtered4$"Food_exports_(%_of_merchandise_exports)" - data_filtered4$"Food_imports_(%_of_merchandise_imports)"

# In the same way as before I created foreign direct investment net balance
data_filtered4$Foreign_direct_investment_net_balance <- data_filtered4$"Foreign_direct_investment,_net_inflows_(%_of_GDP)"-
  data_filtered4$"Foreign_direct_investment,_net_outflows_(%_of_GDP)"

# Goods and services trade balance
data_filtered4$Goods_and_services_trade_balance <- data_filtered4$"Exports_of_goods_and_services_(%_of_GDP)"-
  data_filtered4$"Imports_of_goods_and_services_(%_of_GDP)"

# Services net balance
data_filtered4$Services_net_balance <- data_filtered4$"Service_exports_(BoP,_current_US$)"-
  data_filtered4$"Service_imports_(BoP,_current_US$)"

# I combined "survival to age 65 (male)" and "survival to age 65 (female)" into a single variable by computing their mean
data_filtered4$Survival_to_65 <- rowMeans(data_filtered4[, c("Survival_to_age_,_female_(%_of_cohort)", "Survival_to_age_,_male_(%_of_cohort)")], na.rm = TRUE)

# So, I reduced more the number of variables
data_filtered4 <- data_filtered4[, -c(7,8,9,10,11,14,32,33,34,35)]

vis_miss(data_filtered4) # to visualize missing values

# I imputed the missing values using MissForest
data_imputation <- data_filtered4[, !colnames(data_filtered4) %in% c("Country.Name")]
imputed_data <- missForest(data_imputation)
data_imputed <- cbind(Country.Name = data_filtrato8$Country.Name, imputed_data$ximp)


# HDI Dataset
HDI <- read.csv(file.choose(), sep = ";", header = TRUE)

hdi_2020 <- HDI[HDI$year == 2020, ]
hdi_2020 <- hdi_2020[, c("countryIsoCode", "country", "value")]
HDI2 <- hdi_2020[-c(53,102,113,60,132,139,144,94,156,158,177,185,189,111,
                    193,194,195,196,197,198,199,200,201,202,203,204,205,206,207), ]

HDI3$Row_Number <- seq_len(nrow(HDI3))

HDI2[34,2] <- "Cote d'Ivoire"

HDI3 <- HDI2[-(4), ]
HDI3 <- HDI3[,-4]

HDI3 <- rbind(HDI3, data.frame(countryIsoCode= "MDV", Country.Name= "Maldives", 
                               value = 0.737))

colnames(HDI2)[2] <- c("Country.Name")

HDI3$Country.Name[c(22, 35, 36, 152, 78, 91, 93, 104, 165, 171, 97)] <- c("Bolivia", "Congo, Dem. Rep.","Congo, Rep.",
                                                                          "Eswatini", "Iran, Islamic Rep.", "Korea, Rep.",
                                                                          "Lao PDR", "Moldova", "Tanzania", "St. Vincent and the Grenadines",
                                                                          "St. Lucia")

data_imputed$Country.Name <- as.character(data_imputed$Country.Name)
data_imputed$Country.Name[c(11, 51, 61, 72, 90, 144, 166)] <- c("Bahamas", "Egypt", "Gambia", 
                                                                "Hong Kong, China (SAR)", 
                                                                "Kyrgyzstan", "Slovakia", "Turkey")

# Merge of the two datasets
final_dataset <- full_join(HDI3, data_imputed, by = "Country.Name")
final_dataset <- final_dataset[-179, ]
colnames(final_dataset)[colnames(final_dataset) == "value"] <- "Hdi"
final_dataset <- final_dataset[,-4]
final_dataset$Hdi <- gsub(",", ".", final_dataset$Hdi)
final_dataset$Hdi <- as.numeric(final_dataset$Hdi)
Dataset <- final_dataset


# In order to remove more variables I look for correlation
# Correlation matrix
cor_matrix <- cor(Dataset[, -c(1,2,3)], use = "complete.obs")  

high_corr <- which(abs(cor_matrix) > 0.9, arr.ind = TRUE)
high_corr <- high_corr[high_corr[, 1] != high_corr[, 2], ]  
print(high_corr)

write.csv(cor_matrix, "correlation_matrix.csv")

Dataset$Basic_services <- rowMeans(Dataset[, c("People_using_at_least_basic_drinking_water_services_(%_of_population)", 
                                               "People_using_at_least_basic_sanitation_services_(%_of_population)")], na.rm = TRUE)

Dataset <- Dataset %>%
  select(-`people_using_at_least_basic_sanitation_services_percent_of_population`)

Dataset <- Dataset %>%
  select(-`countryIsoCode`)

Dataset <- Dataset %>%
  select(-`Total_alcohol_consumption_per_capita_(liters_of_pure_alcohol,_projected_estimates,_+_years_of_age)`)

correlation_with_HDI <- cor(Dataset$Hdi, Dataset[, c("Control_of_Corruption:_Estimate", 
                                                     "Government_Effectiveness:_Estimate", 
                                                     "Political_Stability_and_Absence_of_Violence/Terrorism:_Estimate", 
                                                     "Regulatory_Quality:_Estimate", 
                                                     "Rule_of_Law:_Estimate")], use = "complete.obs")
print(correlation_with_HDI)

# Clean column names
Dataset <- clean_names(Dataset)

# I try to implement a model on some variables just to look for vif values
model <- lm(hdi ~ control_of_corruption_estimate + 
              government_effectiveness_estimate + 
              political_stability_and_absence_of_violence_terrorism_estimate + 
              regulatory_quality_estimate + 
              rule_of_law_estimate, data = Dataset)

summary(model)

vif_values <- vif(model)
print(vif_values)

Dataset <- Dataset %>%
  select(-c(`rule_of_law_estimate`, `control_of_corruption_estimate`, `political_stability_and_absence_of_violence_terrorism_estimate`))

model2 <- lm(hdi ~  government_effectiveness_estimate + regulatory_quality_estimate, data = Dataset)

summary(model2)

vif_values2 <- vif(model2)
print(vif_values2)

correlation_with_HDI2 <- cor(Dataset$hdi, Dataset[, c( "government_effectiveness_estimate", 
                                                       "regulatory_quality_estimate")], use = "complete.obs")

model3 <- lm(hdi ~ life_expectancy_at_birth_total_years + maternal_mortality_ratio_modeled_estimate_per_live_births +
               mortality_rate_infant_per_live_births + survival_to_65, data = Dataset)
summary(model3)
vif_values3 <- vif(model3)

correlation_with_HDI3 <- cor(Dataset$hdi, Dataset[, c("life_expectancy_at_birth_total_years", "maternal_mortality_ratio_modeled_estimate_per_live_births", 
                                                      "mortality_rate_infant_per_live_births", "survival_to_65")], use = "complete.obs")

Dataset <- Dataset %>%
  select(-c('life_expectancy_at_birth_total_years', 'mortality_rate_infant_per_live_births'))

model4 <- lm(hdi ~ maternal_mortality_ratio_modeled_estimate_per_live_births + survival_to_65, data = Dataset)
summary(model4)
vif_values4 <- vif(model4)

model5 <- lm(hdi ~ individuals_using_the_internet_percent_of_population +
               vulnerable_employment_total_percent_of_total_employment_modeled_ilo_estimate +
               basic_services, data = Dataset)
summary(model5)
vif_values5 <- vif(model5)

Dataset2 <- Dataset
Dataset_numeric <- Dataset2[, !names(Dataset2) %in% "country_name"]

cor_matrix <- cor(Dataset_numeric, use = "pairwise.complete.obs")
cor_matrix[abs(cor_matrix) < 0.65] <- NA

corrplot(cor_matrix, method = "color", tl.col = "black", na.label = " ", tl.cex = 0.35)


modelAll <- lm(hdi ~ ., data = Dataset)
summary(modelAll)

vif_valuesAll <- vif(modelAll)
Dataset2 <- Dataset2 %>%
  select(-'labor_force_participation_rate_total_percent_of_total_population_ages_modeled_ilo_estimate')

Dataset2$country_name <- country_name


data_filtered4$Country.Name <- as.character(data_filtered4$Country.Name)
data_filtered4$Country.Name[c(11, 51, 61, 72, 90, 144, 166)] <- c("Bahamas", "Egypt", "Gambia", 
                                                                  "Hong Kong, China (SAR)", "Kyrgyzstan", "Slovakia", "Turkey")


# I created a separate dataset to compare it with the original dataset prior to 
#the imputation of missing values

dataset_for_comparison <- data.frame(Country.Name = dataset_for_comparison)
dataset_for_comparison <- full_join(HDI3, data_filtered4, by = "Country.Name")
dataset_for_comparison <- dataset_for_comparison[-179,]

colnames(dataset_for_comparison)[colnames(dataset_for_comparison) == "value"] <- "Hdi"
dataset_for_comparison <- dataset_for_comparison[,-4]
dataset_for_comparison$Hdi <- gsub(",", ".", dataset_for_comparison$Hdi)
dataset_for_comparison$Hdi <- as.numeric(dataset_for_comparison$Hdi)

dataset_for_comparison$Basic_services <- rowMeans(dataset_for_comparison[, c("People_using_at_least_basic_drinking_water_services_(%_of_population)", 
                                                                 "People_using_at_least_basic_sanitation_services_(%_of_population)")], na.rm = TRUE)
dataset_for_comparison <- dataset_for_comparison %>%
  select(-c(`People_using_at_least_basic_sanitation_services_(%_of_population)`,
            `People_using_at_least_basic_drinking_water_services_(%_of_population)`))

dataset_for_comparison <- dataset_for_comparison %>%
  select(-`countryIsoCode`)

dataset_for_comparison <- dataset_for_comparison %>%
  select(-`Total_alcohol_consumption_per_capita_(liters_of_pure_alcohol,_projected_estimates,_+_years_of_age)`)

dataset_for_comparison <- clean_names(dataset_for_comparison)

dataset_for_comparison <- dataset_for_comparison %>%
  select(-c(`rule_of_law_estimate`, `control_of_corruption_estimate`, `political_stability_and_absence_of_violence_terrorism_estimate`))

dataset_for_comparison <- dataset_for_comparison %>%
  select(-c('life_expectancy_at_birth_total_years', 'mortality_rate_infant_per_live_births'))

dataset_for_comparison <- dataset_for_comparison %>%
  select(-'labor_force_participation_rate_total_percent_of_total_population_ages_modeled_ilo_estimate')

dataset_for_comparison <- dataset_for_comparison[-67,] #original dataset
Dataset2 <- Dataset2[-67,] #imputed dataset


# Density checks for all variables after the imputation
numerical_variables <- names(dataset_for_comparison)[sapply(dataset_for_comparison, is.numeric)]
imputated_variables <- numerical_variables[sapply(numerical_variables, function(var) {
  any(is.na(dataset_for_comparison[[var]])) 
})]

par(mfrow = c(2, 2), mar = c(4, 4, 2, 1), bty = "l")

pdf("density_comparison.pdf", width = 10, height = 7)

for (var in imputated_variables) {
  ylim_max <- max(density(na.omit(dataset_for_comparison[[var]]))$y,
                  density(na.omit(Dataset2[[var]]))$y)
  
  xlim_range <- quantile(Dataset2[[var]], probs = c(0.01, 0.99), na.rm = TRUE)
  
  plot(x = dataset_for_comparison[[var]], y = rep(0, nrow(dataset_for_comparison)), pch = 16, col = "black",
       main = var, xlab = var, ylab = "Density", xlim = xlim_range, ylim = c(0, ylim_max))
 
  lines(density(na.omit(dataset_for_comparison[[var]])), col = "black", lwd = 2)
  
  lines(density(na.omit(Dataset2[[var]])), col = "red", lwd = 2)
  
  points(x = Dataset2[[var]][is.na(dataset_for_comparison[[var]])],
         y = rep(0, sum(is.na(dataset_for_comparison[[var]]))), pch = 16, col = "red")
}

dev.off()

# Scatter plots
pdf("scatterplots_imputation_ggplot_corrected.pdf", width = 8, height = 6)
for (var in imputated_variables) {
  cat("Variable:", var, "\n")
  
  imputed_values <- Dataset2[is.na(dataset_for_comparison[[var]]), ]
  
  if (nrow(imputed_values) == 0) {
    cat("No imputed values for:", var, "\n")
    next
  }
  
  p <- ggplot() +
    # original points
    geom_point(
      data = dataset_for_comparison[!is.na(dataset_for_comparison[[var]]), ],
      aes_string(x = var, y = "hdi"),
      color = "black", size = 2
    ) +
    # imputed values
    geom_point(
      data = imputed_values,
      aes_string(x = var, y = "hdi"),
      color = "red", size = 2
    ) +
   
    labs(
      title = paste("Distribution of", var, "vs HDI"),
      x = var, y = "HDI"
    ) +
 
    theme_minimal()

  print(p)
}
dev.off()

# Saving of the reduced dataset
Dataset2 <- Dataset2[,-29]
Dataset2 <- Dataset2[, c("country_name", "hdi", setdiff(names(Dataset2), c("country_name", "hdi")))]
write_xlsx(Dataset2, "Dataset2.xlsx")





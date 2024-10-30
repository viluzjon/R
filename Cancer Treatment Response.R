# Load libraries
library(wesanderson)
library(pastecs)
library(PerformanceAnalytics)

# Read the data
cancer_url <- "https://raw.githubusercontent.com/viluzjon/R/refs/heads/main/treatment_response_development.csv"
cancer <- read.csv(cancer_url)

# Overview of the dataset
summary(cancer)
str(cancer)

# Remove the "X" variable
cancer <- cancer[,-1]

# Age - identify errors such as NA and negative age values
summary(factor(cancer$Age))

# Calculate the median age (ignoring NA values)
median(cancer$Age, na.rm = TRUE)

# Fill in missing and negative age values with the median
cancer$Age[is.na(cancer$Age) | cancer$Age < 0] <- median(cancer$Age, na.rm = TRUE)

# Check for remaining NA values in Age
cancer$Age[is.na(cancer$Age)]

# Identify any rows with missing values
cancer[!complete.cases(cancer),]

# Sum of NA values per column
colSums(is.na(cancer))

# Check for duplicated values in the index and ID variables
sum(duplicated(cancer$index))
sum(duplicated(cancer$ID)) # 148 duplicated IDs

# Display a few duplicate rows in the dataset
head(cancer[duplicated(cancer$ID),])

# Remove duplicated data based on the ID variable
cancer <- cancer[!duplicated(cancer$ID),]

# Check for blank fields in the dataset and replace with NA
summary(cancer[cancer == ''])
cancer[cancer == ''] <- NA

# Recheck for NA values per column
colSums(is.na(cancer))

# Tumor_type: Find and fix any typos
summary(factor(cancer$Tumor_type))
cancer$Tumor_type[cancer$Tumor_type == "adinocarcinoma"] <- "adenocarcinoma"

# Remove rows with missing values in Tumor_type
cancer <- cancer[!is.na(cancer$Tumor_type),]

# Remove rows with missing values in Overall_stage
cancer <- cancer[!is.na(cancer$Overall_stage),]

# For missing values in Sex, fill with 'prefer not to say'
cancer$Sex[is.na(cancer$Sex)] <- "prefer not to say"

# Identify any remaining NA values in ID and replace with "no_id"
cancer$ID[is.na(cancer$ID)] <- "no_id"

# Convert variables to factors

# Tumor_type
cancer$Tumor_type <- factor(cancer$Tumor_type)

# Sex
cancer$Sex <- factor(cancer$Sex)

# Differentiation_grade: Map "X" to "G4" as in dataset description
cancer$Differentiation_grade[cancer$Differentiation_grade == "X"] <- "G4"
cancer$Differentiation_grade <- factor(cancer$Differentiation_grade,
                                       levels = c("G1", "G2", "G3", "G4", "Gx"),
                                       labels = c("well differentiated", "somewhat differentiated", 
                                                  "hardly differentiated", "undifferentiated", "cannot be measured"),
                                       ordered = TRUE)

# T_stage
cancer$T_stage <- factor(cancer$T_stage,
                         levels = c("T1", "T2", "T3", "T4"),
                         labels = c("small", "medium", "big", "very big"),
                         ordered = TRUE)

# N_stage
cancer$N_stage <- factor(cancer$N_stage,
                         levels = c("N0", "N1", "N2", "N3"),
                         labels = c("not found", "1 lymph node", 
                                    "2 lymph nodes", "3 lymph nodes"),
                         ordered = TRUE)

# M_stage
cancer$M_stage <- factor(cancer$M_stage,
                         levels = c("M0", "M1"),
                         labels = c("did not spread", "has spread"),
                         ordered = TRUE)

# Convert Survival_time_days to integer to remove decimal values
cancer$Survival_time_days <- as.integer(cancer$Survival_time_days)

# Set Overall_stage as an ordered factor
cancer$Overall_stage <- factor(cancer$Overall_stage, ordered = TRUE)

# Smoking
cancer$Smoking <- factor(cancer$Smoking)

# Tumor_location
cancer$Tumor_location <- factor(cancer$Tumor_location)

# Data is now cleaned 

# Plot: Probability of complete response by sex
library(wesanderson)
par(mfrow = c(1,1))

plot(cancer$Complete_response_probability ~ cancer$Sex,
     ylab = "Complete response probability", xlab = "Sex",
     main = "Complete response probability by sex",
     xaxt= "n", col = wes_palette("Royal2", 3, type = "discrete"))
legend("topright", legend = c("Females", "Males", "Prefer not to say"), 
       bty = "n", fill = wes_palette("Royal2", 3, type = "discrete"))

# Calculate mean Complete_response_probability by Sex group
females <- subset(cancer, Sex == "F")
males <- subset(cancer, Sex == "M")
pnts <- subset(cancer, Sex == "prefer not to say")

mean(females$Complete_response_probability)
mean(males$Complete_response_probability)
mean(pnts$Complete_response_probability)

# Round Survival_time_days for each Sex group
library(pastecs)
round(stat.desc(cancer$Survival_time_days), 2)
round(stat.desc(females$Survival_time_days), 2)
round(stat.desc(males$Survival_time_days), 2)
round(stat.desc(pnts$Survival_time_days), 2)

# Function to remove outliers
remove_outliers <- function(data, column) {
  quartiles <- quantile(data[[column]], probs = c(.25, .75))
  IQR <- IQR(data[[column]])
  lower <- quartiles[1] - 1.5 * IQR
  upper <- quartiles[2] + 1.5 * IQR
  subset(data, data[[column]] > lower & data[[column]] < upper)
}

# Remove outliers for females and males
females <- subset(cancer, Sex == "F")
females_no_outlier <- remove_outliers(females, "Survival_time_days")

males <- subset(cancer, Sex == "M")
males_no_outlier <- remove_outliers(males, "Survival_time_days")

# Plot: Survival time by tumor stage in females and males
par(mfrow = c(1,2))
par(mar = c(4,4,2,1), oma = c(0,0,2,0))

# Function for plotting survival analysis
plot_survival <- function(data, title) {
  plot(data$Overall_stage, data$Survival_time_days, type = "h", main = title,
       xlab = "Overall stage", ylab = "Survival time in days",
       col = wes_palette("Darjeeling1", 3, type = "discrete"))
}

# Plotting for females and males
plot_survival(females_no_outlier, "Females")
plot_survival(males_no_outlier, "Males")

#The chart indicates that women live longer than men when the tumor is in the first stage, 
#while they live shorter when the tumor is in the second stage. 
#The third stage is comparable for both women and men.

# Function for figure blowup with focus on the mean

par(mar = c(4,4,2,1), oma = c(0,0,2,0))

mean_plot_survival <- function(data, title) {
  plot(data$Overall_stage, data$Survival_time_days, type = "h", main = title,
       xlab = "Overall stage", ylab = "Survival time in days", ylim = c(350,500),
       col = wes_palette("Darjeeling1", 3, type = "discrete"))
  mtext("Survival time by tumor stage in females and males", outer = TRUE)
}

# Plotting for females and males

mean_plot_survival(females_no_outlier, "Females")
mean_plot_survival(males_no_outlier, "Males")

#The average survival of women and men in stage 1 is similar; men live on average 
#about 50 days longer in stage 2 and about 15 days longer in stage 3.

# Plotting survival time if smoking

par(mfrow = c(1,1))

plot(cancer$Smoking, cancer$Survival_time_days, 
     xlab = "Smoking", ylab = "Survival time in days",
     main = "Survival time if smoking", 
     col = wes_palette("Royal1", 4, type = c("discrete")))

legend("topright", legend = levels(cancer$Smoking),
       fill = wes_palette("Royal1", 4, type = c("discrete")),
       title = "Smoking", cex = 0.7, bg = rgb(1, 1, 1, alpha = 0))

      
#Smoking doesn't seem to have any effect on survival time.
      
#Treatment response by smoking.
    
plot(cancer$Smoking, cancer$Complete_response_probability, 
     xlab = "Smoking", ylab = "Complete response probability",
     main = "Complete response probability if smoking",
     xaxt = "n",
     col = wes_palette("Zissou1", 4, type = c("discrete")))

legend(x = "top", legend = levels(cancer$Smoking), 
       fill = wes_palette("Zissou1", 4, type = c("discrete")),
       bty = "n", title = NA, cex = 0.6, 
       text.col = "black")

# The plot suggests that those who smoke rarely have 5% higher 
# szanse na całkowite wyzdrowienie niż osoby niepalące i palące regularnie. 

#Survival time by weight loss

plot(cancer$Weight_loss_percent, cancer$Survival_time_days, 
     type = "h",
     xlab = "Weight loss in percent", ylab = "Survival time in days",
     main = "Survival time by weight loss",
     col = wes_palette("Darjeeling1", 2, type = c("discrete")))
abline(h = 1461, col = "steelblue1")
text(9, 1600, labels = c("four years"), col = "steelblue1")
abline(h = 2191, col = "steelblue3")
text(9, 2350, labels = c("six years"), col = "steelblue3")
abline(h = 2922, col = "steelblue4")
text(9, 3070, labels = c("eight years"), col = "steelblue4")


#The graph indicates that individuals who lost about 8% of their body weight 
#did not survive more than 4 years. Individuals who lost about 6% of their 
#body weight rarely survived 6 years and never 8 years. Individuals who lost 
#between 0 and about 5% of their body weight have similar survival outcomes.

#Correlation between weight loss percent and complete response probability

library("PerformanceAnalytics")

par(mar = c(4,4,2,1), oma = c(0,0,1,0))

chart.Correlation(cancer[, c("Weight_loss_percent", "Complete_response_probability")], histogram = TRUE)
mtext("Complete response probability and weight loss precent correlation", outer = T)

# These r effect sizes for the bivariate correlation and 
# the Pearson correlation are 0.10 for a small effect size, 
# 0.30 for a medium effect size, and 0.50 for a large effect size.

#There is a negligible positive correlation between weight loss and days of survival,
#but it is not significant, and I would approach it with caution.

#Age and complete response probability correlation

par(mar = c(4,4,2,1), oma = c(0,0,1,0))
chart.Correlation(cancer[, c("Age", "Complete_response_probability")], histogram = TRUE)
mtext("Complete response probability and age correlation", outer = T)

#There is a small negative correlation between age and the probability of complete recovery;
#the younger the patient, the greater the probability of recovery. 
#However, the correlation is negligible.

#Age and survival time in days correlation

par(mar = c(4,4,2,1), oma = c(0,0,1,0))
chart.Correlation(cancer[, c("Age", "Survival_time_days")], histogram = TRUE)
mtext("Survival time in days and age correlation", outer = T)

#Computing correlation coefficients
corr.test <- function(data) {
  res <- rcorr(as.matrix(data), type = "pearson") 
  r <- res$r 
  p <- res$P 
  list(r = r, p = p)
}

corr_columns <- cancer[, c("Age", "Survival_time_days")]
results <- corr.test(corr_columns)

# Display Pearson's R
print("Correlation Coefficients:")
print(results$r)

# Display p-values
print("P-value:")
print(results$p)

#Pearson's analysis suggests a weak positive correlation between
#the patient's age and the remaining lifespan in days; the older the patient, 
#the longer the remaining lifespan. The result is statistically significant 
#(p = 0.04, r = 0.06).



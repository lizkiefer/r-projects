# DA5020 Assignment 01.1 / Analyze Data
# Liz Kiefer
# Spring 2025

df<- read.csv("diabetes_data.csv", header = TRUE)
bmi2hlth <- mean(df$BMI)/mean(df$PhysHlth)

avg.age <- mean(df$Age)

cat("Mean age = ", avg.age, "/ Mean BMI to Health Ration =", bmi2hlth)

install.packages("psych")

require(psych)

describe(df)

patientct <- nrow(df[df$Fruits==0 & df$Veggies==0 & df$BMI>35,])
cat("Number of patients not eating veg/fruit:", patientCount)

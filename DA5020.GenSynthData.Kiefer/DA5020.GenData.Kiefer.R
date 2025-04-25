#ASSIGNMENT 03.1: Synthetic Data for Testing
#Liz Kiefer
#DA5020
#Spring 2025

#Question 2 CSV file from chat gpt with teh ski jumpers name and country 
#https://chatgpt.com/share/6792cf5e-0d24-8006-bda7-75866ca438f9

#3 Random Number Generator seed
set.seed(99876) 

#4 CSV preparation and loading
df <- read.csv("./ski_jumpers.csv", header = TRUE, stringsAsFactors = FALSE)
df$Practice <- c()
df$Jump1 <- c()
df$Jump2 <- c()
df$Jump3 <- c()
df$AvgJump <- c()
df$DNC <- c()

# Creates random numbers
random_numbers <- runif(10, min = 0, max = 1)
for (i in 1:nrow(df)) {
  #5 Generate values for DNC to give either T or F
  if (runif(1, min = 0, max = 1) < 0.0438){
    df$DNC[i] = "F"
  }
  else{
    df$DNC[i] = "T"
  }
  
  #6 Creates random numbers with a mean 111.2 and a sd of 20
    jumps <- rnorm(4, mean = 111.2, sd = 20)
    df$Practice[i] <- jumps[1] 
    df$Jump1[i] <- jumps[2] 
    df$Jump2[i] <- jumps[3] 
    df$Jump3[i] <- jumps[4] 
    
  #7 Sets jumps below 90 to 0s  
    if (df$Jump1[i] < 90){
      df$Jump1[i] = 0
    }
    
    if (df$Jump2[i] < 90){
      df$Jump2[i] = 0
    }
    if (df$Jump3[i] < 90){
      df$Jump3[i] = 0
    }
  #8 Finds the average of jumps 1, 2, and 3
    df$AvgJump[i] <- mean(c(df$Jump1[i], df$Jump2[i], df$Jump3[i]))
    }

# 9 Writing the new data into a CSV file
write.csv(df, "synth-jumps-KieferL.csv", row.names = FALSE)

#10 Avg of all jumps 
avgcolumn <- c(mean(df$Practice), mean(df$Jump1), mean(df$Jump2), mean(df$Jump3))
alljumpsmean <- mean(avgcolumn)
cat("mean of all jumps:", alljumpsmean)



plot(x = cleanData$Age , y = cleanData$HOMA , xlab = "age", ylab = "HOMA", main = "Graph of Age and HOMA", sub = "how age is related to HOMA")

abline(h = 2.5, col = "red")



plot(x = cleanData$BMI , y = cleanData$HOMA, xlab = "BMI", ylab = "HOMA", main = "Graph of HOMA and BMI", sub = "How BMI is affecting HOMA")

abline(h = 2.5, col = "red")


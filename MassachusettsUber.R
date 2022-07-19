#Finding correlation between variables
library(data.table)
library(ggplot2)
library(lmtest)
tncdata <- read.csv(file.choose(), fileEncoding = "UTF-8-BOM",header = TRUE)
attach(tncdata)
NewData <- data.table(TNCData)
NewData[ , `:=`(TOWN = NULL, ORIGIN_TRIPS = NULL, DESTINATION_TRIPS = NULL, DESTINATION_TRIPS_PER_PERSON=NULL,
                AVG_MINS_FROM_ORIGIN = NULL)]
NewData
cormat <- round(cor(NewData), 2)
library(rematch2)
# Saving the Image
setwd("~/R/ResEcon213")
save.image(file = "Project.RData")
attach(summaryNewData)
hist(log(ORIGIN_TRIPS_PER_PERSON))
reg <- lm(ORIGIN_TRIPS_PER_PERSON~SUM_SQUARE_MILES+MEDIAN_INCOME+POP2010+UNEMPLOYMENT_RATE2019+AVG_MILES_FROM_ORIGIN, data = NewData)
reg_sum <- summary(reg)
seconreg <- lm(ORIGIN_TRIPS_PER_PERSON~SUM_SQUARE_MILES+log(MEDIAN_INCOME)+POP2010+UNEMPLOYMENT_RATE2019+AVG_MILES_FROM_ORIGIN, data = NewData)
second_reg_sum <- summary(seconreg)
thirdreg <- lm(ORIGIN_TRIPS_PER_PERSON~SUM_SQUARE_MILES+log(MEDIAN_INCOME)+log(POP2010)+UNEMPLOYMENT_RATE2019+AVG_MILES_FROM_ORIGIN, data = NewData)
thirdreg_sum <- summary(thirdreg)
#Necessity to look at the increasing or decreasing effect of income
#F test for joint significance
newreg_sum <- summary(lm(ORIGIN_TRIPS_PER_PERSON~SUM_SQUARE_MILES+log(POP2010)+AVG_MILES_FROM_ORIGIN, data = NewData))
install.packages("car")
library(car)
nullhyp <- c("log(MEDIAN_INCOME)","log(POP2010)","SUM_SQUARE_MILES","UNEMPLOYMENT_RATE2019","AVG_MILES_FROM_ORIGIN")
linearHypothesis(thirdreg,nullhyp)
#Testing for Heteroskedasticity
thirdreg.resi <- thirdreg$residuals
library(ggplot2)
ggplot(data = NewData, aes(y = thirdreg.resi, x = SUM_SQUARE_MILES)) + geom_point(col = 'blue') + geom_abline(slope = 0)
#Conducting Breusch-Pagan test
install.packages("lmtest")
library(lmtest)
bptest(thirdreg)
#Using robust standard errors
install.packages("sandwich")
library(sandwich)
coeftest(thirdreg, vcov = vcovHC(thirdreg, "HC1"))

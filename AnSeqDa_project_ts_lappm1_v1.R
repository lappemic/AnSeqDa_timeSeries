############################### Project on time series ###############################

#############################################
# Projectgroup
# Janine Maron      maronjan@students.zhaw.ch
# Michael Lappert   lappm1@bfh.ch
#############################################

# 1.Task
## Select a monthly or quarterly time series from the M3 competition. Analyse the time series,
## choose meaningful indicators and fit a simple and a exponential smoothing model interpret
## the corresponding residuals and performance. Do the same with the ets and auto.arima.
## In the end document your findings.

## Decomment the line below, if not yet installed
# install.packages('Mcomp')
rm(list = ls()) # clears the global r workspace

######################################################

# 2. Selecting the time series
## Loading library fpp2 for ggplot and Mcomp for the M3 competition time series
library(fpp2)
library(Mcomp)

## Inspecting the available data
?M3
monthly_ts_list <- subset(M3, 'monthly') # filtering monthly time series
monthly_ts_list

quarterly_ts_list <- subset(M3, 'quarterly') # filtering quarterly time series
quarterly_ts_list

yearly_ts_list <- subset(M3, 'yearly') # filtering yearly time series
yearly_ts_list

other_ts_list <- subset(M3, 'other')
other_ts_list

## looking at the description of all the monthly time series 
indices_monthly_ts <- vector()
for (m in 1:length(monthly_ts_list)){
  t <- monthly_ts_list[[m]]
  indices_monthly_ts <- c(indices_monthly_ts, m)
}

for (i in indices_monthly_ts[1]:tail(indices_monthly_ts, 1)){
  print(paste(i, ' - ', monthly_ts_list[[i]]$description))
}

### looking at all the of monthly demographic time series
indices_monthly_demographic <- vector()
for (m in 1:length(monthly_ts_list)){
  t <- monthly_ts_list[[m]]$type
  if(t == 'DEMOGRAPHIC'){
    indices_monthly_demographic <- c(indices_monthly_demographic, m)
    }
}

for (i in indices_monthly_demographic[1]:tail(indices_monthly_demographic, 1)){
  print(paste(i, ' - ', monthly_ts_list[[i]]$description))
}

### looking at all the yearly macro time series
indices_yearly_macro <- vector()
for (m in 1:length(monthly_ts_list)){
  t <- monthly_ts_list[[m]]$type
  if(t == 'MACRO'){
    indices_yearly_macro <- c(indices_yearly_macro, m)
  }
}

for (i in indices_yearly_macro[1]:tail(indices_yearly_macro, 1)){
  print(paste(i, ' - ', monthly_ts_list[[i]]$description))
}

### Plotting some of the time series
data <- monthly_ts_list[[1357]] #UNEMPLOYED-LONG TERM 15 WEEKS AND OVER"
autoplot(data) + ggtitle(data$description)

data <- monthly_ts_list[[1346]] #UNEMPLOYMENT(REGISTED UNEMPLOYED) NORWAY"
autoplot(data) + ggtitle(data$description)

data <- monthly_ts_list[[1351]] #IMMIGRATION-SEASONAL WORKERS"
autoplot(data) + ggtitle(data$description)

data <- monthly_ts_list[[1371]] #ROAD ACCIDENTS ENGLAND"
autoplot(data) + ggtitle(data$description)

### temporary choice of dataset for project
timeS <- monthly_ts_list[[1371]] #ROAD ACCIDENTS ENGLAND"

######################################################

# 3. Exploratory Analysis
## Exploring in a first part the properties of the selected ts object
summary(timeS) # looking at the summary statistics of the selected ts
head(timeS) # looking at the first entries
tail(timeS) # looking at the last entries
frequency(timeS) # there is no seasonality
timeS$type # looking at the ts type: In our case, as seen before, it is demographic
timeS$description # Looking again at the description
timeS$h # length of historical data (--> training set?)
timeS$n # length of future data (--> test set?)


## looking at some plots for a better understanding of the ts
autoplot(timeS) + ggtitle(paste0(timeS$description))

train <- timeS$x # assigning training set
ggseasonplot(train) + ggtitle(paste0('Seasonal plot: ', timeS$description)) 
ggsubseriesplot(train) + ggtitle(paste0('Subseries plot: ', timeS$description)) 
ggAcf(train) + ggtitle(paste0('Autocorrelogram: ', timeS$description))
gglagplot(train) + ggtitle(paste0('Lag plot: ', timeS$description))

# - the autoplot lets already assume a seasonality and a slight trend downwards
# - in the seasonal and subseries plot the assumption gets of the seasonality gets even stronger
# - trend in the seasonal and subseries plot not anymore visible
# - the autocorrelogram proves that there is a seasonality:
#   * maximum and minimum outside the 95% confidence intervals
#   * maximum respectively minimum 12 month apart
#   * maximum to minimum always 6 month apart

######################################################

# 4. Indicators

# trend and seasonality? --> i would say so
# what is the objective on these indicators?

######################################################

# 5. Simple Model

# --> Seasonal na�ve method
# since there is a strong seasonality in the data this model is probably the most appropriate one of the simple models. It takes the last value form the same season as a forecast.

### forecast
test_set_length <- length(timeS$xx)
fc_length <- length(timeS$x) * 2
fc_snaive <- snaive(train, h=fc_length)
summary(fc_snaive)
summary(fc_snaive[['model']])
?snaive
autoplot(fc_snaive) +
  autolayer(fitted(fc_snaive), series="Fitted") +
  xlab("Year")  +
  ggtitle(paste0("Forecast from ","Seasonal naive method: \n", timeS$description)) 

### residuals
res <- residuals(fc_snaive) 
checkresiduals(fc_snaive) 

# - residuals are more or less normally distributed
# - p-value < 0.05 -> reject the null hypothesis that the data are white noise, concluding that there is a significant autocorrelation

## Evaluating forecast accuracy
### Traditional evaluation
test_set <- timeS$xx
accuracy(fc_snaive, test_set)

# - MAPE on test set of 2.97%

### Cross-validation
#### A good way to choose the best forecasting model is to find the model with
#### the smallest RMSE computed using time series cross-validation

### ---> dont get it at the moment
?tsCV
fc_cv <- tsCV(train, snaive, drift=TRUE, h=1)
autoplot(fc_cv)
sqrt(mean(fc_cv^2, na.rm=TRUE))

as <- snaive(train, h=18)
fc_cv <- tsCV(train, as, drift=TRUE, h=1)

######################################################

# 6. Exponential Smoothing

#################### --> not sure about these ones

## --> simple exponential smoothing
fc_ses <- ses(train, h=test_set_length)
summary(fc_ses)
summary(fc_ses[['model']])

autoplot(fc_ses) +
  autolayer(fitted(fc_ses), series="Fitted") +
  xlab("Year")  +
  ggtitle(paste0("Forecast from ","simple exponential smoothing: \n", timeS$description))

res <- residuals(fc_ses) 
checkresiduals(fc_ses) 

# - residuals are more or less normally distributed
# - p-value < 0.05 -> reject the null hypothesis that the data are white noise, concluding that there is a significant autocorrelation

### test on TEST SET
accuracy(fc_ses, test_set)

# - MAPE on test set of 8.66%

## --> holt's method --> this is a linear trend forecast
fc_holt1 <- holt(train, h=test_set_length)
fc_holt2 <- holt(train, h=test_set_length, damped=TRUE)
summary(fc_holt1)
summary(fc_holt1[['model']])

autoplot(fc_holt1) +
  autolayer(fitted(fc_holt1), series="Fitted holt1") +
  autolayer(fitted(fc_holt2), series="Fitted holt2") +
  xlab("Year")  +
  ggtitle(paste0("Forecast from ","holt's method: \n", timeS$description))

res <- residuals(fc_holt1) 
checkresiduals(fc_holt1)

# - residuals are more or less normally distributed
# - p-value < 0.05 -> reject the null hypothesis that the data are white noise, concluding that there is a significant autocorrelation

### test on TEST SET
accuracy(fc_holt1, test_set)
accuracy(fc_holt2, test_set)

# - MAPE on test set of holt1 = 8.01%
# - MAPE on test set of holt2 = 8.19%

## --> holt-winters' additive method --> seasonal method
fc_hw1 <- hw(train, h=test_set_length, damped=TRUE, seasonal='additive')
fc_hw2 <- hw(train, h=test_set_length, damped=FALSE, seasonal='additive')
fc_hw3 <- hw(train, h=test_set_length, damped=TRUE, seasonal='multiplicative')
fc_hw4 <- hw(train, h=test_set_length, damped=FALSE, seasonal='multiplicative')
summary(fc_hw4)
summary(fc_hw4[['model']])

autoplot(fc_hw1) +
  autolayer(fitted(fc_hw1), series="Fitted hw 1") +
  autolayer(fitted(fc_hw2), series="Fitted hw 2") +
  autolayer(fitted(fc_hw3), series="Fitted hw 3") +
  autolayer(fitted(fc_hw4), series="Fitted hw 4") +
  xlab("Year")  +
  ggtitle(paste0("Forecast from ","holt-winters' additive method: \n", timeS$description))

res <- residuals(fc_hw4) 
checkresiduals(fc_hw4)

# - residuals have a nice normally distributed shape
# - p-value < 0.05 -> reject the null hypothesis that the data are white noise, concluding that there is a significant autocorrelation


### test on TEST SET
accuracy(fc_hw1, test_set)
accuracy(fc_hw2, test_set)
accuracy(fc_hw3, test_set)
accuracy(fc_hw4, test_set)

# - MAPE on test set of hw1 = 4.83%
# - MAPE on test set of hw1 = 5.32%
# - MAPE on test set of hw1 = 4.88%
# - MAPE on test set of hw1 = 4.75%

# 7. ETS and AUTO.ARIMA

########## just tries!!
?ets
fc_ets1 <- forecast(ets(train, model='ZZZ'), h=18)
#fc_ets2 <- ets(test_set, model=fit_ets1, use.initial.values = TRUE)

summary(fc_ets1)
summary(fc_ets1[['model']])

autoplot(fc_ets1) +
  autolayer(fitted(fc_ets1), series="Fitted ets 1") +
  xlab("Year")  +
  ggtitle(paste0("Forecast from ","ets: \n", timeS$description))

accuracy(fc_ets1, test_set)

# - MAPE on test set of 4.87%

# 8. Conclusion

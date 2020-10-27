############################### Project on time series ###############################

#############################################
# Projectgroup
# Janine Maron      maronjan@students.zhaw.ch
# Michael Lappert   lappm1@bfh.ch
#############################################


pathOut  <- paste0("your_path")


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

# quarterly_ts_list <- subset(M3, 'quarterly') # filtering quarterly time series
# quarterly_ts_list
# 
# yearly_ts_list <- subset(M3, 'yearly') # filtering yearly time series
# yearly_ts_list
# 
# other_ts_list <- subset(M3, 'other')
# other_ts_list
# 
# ## looking at the description of all the monthly time series 
# indices_monthly_ts <- vector()
# for (m in 1:length(monthly_ts_list)){
#   t <- monthly_ts_list[[m]]
#   indices_monthly_ts <- c(indices_monthly_ts, m)
# }
# 
# for (i in indices_monthly_ts[1]:tail(indices_monthly_ts, 1)){
#   print(paste(i, ' - ', monthly_ts_list[[i]]$description))
# }
# 
# ### looking at all the of monthly demographic time series
# indices_monthly_demographic <- vector()
# for (m in 1:length(monthly_ts_list)){
#   t <- monthly_ts_list[[m]]$type
#   if(t == 'DEMOGRAPHIC'){
#     indices_monthly_demographic <- c(indices_monthly_demographic, m)
#     }
# }
# 
# for (i in indices_monthly_demographic[1]:tail(indices_monthly_demographic, 1)){
#   print(paste(i, ' - ', monthly_ts_list[[i]]$description))
# }
# 
# ### looking at all the yearly macro time series
# indices_yearly_macro <- vector()
# for (m in 1:length(monthly_ts_list)){
#   t <- monthly_ts_list[[m]]$type
#   if(t == 'MACRO'){
#     indices_yearly_macro <- c(indices_yearly_macro, m)
#   }
# }
# 
# for (i in indices_yearly_macro[1]:tail(indices_yearly_macro, 1)){
#   print(paste(i, ' - ', monthly_ts_list[[i]]$description))
# }
# 
### Plotting some of the time series
# data <- monthly_ts_list[[1357]] #UNEMPLOYED-LONG TERM 15 WEEKS AND OVER"
# autoplot(data) + ggtitle(data$description)
# 
# data <- monthly_ts_list[[1346]] #UNEMPLOYMENT(REGISTED UNEMPLOYED) NORWAY"
# autoplot(data) + ggtitle(data$description)
# 
# data <- monthly_ts_list[[1351]] #IMMIGRATION-SEASONAL WORKERS"
# autoplot(data) + ggtitle(data$description)
# 
# data <- monthly_ts_list[[1371]] #ROAD ACCIDENTS ENGLAND"
# autoplot(data) + ggtitle(data$description)

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
autoplot(timeS) + ggtitle(paste0(timeS$description)) + theme_bw()
ggsave(paste0("A_autoplot_road_accidents.png"), width = 10, height = 6, path = pathOut)

trainData <- timeS$x # assigning training set

ggseasonplot(trainData) + ggtitle(paste0('Seasonal plot: ', timeS$description)) + theme_bw()
ggsave(paste0("A_seasonplot_road_accidents.png"), width = 10, height = 6, path = pathOut)

ggsubseriesplot(trainData) + ggtitle(paste0('Subseries plot: ', timeS$description)) + theme_bw()
ggsave(paste0("A_seriesplot_road_accidents.png"), width = 10, height = 6, path = pathOut)

ggAcf(trainData) + ggtitle(paste0('Autocorrelogram: ', timeS$description))
ggsave(paste0("A_autocorrelogram_road_accidents.png"), width = 10, height = 6, path = pathOut)

gglagplot(trainData) + ggtitle(paste0('Lag plot: ', timeS$description))
ggsave(paste0("A_lagplot_road_accidents.png"), width = 10, height = 6, path = pathOut)


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

# --> Seasonal na?ve method
# since there is a strong seasonality in the data this model is probably the most appropriate one of the simple models. It takes the last value form the same season as a forecast.

### forecast
test_length <- length(timeS$xx) 

# NAIVE model
fc_snaive <- snaive(trainData, h=test_length)
summary(fc_snaive)
summary(fc_snaive[['model']])

autoplot(fc_snaive) +
  autolayer(fitted(fc_snaive), series="Fitted", color ="blue", alpha = 0.6) +
  xlab("Year")  +   theme_bw()
  ggtitle(paste0("Forecast from ","Seasonal naive method: \n", timeS$description)) 
ggsave(paste0("B_forecast_naive_road_accidents.png"), width = 10, height = 6, path = pathOut)


### residuals
res <- residuals(fc_snaive) 
checkresiduals(fc_snaive) 

ggAcf(res)   # no white noise
ggsave(paste0("B_residuals_naive_road_accidents.png"), width = 10, height = 6, path = pathOut)


# - residuals are more or less normally distributed
# - p-value < 0.05 -> reject the null hypothesis that the data are white noise, concluding that there is a significant autocorrelation

## Evaluating forecast accuracy
### Traditional evaluation
testData <- timeS$xx
accuracy(fc_snaive, testData)

# - MAPE on test set of 2.97
# - RMSE of 110 on test set

### Cross-validation
#### A good way to choose the best forecasting model is to find the model with
#### the smallest RMSE computed using time series cross-validation

### Cross Validation
e <- tsCV(testData, snaive, drift=TRUE, h=test_length)
RMSE_naive <- sqrt(mean(e^2, na.rm=TRUE)) 


## forecast vs. true values
fc_snaive%>%autoplot() +
   autolayer(fitted(fc_snaive), series="Fitted", color ="blue", alpha = 0.6) +
   geom_line(aes( x = as.numeric(time(testData)), y = as.numeric(testData) ),col = "red" ) +  theme_bw()
 ggsave(paste0("B_fit_vs_true_naive_road_accidents.png"), width = 10, height = 6, path = pathOut)
 


######################################################

# 6. Exponential Smoothing

#################### --> not sure about these ones

## --> simple exponential smoothing
fc_ses <- ses(trainData, h=test_length)
summary(fc_ses)
summary(fc_ses[['model']])

autoplot(fc_ses) +
  autolayer(fitted(fc_ses), series="Fitted", color ="blue", alpha = 0.6) +
  xlab("Year")  +    theme_bw()
  ggtitle(paste0("Forecast from ","simple exponential method: \n", timeS$description)) 
ggsave(paste0("C_forecast_ses_road_accidents.png"), width = 10, height = 6, path = pathOut)

res <- residuals(fc_ses) 
checkresiduals(fc_ses) 

ggAcf(res)   # no white noise
ggsave(paste0("C_residuals_ses_road_accidents.png"), width = 10, height = 6, path = pathOut)


# - residuals are more or less normally distributed
# - p-value < 0.05 -> reject the null hypothesis that the data are white noise, concluding that there is a significant autocorrelation

### test on TEST SET
accuracy(fc_ses, testData)

# - MAPE on test set of 8.66%

### Cross Validation
e <- tsCV(testData, ses, drift=TRUE, h=test_length)
RMSE_ses <- sqrt(mean(e^2, na.rm=TRUE)) 

#### Holts Method

## --> holt's method --> this is a linear trend forecast
fc_holt1 <- holt(trainData, h=test_length)
fc_holt2 <- holt(trainData, h=test_length, damped=TRUE)
summary(fc_holt1)
summary(fc_holt1[['model']])


autoplot(fc_holt1) +
  autolayer(fitted(fc_holt1), series="Fitted holt1") +
  xlab("Year")  +
  ggtitle(paste0("Forecast from ","holt's method: \n", timeS$description))
ggsave(paste0("D_forecast_holts_road_accidents.png"), width = 10, height = 6, path = pathOut)

autoplot(fc_holt2) +
  autolayer(fitted(fc_holt2), series="Fitted holt2") +
  xlab("Year")  +
  ggtitle(paste0("Forecast from ","holt's method: \n", timeS$description))
ggsave(paste0("D_forecast_holts_damped_road_accidents.png"), width = 10, height = 6, path = pathOut)


res <- residuals(fc_holt1) 
ggAcf(res)   # no white noise
ggsave(paste0("D_residuals_holts_road_accidents.png"), width = 10, height = 6, path = pathOut)

res <- residuals(fc_holt2) 
ggAcf(res)   # no white noise
ggsave(paste0("D_residuals_holts_damped_road_accidents.png"), width = 10, height = 6, path = pathOut)


# - residuals are more or less normally distributed
# - p-value < 0.05 -> reject the null hypothesis that the data are white noise, concluding that there is a significant autocorrelation

### test on TEST SET
accuracy(fc_holt1, testData)
accuracy(fc_holt2, testData)

# - MAPE on test set of holt1 = 8.01%
# - MAPE on test set of holt2 = 8.19%

# Cross Validation
e <- tsCV(testData, holt, drift=TRUE, h=test_length)
RMSE_holt <- sqrt(mean(e^2, na.rm=TRUE)) 

e <- tsCV(testData, holt,damped=TRUE, drift=TRUE, h=test_length)
RMSE_holt_d <- sqrt(mean(e^2, na.rm=TRUE)) 

#### Holt-winters method (SEASONAL method)
## --> holt-winters' additive method --> seasonal method
fc_hw1 <- hw(trainData, h=test_length, damped=TRUE, seasonal='additive')
fc_hw2 <- hw(trainData, h=test_length, damped=FALSE, seasonal='additive')
fc_hw3 <- hw(trainData, h=test_length, damped=TRUE, seasonal='multiplicative')
fc_hw4 <- hw(trainData, h=test_length, damped=FALSE, seasonal='multiplicative')
summary(fc_hw4[['model']])

# Cross Validation
e <- tsCV(testData, hw,seasonal='additive',h=test_length, damped=TRUE, drift=TRUE)
RMSE_hw_Ad <- sqrt(mean(e^2, na.rm=TRUE)) 

e <- tsCV(testData, hw, h=test_length, damped=FALSE, seasonal='additive', drift=TRUE)
RMSE_hw_A <- sqrt(mean(e^2, na.rm=TRUE)) 

e <- tsCV(testData, hw,  damped=TRUE, seasonal='multiplicative', drift=TRUE)
RMSE_hw_Md <- sqrt(mean(e^2, na.rm=TRUE)) 

e <- tsCV(testData, hw,h=test_length, damped=FALSE, seasonal='multiplicative', drift=TRUE)
RMSE_hw_M <- sqrt(mean(e^2, na.rm=TRUE)) 

autoplot(fc_hw1) +
  autolayer(fitted(fc_hw1), series="Fitted hw 1") +
  autolayer(fitted(fc_hw2), series="Fitted hw 2") +
  autolayer(fitted(fc_hw3), series="Fitted hw 3") +
  autolayer(fitted(fc_hw4), series="Fitted hw 4") +
  xlab("Year")  + theme_bw() +
ggtitle(paste0("Forecast from holt-winters method': \n", timeS$description))
ggsave(paste0("E_forecast_hw_road_accidents.png"), width = 10, height = 6, path = pathOut)

res <- residuals(fc_hw2) 
ggAcf(res)   # no white noise
ggsave(paste0("E_residuals_holt-winters_additive_road_accidents.png"), width = 10, height = 6, path = pathOut)

res <- residuals(fc_hw4) 
ggAcf(res)   # no white noise
ggsave(paste0("E_residuals_holt-winters_multiplicative_road_accidents.png"), width = 10, height = 6, path = pathOut)

### test on TEST SET
accuracy(fc_hw1, testData)
accuracy(fc_hw2, testData)
accuracy(fc_hw3, testData)
accuracy(fc_hw4, testData)

sink(file = paste0(pathOut,"E_accuracy_hw_models.txt"))
fc_hw1$method
accuracy(fc_hw1, testData)
fc_hw2$method
accuracy(fc_hw2, testData)
fc_hw3$method
accuracy(fc_hw3, testData)
fc_hw4$method
accuracy(fc_hw4, testData)
sink(file = NULL)


# - MAPE on test set of hw1 = 4.83
# - MAPE on test set of hw1 = 5.32
# - MAPE on test set of hw1 = 4.88
# - MAPE on test set of hw1 = 4.75

#plot forecast with true values
autoplot(cbind(testData), color="black") +
  autolayer(predict(fc_hw1), series="HW Ad Fitted", alpha = 0.6, PI=FALSE) +
  autolayer(predict(fc_hw2), series="HW A Fitted", alpha = 0.6, PI=FALSE) +
  autolayer(predict(fc_hw3), series="HW Md Fitted", alpha = 0.6, PI=FALSE) +
  autolayer(predict(fc_hw4), series="HW M Fitted", alpha = 0.6, PI=FALSE) +
  theme_bw() + xlab("year") + ylab("") + ylim(2000,4000) +
  ggtitle(paste0("Forecast \n", timeS$description)) 
ggsave(paste0("E_forecast_hw_models_road_accidents.png"), width = 10, height = 6, path = pathOut)


# 7. ETS and AUTO.ARIMA

########## just tries!!
?ets
fit_ets1 <- ets(trainData)
fc_ets1 <- forecast(ets(trainData), h=test_length)
fc_ets1$model
#fc_ets2 <- ets(test_set, model=fit_ets1, use.initial.values = TRUE)

sink(file = paste0(pathOut,"F_ets_summary.txt"))
summary(fc_ets1[['model']])
sink(file = NULL)


autoplot(fit_ets1) +
  xlab("Year")  +  theme_bw() +
  ggtitle(paste0("Fit from ","ets: \n", timeS$description))
ggsave(paste0("F_fit_ets_road_accidents.png"), width = 10, height = 6, path = pathOut)

autoplot(fc_ets1) +
  autolayer(fitted(fc_ets1), series="Fitted ets 1", color="lightblue") +
  xlab("Year")  +  theme_bw() +
  ggtitle(paste0("Forecast from ","ets: \n", timeS$description)) 
ggsave(paste0("F_forecast_ets_road_accidents.png"), width = 10, height = 6, path = pathOut)


accuracy(fc_ets1, testData)

sink(file = paste0(pathOut,"F_accuracy_ets_models.txt"))
fc_ets1$method
accuracy(fc_ets1, testData)
sink(file = NULL)

# - MAPE on test set of 4.87%

# Cross Validation
fets <- function(x, h) {
  forecast(ets(x), h = h)
}

e_t <- tsCV(testData, fets,h=test_length)
RMSE_ets1 <- sqrt(mean(e_t^2, na.rm=TRUE)) 

cbind('Residuals' = residuals(fc_ets1),
      'Forecast errors' = residuals(fc_ets1, type='response')) %>%
  autoplot(facet=TRUE) + xlab("Year") + ylab("") +theme_bw() +
  ggtitle(paste0("Residuals and Errors from ","ets: \n", timeS$description)) 
ggsave(paste0("F_residuals_&_errors_road_accidents.png"), width = 10, height = 6, path = pathOut)


# 8. Conclusion



##### comparison of methods

fileConn<-file(paste0(pathOut,"X_RMSE_comparison_per_models.txt"))
writeLines(c(paste0("RSME per method \n"),
             paste0("Naive model: ",RMSE_naive),"\n",
             paste0("SES model: ",RMSE_ses),"\n",
             paste0("Holt model: ",RMSE_holt),"\n",
             paste0("Holt damped model: ",RMSE_holt_d),"\n",
             paste0("HW Ad model: ",RMSE_hw_Ad),"\n",
             paste0("HW A model: ",RMSE_hw_A),"\n",
             paste0("HW Md model: ",RMSE_hw_Md,"     BEST MODEL"),"\n",
             paste0("HW M model: ",RMSE_hw_M),"\n",
             paste0("ETS model: ",RMSE_ets1)
             )
             , fileConn)
close(fileConn)

## forecast vs. true values
fc_hw3%>%autoplot() +
  autolayer(fitted(fc_snaive), series="Fitted", color ="blue", alpha = 0.6) +
  geom_line(aes( x = as.numeric(time(testData)), y = as.numeric(testData) ),col = "red" ) +  theme_bw()
ggsave(paste0("X_best_model_models_road_accidents.png"), width = 10, height = 6, path = pathOut)

#plot forecast with true values
autoplot(cbind(testData), color="black") +
  autolayer(predict(fc_snaive), series="Naive Fitted", alpha = 0.6, PI=FALSE) +
  autolayer(predict(fc_hw3), series="HW Md Fitted", alpha = 0.6, PI=FALSE) +
  autolayer(predict(fc_ets1), series="ETS Fitted", alpha = 0.6, PI=FALSE) +
  theme_bw() + xlab("year") + ylab("") + ylim(2000,4000) +
  ggtitle(paste0("Forecast \n", timeS$description)) 
ggsave(paste0("X_forecast_all_models_road_accidents.png"), width = 10, height = 6, path = pathOut)


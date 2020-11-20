# AnSeqDa_timeSeries
Analysis and forecasting time series of the M3 competition with simple models and exponential smoothing as part of the Master of Engineering module Analysis of Sequential Data.

MSE | TSM_AnSeqDa | autumn semester 2020
Project 1 – time series

Michael Lappert & Janine Maron


Table of Contents
1	Exploratory time series analysis	2
2	Indicators	2
3	Simple Model	3
3.1	Accuracy & Cross Validation	3
3.2	Residuals	3
3.3	Findings	3
4	EXPONENTIAL SMOOTHING	3
4.1	Accuracy & Cross Validation	4
4.2	Residuals	4
4.3	Findings	4
5	ETS	4
5.1	Accuracy & Cross Validation	5
5.2	Residuals	5
5.3	Findings	5
6	Auto-Arima model	6
6.1	Accuracy & Cross Validation	6
6.2	Residuals	7
6.3	Findings	7
7	Auto-Arima model	7
7.1	Accuracy & Cross Validation	8
7.2	Residuals	8
7.3	Findings	8
8	Conclusion	8



 
1	Exploratory time series analysis
The time series “Road accidents England” from the library “Mcomb” was taken for this project. It contains the number of road accidents per month in England for the period of 1964 to 1972.
The plot of the time series indicates that there is a seasonality in the data and a slight trend.

 
The seasonal and subseries plot indicate as well that there is a seasonality.










The Autocorrelogram shows that the data is no white noise since it exceeds the thresholds. Further, it shows its maximum at lag 12 and its minimum at lag 6 and 18, which means the maximum is in winter and its minimum in summer.

 
2	Indicators
We use the following indicators to assess the accuracy of the forecasting models:
Root mean squared error (RMSE)	
•	RMSE gives more importance to large errors.
•	It is scale dependent
Mean absolute percentage error (MAPE)
•	MAPE is scale independent (Percentage error)
•	It is only sensible if yt ≫ 0 and y has a natural zero.
•	This time series has y between 2340 and 3760 which is >> 0, therefor the MAPE is a good indicator for the model
 
3	Simple Model
Since this time series has a strong seasonality the most appropriate simple model seems to be the seasonal naïve forecast.

 
3.1	Accuracy & Cross Validation
The accuracy and the cross validation is always computed with the following code:
•	accuracy(fc_model, testData)
•	e <- tsCV(testData, model, drift=TRUE, h=test_length)
                		RMSE 	 	MAPE
Training set 	232.959 		6.067
Test set     	110.126 		2.968

Compared to the Random walk forecast (RMSE= 286.822 , MAPE = 8.219 on the test set), the accuracy of the Seasonal Naïve Model is much more accurate. 

The RMSE of the cross validation is 354.7874.

3.2	Residuals
The Residuals are always computed with the following code:
•	checkresiduals(fc_model)
The residuals should have the following properties:
•	Be white noise	
o	uncorrelated residuals
o	mean zero of residuals
o	constant variance

 ACF does not look like white noise since the residuals exceed the thresholds of the autocorrelogram and do not look normally distributed.

p-value = 0.001389
 p-value< 0.05,  reject the null hypothesis, concluding that there is a significant autocorrelation and therefore the residuals are not white noise.

3.3	Findings
The forecast with the seasonal naïve model is much better than when using a random walk model, but the residuals are no white noise. The model is therefore not satisfying.
 
4	EXPONENTIAL SMOOTHING 
Out of the exponential smoothing model the Holt-Winter’s model was chosen for this time series, due to its ability to handle seasonality. After computing every combination of damped TRUE/FALSE and seasonality additive/multiplicative the Holt-Winter’s model with multiplicative seasonality and linear trend was found performing the best for this series.

Holt-Winter’s model, damped=FALSE, seasonal='multiplicative'

 
4.1	Accuracy & Cross Validation
The errors on the training data of the Holt-Winter’s model are smaller than of the simple seasonal Naïve model. On the test data the RMSE and MAPE for the Holt-Winter’s model are 166.7 and 4.8. So even though the training errors are smaller, the test error is larger than for the simple seasonal Naïve model. This lets assume that the model is overfitting the training data.

		RMSE		MAPE
Training set	155.608		4.255
Test set		166.742		4.753

The RMSE after applying the cross validation is 351.8, which is comparable to the simple seasonal naïve model.

4.2	Residuals
 ACF does not look like white noise since the residuals exceed the thresholds of the autocorrelogram


p-value = 0.001929
 p-value< 0.05,  reject the null hypothesis, concluding that there is a significant autocorrelation.


4.3	Findings
The Holt-Winter’s model does not perform better than the simple seasonal Naïve model. The RMSE and MAPE are on the test data larger than the ones of the seasonal naïve model. The RMSE of the Cross Validation is about the same for the Holt-Winter’s and the seasonal Naïve model. The residuals are no white noise for both models, but still look a bit better for the Holt-Winter’s model. 
 
5	ETS
The ETS (error, trend, seasonal) model is a time series univariate forecasting method. It focuses on trend and seasonal components. Applied to the time series it chooses automatically the best fitting paramters. On the “Road accidents England” time series it chose the following parameters:
Error:	additive
Trend:	none
Season:	additive

Smoothing parameters:
alpha 	= 0.3681 	 smoothing coefficient of the level rather small, a lot of the past is
		included in the forecast
gamma 	= 1e-04 	 the smoothing coefficient of the season is near zero, therefore the
		season is constant

Initial states:
l = 3264.6351		 level at time zero
s = 188.7787 110.8121 185.8906 
      141.5707 296.9689 308.5469
      90.5682 144.6849 -187.2833 
     -244.7734 -596.662 -439.102	 the month January until august lay above the average, the rest of the
		month lays below the average 

AIC               AICc               BIC 
1147.767    1155.509     1183.118	 The AIC is 1147.8.

 

5.1	Accuracy & Cross Validation
On the training set the errors are lower than for the seasonal Naïve and the Holt-Winter’s model. But on the test set the errors are larger than for both of the other models.

                		RMSE  		MAPE
Training set 	146.470 		3.966
Test set     	184.597 		4.873

When applying cross validation the RMSE is 372.7, which is larger compared to the other models.
 
5.2	Residuals
 The residuals look like white noise.
 residuals are uncorrelated	
 mean of residuals is zero
 constant variance

p-value = 0.02011
 p-value< 0.05,  reject the null hypothesis, concluding that there is a significant autocorrelation and actually are not white noise.

5.3	Findings
The errors of the ETS model are larger than for the seasonal Naïve and the Holt-Winter’s model. But only for the ETS model the residuals are white noise. The AIC of the ETS model is 1147.8.

6	Auto-Arima model
Before fitting the Arima model the data needs to be stationary. Which made by differencing the time series with the seasonality (if existing) and the first difference.
Since there is a seasonality in, the seasonal difference needs to be taken.
nsdiffs(trainData) # 1

According to the nsdiffs function there would be no need for another first difference, but looking at the plot, the data is still not stationary. So the first difference is applied on top, which led to the following stationary plot:
 

Now the differentiated data can be fitted with the Auto-Arima model, which leads to the following code 
•	fc_aa <- forecast(auto.arima(diff(diff(trainData, lag=12), lag=1)), h=test_length)
and results in the following model and coefficients:
ARIMA(0,0,1)(0,0,1)[12] with zero mean 	First order moving average with first order seasonal
moving average

Coefficients: 
          ma1     sma1				Coefficients ma1 from moving average as well as sms1
      -0.6316  -0.7175				from seasonal moving average are >> 0 and therefore
s.e.   0.1267   0.1800				model not equivalent to white noise

sigma^2 estimated as 31071:  log likelihood=-431.9
AIC=869.81   AICc=870.2   BIC=876.33		The AIC is 869.81
 
6.1	Accuracy & Cross Validation
On the training and the test data the errors of the Auto-Arima model are almost the same as the ones from the ETS model. Therefore the seasonal Naïve model still has the lowest errors.

                		RMSE  		MAPE
Training set 	151.360 		3.691
Test set     	193.672 		4.879

The RMSE when applying the cross validation is 332.7. This is smaller than for the other models.

6.2	Residuals
 The residuals look like white noise.
 residuals are uncorrelated	
 mean of residuals is zero
 constant variance


p-value = 0.9856
 p-value> 0.05,  the null hypothesis is true, concluding that there is no significant autocorrelation and the residuals are white noise.

6.3	Findings
While the errors of this model are larger on the training sets compared to the other models, the RMSE of the cross validation is smaller. Also the Residuals are white noise. The AIC of the Auto-Arima model is a lot smaller than the AIC of the ETS model. This means that the Auto-Arima model fits the time series better than the ETS model.
7	Conclusion
In this project the time series "Road accidents England" of the Mcomp package from the M3 competition was chosen to fit different models such as a simple (seasonal naïve forecast), exponential smoothing (Holt-Winter’s model), ets and auto-arima model. Afterwards the corresponding residuals were analysed and interpreted. In the table below the main criterions to evaluate the models are listed.

Criterion | model	Seasonal naïve forecast	Holt-Winter's	ETS	Auto-Arima
RMSE / MAPE train data	232.96 / 6.07	155.61 / 4.26	146.47 / 3.97	151.36 / 3.69
RMSE / MAPE test data	110.13 / 2.97	166.74 / 4.75	184.60 / 4.87	193.67 / 4.88
Cross Validation RMSE	354.79	351.8	372.7	332.7
Residuals WN	no	no	yes	yes

It was found that the more complex the model is, the lower the training error became (lowest training RMSE with 146 of the ETS model) the higher the test error got (highest test RMSE with 193 of the auto-arima model). Compared to the simple model of the seasonal naïve forecast the RMSE on the train set results in 332 and on the test set in 110. This leads to the conclusion that the complexer the models get, the more they overfit the data. However, the Cross Validation error is the lowest for the Auto-Arima model. This model also provides normally distributed residuals which are white noise, while the seasonal naïve as well as the Holt-Winter's model do not.

The cross validation and the AIC aim at choosing the model which will yield the most accurate forecast on the test set. The whiteness of the residuals is the basis for the computation of the prediction intervals. Therefore, residuals that are not white noise might distort the prediction intervals.

The auto-arima model results in the lowest cross validation error and also has residuals that are white noise. That is the reason why the auto-arima model is probably the most suitable model for this time series.

In further studies the authors would calculatethe accuracy of their own chosen models and comparing there the AIC's of the nested models instead of choosing the auto functions of the ets and arima model. This would eventually lead to better fitting models and moreover of a better understanding of the time series.


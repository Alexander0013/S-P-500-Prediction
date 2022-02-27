# [GroupID] S&P500 prediction

### Name
Alexander Liang

### Goal
A breif introduction about your project, i.e., what is your goal?

A: Using LSTM model to predict Vanguard S&P 500 ETF price，in order to develop a long-term profitable strategy

### data

* Source : 
      A:Yahoo Finance
* Input format : 
      A:CSV
* Any preprocessing? 
  * Handle missing data   
      A:If the stock price have missing value, we drop the value and use data from yesterday to fill the space.
  * Scale value  
      A:We use normalization on the data, keep the data in [0,1]

### code

* Which method do you use? 
      A: LSTM
* What is a null model for comparison? 
      A: Random Forest
* How do your perform evaluation? ie. Cross-validation, or extra separated data 
      A: RMSE/R square/ RSE

### results

* Which metric do you use 
  * precision, recall, R-square 
      A: RMSE/ R square/ RSE
* Is your improvement significant? 
      A:Cut out the validation data from the training data and let the model do validation
* What is the challenge part of your project? 
      A:1. Choose the right model 2. Find valid eigenvalues 3. Make the model run more accurately




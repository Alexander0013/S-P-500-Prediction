# [GroupID] S&P500發財模型

### Groups
* 袁嵩皓, 107306085
* 梁永強, 105701060
* 林羿名, 107703007
* 翁義甫, 107703041

### Goal
A breif introduction about your project, i.e., what is your goal?

A: Using LSTM model to predict Vanguard S&P 500 ETF price，in order to devlop a long-term profitable strategy

### Demo 
You should provide an example commend to reproduce your result
```R
Rscript code/your_script.R --input data/training --output results/performance.tsv
```
* any on-line visualization

## Folder organization and its related information

### docs
* Your presentation, 1091_datascience_FP_<yourID|groupName>.ppt/pptx/pdf, by **Jan. 12** 
* Any related document for the final project
  * papers
  * software user guide

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

## References
* Code/implementation which you include/reference (__You should indicate in your presentation if you use code for others. Otherwise, cheating will result in 0 score for final project.__)
* Packages you use




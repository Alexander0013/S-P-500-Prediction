# [GroupID] S&P500發財模型

### Groups
* 袁嵩皓, 107306085
* name, student ID2
* name, student ID3
* ...

### Goal
A breif introduction about your project, i.e., what is your goal?

A: 透過LSTM的model預測S&P500的指數型基金VFINX的股價走勢，希望能藉此發展出能穩定獲利的交易策略

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
      A:假如說股價有missing value就直接drop掉，然後用前一天的資料去補
  * Scale value  
      A:做標準化，把資料縮在0~1之間

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
      A:將訓練資料裡面切出validation的資料出來，讓模型做validation。
* What is the challenge part of your project? 
      A:1. 選擇預測模型 2. 找出有效的特徵值 3. 讓模型跑得更準

## References
* Code/implementation which you include/reference (__You should indicate in your presentation if you use code for others. Otherwise, cheating will result in 0 score for final project.__)
* Packages you use
* Related publications



# read parameters
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("USAGE: Rscript final_project.R --input data/training --output results/performance.tsv", call.=FALSE)
}


# parse parameters
i<-1 
while(i < length(args))
{
  if(args[i] == "--input"){
    j<-grep("-", c(args[(i+1):length(args)], "-"))[1]
    files<-args[(i+1):(i+j-1)]
    i<-i+j-1
  }else if(args[i] == "--output"){
    out_f<-args[i+1]
    i<-i+1
  }else{
    stop(paste("Unknown flag", args[i]), call.=FALSE)
  }
  i<-i+1
}
## load data ##
d <- read.csv("Result.csv")
#d <- read.csv(files)
summary(d)
na_VFINX <- which(is.na(d$VFINX))
d <- d[-c(na_VFINX),] # drop the na row in VFINX
library(zoo)
d_original <- na.locf(d) # fill na with the value prior to it

datelist<-matrix(c('2009-01-02','2016-01-04','2016-04-29',
                   '2009-04-01','2016-04-01','2016-07-29',
                   '2009-07-01','2016-07-01','2016-10-31',
                   '2009-10-01','2016-10-03','2017-01-31',
                   '2010-01-04','2017-01-03','2017-04-28',
                   '2010-04-01','2017-04-03','2017-07-31',
                   '2010-07-01','2017-07-03','2017-10-31',
                   '2010-10-01','2017-10-02','2018-01-31',
                   '2011-01-03','2018-01-02','2018-04-30',
                   '2011-04-01','2018-04-02','2018-07-31',
                   '2011-07-01','2018-07-02','2018-10-31',
                   '2011-10-03','2018-10-01','2019-01-31',
                   '2012-01-03','2019-01-02','2019-04-30',
                   '2012-04-02','2019-04-01','2019-07-31',
                   '2012-07-02','2019-07-01','2019-10-31',
                   '2012-10-01','2019-10-01','2020-01-31',
                   '2013-01-02','2020-01-02','2020-04-30',
                   '2013-04-01','2020-04-01','2020-07-31',
                   '2013-07-01','2020-07-01','2020-10-30',
                   '2013-10-01','2020-10-01','2020-12-31'
                   ),nrow = 20,ncol = 3,byrow = T)

i<-1
RMSE<-c()
RSE<-c()
Rsquare<-c()
null_RMSE<-c()
null_RSE<-c()
null_Rsquare<-c()
pseudo_rsquare<-c()

print(datelist)
for(i in 1:20){
d<-d_original
##traindata begin day##
splittime3<-datelist[i,1]

##testdata beginday(train data endday)##

splittime1<-datelist[i,2]

##testdata endday##

splittime2<-datelist[i,3]

print(paste(splittime3,splittime1,splittime2,sep=','))
train_index_begin<-which(d$Date==splittime3)#begin index of train set

test_index <- which(d$Date == splittime1) # index to split in the data set

test_index_end<-which(d$Date==splittime2)#end test index

print(train_index_begin)
print(test_index)
print(test_index_end)

d <- d_original[,-c(1)] # drop 'Date' column

## data processing ##
#nomalize
library(gradDescent)
scaled_data <- minmaxScaling(d)


# create shift dataset, e.g. t-1, t
lag_transform <- function(x, k= 1){
  lagged =  c(rep(NA, k), x[1:(length(x)-k)])
  DF = as.data.frame(cbind(lagged, x))
  colnames(DF) <- c( paste0('x-', k), 'x')
  DF[is.na(DF)] <- 0
  return(DF)
}

supervised <- sapply(scaled_data$scaledDataSet,lag_transform)
last_day <- c() # t-1 dataframe of input data (scaled_data)
for(i in c(1:(length(supervised)/2))){ # choose t-1 data
  last_day <- cbind(last_day, supervised[[1,i]])
}
scaled_sts <- cbind(last_day, scaled_data$scaledDataSet) # series to surpervise dataframe

##  split train and test data set ##
train <- scaled_sts[train_index_begin:test_index,]
#test <- scaled_sts[(test_index+1):nrow(scaled_sts),]
test <- scaled_sts[(test_index+1):test_index_end,]

train <- train[-c(1),] # drop 1st row, cuz t-1 are 0

x_train <- as.matrix(train[, 1:(ncol(train)/2)])
y_train <- as.matrix(train[,((ncol(train)/2)+1)])


x_test <- as.matrix(test[,1:(ncol(train)/2)])
y_test <- as.matrix(test[,((ncol(train)/2)+1)])


# x_train <- as.matrix(x_train[,])
# x_test <- as.matrix(x_test[,])

print(summary(train))
#create null model(glm)
names(train)[1:15]<-c('x1','x2','x3','x4','x5','x6','x7','x8','x9','x10','x11','x12','x13','x14','x15')
names(test)[1:15]<-c('x1','x2','x3','x4','x5','x6','x7','x8','x9','x10','x11','x12','x13','x14','x15')
print(names(train))
library(randomForest)
nullmodel <- randomForest(VFINX~.,data = train[,1:16],mtry=4,ntree=200)
plot(nullmodel)
print(summary(nullmodel))
nullresult<-predict(nullmodel,test)
print(nullresult)


# creat LSTM model

library(keras)
#install_keras()
# install_keras(method="conda",conda = "auto",version = "default", tensorflow = "default",)
#install_keras(method="virtualenv", envname="tf",version="default",tensorflow="default")

library(tensorflow)
#install_tensorflow()
#gpu <- tf$config$experimental$get_visible_devices('GPU')[[1]]
#tf$config$experimental$set_memory_growth(device = gpu, enable = TRUE)
# cpu <- tf$config$experimental$get_visible_devices('CPU')[[1]]
# tf$config$experimental$set_visible_devices(gpu)
dim_row <- nrow(x_train)
dim_col <- ncol(x_train)
dim(x_train) <- c(dim_row, 1, dim_col)
X_shape2 = dim(x_train)[2]
X_shape3 = dim(x_train)[3]
batch_size <-  36
units <-  17
epochs <- 300

adam <- optimizer_adam(lr = 0.001)
model <- keras_model_sequential()
model%>%
  layer_lstm(units,
             input_shape = c(X_shape2, X_shape3),
             activation = "tanh",
             recurrent_activation = "sigmoid",
             use_bias = TRUE,
             unroll = FALSE,
             recurrent_dropout = 0,
             return_sequences = FALSE
             )%>%
  # layer_lstm(units = 5, stateful= TRUE,return_sequences = FALSE)%>%
  layer_dense(units = 1)

model %>% compile(
  loss = 'mean_squared_error',
  optimizer = adam,
)




summary(model)

history <- model %>% fit(x          = x_train,
                         y          = y_train,
                         batch_size = batch_size,
                         epochs     = 100,
                         verbose    = 1,
                         shuffle    = FALSE)


library(ggplot2)
#plot training histroy


#reshape test data
dim_row <- nrow(x_test)
dim_col <- ncol(x_test)
dim(x_test) <- c(dim_row, 1, dim_col)

# predict the value
yhat <- model %>% predict(x_test)


# inverse the result of prediction
yhat <- data.frame(yhat)
descaling_para <- matrix(scaled_data$scalingParameter[,1], nrow = 2, ncol = 1)
yhat_inverse <- minmaxDescaling(yhat, descaling_para)

# inverse the true value
y_test <- data.frame(y_test)
y_inverse <- minmaxDescaling(y_test, descaling_para)

# inverse the true value
null_test <- data.frame(nullresult)
null_inverse <- minmaxDescaling(null_test, descaling_para)

rmse<-(mean((yhat_inverse[,1] - y_inverse[,1])^2))^0.5
mu = mean(y_inverse[,1])
rse = mean((yhat_inverse[,1] - y_inverse[,1])^2)/mean((mu-y_inverse[,1])^2)
rsquare=1-rse

null_rmse<-(mean((null_inverse[,1] - y_inverse[,1])^2))^0.5
null_mu = mean(y_inverse[,1])
null_rse = mean((null_inverse[,1] - y_inverse[,1])^2)/mean((null_mu-y_inverse[,1])^2)
null_rsquare=1-null_rse

RMSE<-c(RMSE,rmse)
RSE<-c(RSE,rse)
Rsquare<-c(Rsquare,rsquare)

null_RMSE<-c(null_RMSE,null_rmse)
null_RSE<-c(null_RSE,null_rse)
null_Rsquare<-c(null_Rsquare,null_rsquare)

## plot the result ##
data_plot1 <- data.frame(y_inverse)
data_plot2 <- data.frame(yhat_inverse)
result<-ggplot(data_plot1, aes(x = seq_along(y_test), y = y_test)) +
        geom_line(color='#56B4E9')+
        geom_line(data = data_plot2,aes(x=seq_along(yhat), y=yhat),color='red') +
        theme_grey(base_size = 16) +
        ggtitle(paste(splittime1,splittime2,sep = ' to ')) +
        labs(x = "time index", y = "price")
    print(result)
    
data_plot1 <- data.frame(y_inverse)
data_plot2 <- data.frame(null_inverse)
result<-ggplot(data_plot1, aes(x = seq_along(y_test), y = y_test)) +
      geom_line(color='#56B4E9')+
      geom_line(data = data_plot2,aes(x=seq_along(nullresult), y=nullresult),color='red') +
      theme_grey(base_size = 16) +
      ggtitle(paste(splittime1,splittime2,'nullmodel',sep = ' to ')) +
      labs(x = "time index", y = "price")
    print(result)
    
}

ansresult<-data.frame(RMSE=RMSE,RSE=RSE,Rsquare=Rsquare,RMSE_of_nullmodel=null_RMSE,RSE_of_nullmodel=null_RSE,Rsquare_of_nullmodel=null_Rsquare)
write.csv(ansresult,file='performance.csv',row.names = F,quote = F)

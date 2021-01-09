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
d <- na.locf(d) # fill na with the value prior to it


split_time <- "2019-09-30" #the time to split train an test set
test_index <- which(d$Date == split_time) # index to split in the data set
d <- d[,-c(1)] # drop 'Date' column

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
train <- scaled_sts[1:test_index,]
test <- scaled_sts[(test_index+1):nrow(scaled_sts),]

train <- train[-c(1),] # drop 1st row, cuz t-1 are 0

x_train <- as.matrix(train[, 1:(ncol(train)/2)])
y_train <- as.matrix(train[,((ncol(train)/2)+1)])

x_test <- as.matrix(test[,1:(ncol(train)/2)])
y_test <- as.matrix(test[,((ncol(train)/2)+1)])

# x_train <- as.matrix(x_train[,])
# x_test <- as.matrix(x_test[,])

# creat LSTM model
library(keras)
library(tensorflow)
gpu <- tf$config$experimental$get_visible_devices('GPU')[[1]]
tf$config$experimental$set_memory_growth(device = gpu, enable = TRUE)
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

## plot the result ##
data_plot1 <- data.frame(y_inverse)
data_plot2 <- data.frame(yhat_inverse)
ggplot(data_plot1, aes(x = seq_along(y_test), y = y_test)) +
        geom_line(color='#56B4E9')+
        geom_line(data = data_plot2,aes(x=seq_along(yhat), y=yhat),color='red') +
        theme_grey(base_size = 16) +
        ggtitle("Prediction") +
        labs(x = "time index", y = "price")

       
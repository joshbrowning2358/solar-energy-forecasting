machine = "linux-master"
source("C:/users/jbrowning/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/rockclimber112358/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/josh/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")

load( paste(data.dir,"/model_matrix_pc",sep=""))
d = d[,!grepl("Comp.",colnames(d))]
library(randomForest)
fit = randomForest( En ~ .
  ,data=d[d$train.fl==1,!colnames(d) %in% c("Station_Name","Date","cv.group")]
  ,ntree=10)
plot(fit)

pred = data.frame( En=predict( fit1, newdata=d[d$train.fl==0,]) )
pred$Station_Name = d[d$train.fl==0,]$Station_Name
pred$Date = as.character( d[d$train.fl==0,]$Date, "%Y%m%d" )
pred = cast( pred, Date ~ Station_Name, value="En", sum )
setwd("/home/josh/Documents/Kaggle/Solar Energy Forecasting/Models")
write.csv( file="001_basic_prediction.csv", pred, row.names=F )

cv.mod = lapply( 1:10, function(i){
  mod = glm( En ~ cos(Week) + sin(Week) + Lat + Long + Elev +
               Comp.1 + Comp.2 + Comp.3 + Comp.4 + Comp.5 +
               Comp.6 + Comp.7 + Comp.8 + Comp.9 + Comp.10+
               Comp.11+ Comp.12+ Comp.13+ Comp.14+ Comp.15+
               Comp.16+ Comp.17+ Comp.18+ Comp.19+ Comp.20
             ,data=d[d$cv.group!=i & d$train.fl==1,] )
  pred = predict( mod, newdata=d )
  #Don't allow a model to predict on data it used
  pred[! d$cv.group %in% c(i,-1)] = 0
  return(pred)
})
mod = eval.model.list(cv.mod)
write.csv( mod$pred, file="glm_20_comp.csv", row.names=F)

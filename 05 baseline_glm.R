machine="linux-master"
source("/home/rockclimber112358/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/josh/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")

load( paste(data.dir,"/model_matrix_pc",sep=""))

fit1 = lm( En ~ cos(Week) + sin(Week) + Lat + Long + Elev +
    Comp.1 + Comp.2 + Comp.3 + Comp.4 + Comp.5 +
    Comp.6 + Comp.7 + Comp.8 + Comp.9 + Comp.10+
    Comp.11+ Comp.12+ Comp.13+ Comp.14+ Comp.15+
    Comp.16+ Comp.17+ Comp.18+ Comp.19+ Comp.20, data=d[d$train.fl==1,] )
summary(fit1)
fit2 = lm( En ~ cos(Week) + sin(Week) + ., data=d[d$train.fl==1,-c(1,2)] )
summary(fit2)
fit3 = glm( En ~ cos(Week) + sin(Week) + Lat + Long + Elev +
     Comp.1 + Comp.2 + Comp.3 + Comp.4 + Comp.5 +
     Comp.6 + Comp.7 + Comp.8 + Comp.9 + Comp.10+
     Comp.11+ Comp.12+ Comp.13+ Comp.14+ Comp.15+
     Comp.16+ Comp.17+ Comp.18+ Comp.19+ Comp.20
  ,data=d[d$train.fl==1,], family=gaussian(link="log") )
summary(fit3)
d$Long.flr = as.factor(floor(d$Long))
fit4 = lm( En ~ cos(Week) + sin(Week) + Lat + Long + Elev +
    (Comp.1 + Comp.2 + Comp.3 + Comp.4 + Comp.5 +
     Comp.6 + Comp.7 + Comp.8 + Comp.9 + Comp.10)*Long.flr
  ,data=d[d$train.fl==1,] )
summary(fit4)

pred = data.frame( En=predict( fit1, newdata=d[d$train.fl==0,]) )
pred$Station_Name = d[d$train.fl==0,]$Station_Name
pred$Date = as.character( d[d$train.fl==0,]$Date, "%Y%m%d" )
pred = cast( pred, Date ~ Station_Name, value="En", sum )
setwd("/home/josh/Documents/Kaggle/Solar Energy Forecasting/Models")
write.csv( file="001_basic_prediction.csv", pred, row.names=F )

basic.mod = lapply( 1:10, function(i){
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
basic.mod = eval.model.list(basic.mod)
write.csv( basic.mod$pred, file="glm_20_comp.csv", row.names=F)
create.sub(basic.mod$pred, file="002_basic_prediction.csv")
zero.cnt = aggregate(basic.mod[[1]], by=list(Station_Name=d$Station_Name, Long=d$Long), function(x)sum(x==0))
ggplot( zero.cnt, aes(x=Long, y=x) ) + geom_point()

link.mod = lapply( 1:10, function(i){
  mod = glm( En ~ cos(Week) + sin(Week) + Lat + Long + Elev +
               Comp.1 + Comp.2 + Comp.3 + Comp.4 + Comp.5 +
               Comp.6 + Comp.7 + Comp.8 + Comp.9 + Comp.10+
               Comp.11+ Comp.12+ Comp.13+ Comp.14+ Comp.15+
               Comp.16+ Comp.17+ Comp.18+ Comp.19+ Comp.20
             ,data=d[d$cv.group!=i & d$train.fl==1,]
             ,family=gaussian(link=log))
  pred = exp(predict( mod, newdata=d ))
  #Don't allow a model to predict on data it used
  pred[! d$cv.group %in% c(i,-1)] = 0
  return(pred)
})
link.mod = eval.model.list(link.mod)
write.csv( link.mod$pred, file="glm_20_comp.csv", row.names=F)

fact.mod = lapply( 1:10, function(i){
  mod = glm( En ~ cos(Week) + sin(Week) + Lat + Long + Elev +
               (Comp.1 + Comp.2 + Comp.3 + Comp.4 + Comp.5 +
               Comp.6 + Comp.7 + Comp.8 + Comp.9 + Comp.10)*Long.flr
             ,data=d[d$cv.group!=i & d$train.fl==1,]
             ,family=gaussian(link=log))
  pred = exp(predict( mod, newdata=d ))
  #Don't allow a model to predict on data it used
  pred[! d$cv.group %in% c(i,-1)] = 0
  return(pred)
})
fact.mod = eval.model.list(fact.mod)
write.csv( fact.mod$pred, file="glm_20_comp.csv", row.names=F)

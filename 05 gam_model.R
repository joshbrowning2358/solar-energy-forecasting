machine = "linux-master"
source("C:/users/jbrowning/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/rockclimber112358/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/josh/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")

load( paste(data.dir,"/model_matrix_pc",sep=""))
library(gam)

for( i in c(4:6,83:158) ){
  to.plot = d[sample(1:nrow(d),size=40000),c(3,i)]
  print( ggplot( to.plot, aes_string(x=colnames(d)[i], y="En")) + geom_point(alpha=.05) +
    geom_smooth() )
  readline(colnames(d)[i])
}

mod.parms = 1:10
mod.parms = merge( mod.parms, c(2^(0:6),75))
colnames(mod.parms) = c("CV", "Comp.cnt")
gam.lo.mod = mapply( function(i,comp.cnt){
    form = formula( paste("En ~ lo(Week) + Lat + Long + lo(Elev) +"
      ,paste("lo(Comp.",1:comp.cnt,")",collapse=" + ", sep="") ) )
    mod = gam( form, data=d[d$cv.group!=i & d$train.fl==1,] )
    pred = predict( mod, newdata=d )
    #Don't allow a model to predict on data it used
    pred[! d$cv.group %in% c(i,-1)] = 0
    return(pred)
  }
  ,i=mod.parms[,1], comp.cnt=mod.parms[,2])
#Create a list with the different models:
mods.list = lapply( 1:(nrow(mod.parms)/10), function(i){#/10 for the cv.groups
  parms = mod.parms[(i-1)*10+1,-1]
  cv.data = lapply(((i-1)*10+1):(i*10), function(x)gam.lo.mod[,x] )
  return( list(parms=parms, mod=cv.data) )
} )
for( i in 1:length(mods.list) ){
  mod = eval.model.list(mods.list[[i]][[2]])
  create.sub(mod[[1]], file=paste("003_gam_full_MAE_",round(mod[[2]]),"_Comps_",mods.list[[i]][[1]],".csv",sep="") )
}
gam.lo.mod = eval.model.list(gam.lo.mod)
write.csv( gam.lo.mod$pred, file="gam_20_comp.csv", row.names=F)
create.sub(gam.lo.mod$pred, file="003_gam_prediction.csv")

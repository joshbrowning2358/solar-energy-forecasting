machine = "linux-master"
source("C:/users/jbrowning/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/rockclimber112358/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/josh/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")

setwd(train.dir)
stat = list.files()
stat = stat[grepl("interp.csv",stat)]
stat = gsub("(train_|_avgd_interp.csv)","",stat)
for( i in stat ){
  train.temp = read.csv( file=paste(train.dir,"/train_",i,"_avgd_interp.csv",sep=""))
  test.temp = read.csv(file=paste(test.dir,"/test_",i,"_avgd_interp.csv",sep=""))
  out = rbind( train.temp, test.temp )
  rm( train.temp, test.temp )
  out$Lat = NULL; out$Long=NULL
  colnames(out)[2] = i
  print( paste("Writing file: final_",i,".csv",sep=""))
  write.csv( file=paste(data.dir,"/final_",i,".csv",sep=""), out)
}

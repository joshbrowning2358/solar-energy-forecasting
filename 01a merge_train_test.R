machine = "linux-master"
source("C:/users/jbrowning/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/rockclimber112358/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/josh/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")

setwd(train.dir)
files = list.files()
files = files[grepl("avgd.csv", files)]
files = gsub( "(train_|_avgd.csv)","",files)
for( i in files ){
  train = read.csv( file=paste(train.dir, "/train_",i,"_avgd.csv",sep=""))
  test = read.csv( file=paste(test.dir, "/test_",i,"_avgd.csv",sep=""))
  d = rbind( train, test )
  write.csv( d, file=paste(data.dir, "/Aggregated/",i,"_avgd.csv",sep=""), row.names=F )
}

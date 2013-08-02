machine = "linux-master"
source("C:/users/jbrowning/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/rockclimber112358/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/josh/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")

#load in energy values for training set
train = read.csv( file=paste(data.dir,"/train.csv", sep="") )
train = melt( train, id.vars="Date")
colnames(train) = c("Date", "Station_Name", "En")
sinfo = read.csv( file=paste(data.dir,"/station_info.csv", sep="") )
colnames(sinfo) = c("Station_Name","Lat","Long","Elev")
train = merge( train, sinfo, by="Station_Name")
train$train.fl = 1

#load in dummy records for test set
test = read.csv( file=paste(data.dir,"/sampleSubmission.csv", sep="") )
test = melt( test, id.vars="Date")
colnames(test) = c("Date", "Station_Name", "En")
test = merge( test, sinfo, by="Station_Name")
test$train.fl = 0
d = rbind( train, test )
d$Long = d$Long + 360
d$Date = as.Date( as.character(d$Date), format="%Y%m%d")
rm( train, test )

#merge in the cloud coverage data
setwd(data.dir)
files = list.files()
files = files[grepl("final_",files)]
for( i in files ){
  to.bind = read.csv( file=i)
  to.bind = cast( to.bind, Date + stat.name ~ Hour
    , value=gsub("(final_|.csv)","",i), sum )
  to.bind$Date = as.Date( to.bind$Date/24, origin=as.Date("18000101","%Y%m%d"))
  colnames(to.bind)[3:7] = paste(gsub("(final_|.csv)","",i),"_",c(12,15,18,21,24),sep="")
  colnames(to.bind)[colnames(to.bind)=="stat.name"] = "Station_Name"
  d = merge( d, to.bind )
}
pc = princomp( d[,grepl("[0-9]",colnames(d))])
d = rbind( d, pc$scores )
d$Week = as.numeric( as.character( d$Date, "%W" ) )
d$cv.group = -1
d$cv.group[d$train.fl==1] = sample(1:10,size=sum(d$train.fl),replace=T)
save(d, file=paste(data.dir,"/model_matrix_pc",sep=""))
sum( is.na(d) ) #Should be 0

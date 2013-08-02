machine = "linux-master"
source("C:/users/jbrowning/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/rockclimber112358/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/josh/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")

d = read.csv( file=paste(train.dir,"/train_tcdc_eatm_avgd.csv",sep="" ), stringsAsFactors=F ); d$X=NULL
d$Time = as.POSIXct(as.Date(d$Date/24, origin=as.Date("18000101","%Y%m%d")))+d$Hour*3600
sinfo = read.csv( file=paste(data.dir,"/station_info.csv", sep="" ) )
colnames(sinfo) = c("Station_Name", "Lat", "Long", "Elev")
sinfo$Long = 360 + sinfo$Long

###Fit a model including time as a variable:
#Generate the gstat object:
sp = SpatialPoints( unique( d[,c("Long","Lat")] ) )
d.st = STFDF(sp, time=unique(d$Time), data=data.frame(x=d[,c("vals")]) )
#Sample down so the variogram doesn't take forever:
d.st = STFDF(sp, time=unique(d$Time[d$Time<as.POSIXct("1994/05/01 00:00:00")])
  ,data=data.frame(x=d[d$Time<as.POSIXct("1994/05/01 00:00:00"),c("vals")]) )
summary(d.st)
vv = variogram( x~1, d.st, width=.5, cutoff=6 )
plot(vv,wireframe=T,col.regions=bpy.colors())
plot(vv)
to.plot = data.frame(vv)
ggplot( to.plot, aes(x=spacelag, y=gamma, color=timelag, group=timelag ) ) +
  geom_line()
ggplot( to.plot, aes(x=timelag, y=gamma, color=spacelag, group=spacelag ) ) +
  geom_line()
?vgmST

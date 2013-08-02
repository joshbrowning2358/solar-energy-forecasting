machine = "linux-master"
source("C:/users/jbrowning/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/rockclimber112358/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/josh/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
library(ncdf4)

#Plot ensembles to verify that each prediction is comparable
setwd(train.dir)
files = list.files()
files = files[grepl(".nc",files)]
for( j in files ){
  train = nc_open(filename=j)
  d = ncvar_get(nc=train)
  lat = round( runif(1)*9+.5 )
  long = round( runif(1)*16+.5 )
  to.plot = d[long,lat,,,]
  #Use lapply to create a list where each element is a numeric vector
  # ordered in time (hour and date)
  to.plot = lapply( 1:11, function(x)as.numeric( to.plot[,x,] ) )
  to.plot = data.frame( do.call("cbind", to.plot ) )
  d.names = lapply( c(3,5), function(x)train$var[[3]]$dim[[x]]$vals )
  d.names = merge( d.names[[1]], d.names[[2]] )
  to.plot$time = d.names[,1] + d.names[,2]
  C = cor( to.plot[,-12] )
  #Plot the correlation matrix:
  C = melt( C, measure.vars=1:11 )
  C$X1 = gsub("X","Ensem ", C$X1); C$X1=factor(C$X1, levels=paste("Ensem",1:11))
  C$X2 = gsub("X","Ensem ", C$X2); C$X2=factor(C$X2, levels=paste("Ensem",1:11))
  plot.name = paste(plot.dir, "/Ensemble_Correlation_Matrix_"
    ,gsub("latlon_subset_19940101_20071231.nc","",j)
    ,"_lat_" ,lat
    ,"_long_" ,long, ".png", sep="")
  ggsave(plot.name
    ,ggplot( C, aes(x=X1, y=X2, fill=value) ) + geom_tile() + plot_theme +
      labs(x="", y="", fill="Correlation", title="Correlation Matrix for 1 point")
    ,width=14, height=14, units="in" )
  nc_close(train); rm(train)
}

#Verify that interpolated values are close (pick a few points by a grid)
#Latitude: 35.97, Longitude: 265.01, Station: TAHL
#Latitude: 36.42, Longitude: 260.6, Station: WOOD
stat.name = "WOOD"
interp = read.csv( file=paste(train.dir,"/train_dlwrf_sfc_avgd_interp.csv", sep="") )
interp = interp[interp$stat.name==stat.name,]
interp$time = interp$Date + interp$Hour
lat.vals = c(floor(min(interp$Lat)), ceiling(max(interp$Lat)))
long.vals = c(floor(min(interp$Long)), ceiling(max(interp$Long)))
grid = read.csv( file=paste(train.dir,"/train_dlwrf_sfc_avgd.csv", sep="") )
grid = grid[grid$Lat %in% lat.vals & grid$Long %in% long.vals,]
grid$time = grid$Date + grid$Hour
to.plot = merge( cast( grid, time ~ Lat + Long, value="vals", sum )
  ,interp[,c("time","value")] )
colnames(to.plot)[ncol(to.plot)] = "Interp"
cor( to.plot )
to.plot.1 = melt( to.plot, id.vars=c("time", "Interp") )
ggsave( paste(plot.dir, "/Interp_vs_Grid_",stat.name,".png", sep=""),
  ggplot( to.plot.1, aes(x=value, y=Interp) ) + geom_point() +
    facet_wrap( ~ variable ) +
    labs(x="Grid Values", y="Interpolated Values", title=paste("Station: ",stat.name," (", interp$Lat[1], ",", interp$Long[1], ")", sep="")) +
    plot_theme + geom_smooth()
  ,width=15, height=15, dpi=400, units="in")

to.plot.2 = melt( to.plot, id.vars="time" )
  ggplot( to.plot.2[to.plot.2$time<=1701000,], aes(x=time, y=value, color=variable) ) + geom_line() +
    labs(x="Time", y="Variable Values", color="Location", title=paste("Station: ",stat.name," (", interp$Lat[1], ",", interp$Long[1], ")", sep="")) +
    scale_x_continuous(breaks=c()) +
    plot_theme

#Verify that kriged values are close (pick a few points by a grid)

#Compare atmospheric variables to solar energy (for a fixed station)
stations = read.csv( file=paste(data.dir,"/station_info.csv", sep=""), stringsAsFactors=F)[,1]
for( stat.name in stations ){
  train = read.csv( file=paste(data.dir,"/train.csv", sep=""))
  train = train[,c("Date",stat.name)]
  setwd(train.dir)
  files = list.files()
  files = files[grepl("_interp.csv",files)]
  atm = read.csv(paste(train.dir,"/",files[1],sep=""))
  atm = atm[atm$stat.name==stat.name,c("Date","Hour","value")]
  colnames(atm)[ncol(atm)] = gsub("(train_|_avgd_interp.csv)","",files[1])
  for( i in files[-1]){
    temp=read.csv(i)
    temp=temp[temp$stat.name==stat.name,c("Date","Hour","value")]
    colnames(temp)[ncol(temp)] = gsub("(train_|_avgd_interp.csv)","",i)
    atm = merge(atm, temp)
  }
  atm.daily = aggregate(atm[,3:ncol(atm)], by=list(Date=atm$Date), mean)
  atm.daily$Date = as.Date( atm.daily$Date/24, origin=as.Date("18000101","%Y%m%d"))
  train$Date = as.Date( as.character( train$Date ), "%Y%m%d" )
  to.plot = merge( train, atm.daily )
  to.plot.1 = melt( to.plot, id.vars="Date" )
  ggsave(paste(plot.dir,"/time_plots_1994_",stat.name,".png",sep=""),
    ggplot( to.plot.1[to.plot$Date<as.Date("19941231","%Y%m%d"),], aes(x=Date, y=value, color=variable ) ) + geom_line() + 
      facet_wrap(~variable, scale="free") + labs(x="",color="Variable", title=stat.name)
    ,width=15, height=15, units="in", dpi=400 )
  C = cor(to.plot[,-1])
  C = melt(C,id.vars=c())
  #Relevel so station appears at bottom of C matrix:
  C[,1]=relevel(C[,1],stat.name); C[,2]=relevel(C[,2],stat.name)
  ggsave(paste(plot.dir,"/corr_matrix_",stat.name,".png",sep=""),
    ggplot( C, aes(x=X1,y=X2,fill=value)) + geom_tile() + plot_theme +
      geom_text(aes(label=round(value,2)),size=4) + labs(x="", y="", fill="Correlation", title=paste(stat.name,"Corr. Matrix"))
    ,width=15, height=15, units="in", dpi=400 )
  to.plot.2 = melt( to.plot, id.vars=c("Date",stat.name))
  ggsave(paste(plot.dir,"/scatter_",stat.name,".png",sep=""),
    ggplot( to.plot.2, aes_string(x="value", y=stat.name, color="variable") ) + geom_point(alpha=.05) +
      facet_wrap( ~ variable, scale="free" ) + geom_smooth() +
      labs(x="Atmospheric Variable Value",color="Variable",title=stat.name)
    ,width=15, height=15, units="in", dpi=400 )
}

#Compare atmospheric variables to solar energy (over all stations)

#Plot energy as a function of elevation, latitude, longitude, time of year
train = read.csv( file=paste(data.dir,"/train.csv", sep="") )
train = melt( train, id.vars="Date")
colnames(train) = c("Date", "Station_Name", "En")
sinfo = read.csv( file=paste(data.dir,"/station_info.csv", sep="") )
colnames(sinfo) = c("Station_Name","Lat","Long","Elev")
train = merge( train, sinfo, by="Station_Name")

train$Date = as.Date( as.character(train$Date), "%Y%m%d" )
train$Week = as.numeric(as.character(train$Date,"%W"))
train$Lat.Plot = round( train$Lat )
train$Long.Plot = round( train$Long )
train$Lat.Long = paste("Lat:",train$Lat.Plot,"Long:",train$Long.Plot)
ggplot( train, aes(x=Week, y=En) ) + geom_point() +
  facet_grid( Lat.Plot ~ Long.Plot )
ggsave(paste(plot.dir,"/lat_long_time_energy.png",sep=""),
  ggplot( train, aes(x=Week, y=En, color=Lat.Plot, group=Lat.Plot) ) +
    geom_smooth(se=F) + facet_wrap( ~ Long.Plot )
  ,width=15, height=15, dpi=400, units="in" )

fit = lm( En ~ elev + nlat + Week, data=to.plot )
summary( fit )

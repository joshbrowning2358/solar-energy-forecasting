machine = "linux-master"
source("C:/users/jbrowning/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/rockclimber112358/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/josh/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
setwd(data.dir)

stat.coord = read.csv( file=paste(data.dir, "/station_info.csv", sep="" ) )
stat.name = stat.coord[,1]
stat.coord = stat.coord[,c("nlat","elon")]
stat.coord$elon = 360 + stat.coord$elon
colnames( stat.coord ) = c("Lat","Long")

#Grab the lat, long, hour and date from a ensemble data file
d = read.csv( file=paste(train.dir,"/train_tmax_2m_avgd.csv", sep="") )
grid = unique( d[,c("Long","Lat")] )
rm(d)

#Bilinear interpolation: http://en.wikipedia.org/wiki/Bilinear_interpolation
#Interpolation depends linearly on the 4 z values that define a square containing
# the point of interest.  So, we can define a matrix A such that the interpolation
# is simply z_sensor=A*z_grid (and A is constant, which should save computations)
A = matrix(0, nrow=nrow(stat.coord), ncol=nrow(grid) )
for(i in 1:nrow(stat.coord) ){
  x = stat.coord[i,2]
  y = stat.coord[i,1]
  x1=floor(x)
  x2=ceiling(x)
  y1=floor(y)
  y2=ceiling(y)
  coeff = c((x2-x)*(y2-y), (x-x1)*(y2-y), (x2-x)*(y-y1), (x-x1)*(y-y1))
  rows = rownames(grid[grid$Long %in% c(x1,x2)&grid$Lat %in% c(y1,y2),])
  A[i,as.numeric(rows)] = coeff
}

#Perform the interpolation:
setwd(train.dir)
files = list.files()
files = files[grepl("avgd.csv",files)]
memory.limit(8000)
for( j in files ){
  d = read.csv( file=j ); d$X=NULL
  d = cast( d, Lat + Long ~ Date + Hour, value="vals", sum )
  z0 = as.matrix(d[,-c(1,2)])
  z = A%*%z0
  out = data.frame( stat.name, stat.coord, z )
  rm( z, z0 )
  colnames(out)[-(1:3)] = colnames(d)[-(1:2)]
  out = melt( out, id.vars=1:3 )
  time.vars = strsplit(as.character(out$variable),"_")
  time.vars = do.call("rbind", time.vars)
  time.vars = apply( time.vars, c(1,2), as.numeric )
  out$variable = NULL
  out$Date = time.vars[,1]
  out$Hour = time.vars[,2]
  print(paste("Writing file", gsub(".csv","_interp.csv", j) ) )
  write.csv( file=gsub(".csv","_interp.csv", j), out, row.names=F )
  rm( d, out )
}

setwd(test.dir)
files = list.files()
files = files[grepl("avgd.csv",files)]
for( j in files ){
  d = read.csv( file=j ); d$X=NULL
  d = cast( d, Lat + Long ~ Date + Hour, value="vals", sum )
  z0 = as.matrix(d[,-c(1,2)])
  z = A%*%z0
  out = data.frame( stat.name, stat.coord, z )
  rm( z, z0 )
  colnames(out)[-(1:3)] = colnames(d)[-(1:2)]
  out = melt( out, id.vars=1:3 )
  time.vars = strsplit(as.character(out$variable),"_")
  time.vars = do.call("rbind", time.vars)
  time.vars = apply( time.vars, c(1,2), as.numeric )
  out$variable = NULL
  out$Date = time.vars[,1]
  out$Hour = time.vars[,2]
  print(paste("Writing file", gsub(".csv","_interp.csv", j) ) )
  write.csv( file=gsub(".csv","_interp.csv", j), out, row.names=F )
  rm( d, out )
}

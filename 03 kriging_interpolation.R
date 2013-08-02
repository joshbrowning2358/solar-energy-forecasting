machine = "linux-master"
source("C:/users/jbrowning/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/rockclimber112358/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/josh/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")

setwd(paste(data.dir,"/Aggregated",sep=""))
files = list.files()
files = files[grepl("_avgd.csv",files)]
#library(kriging)

stat.pts = read.csv( paste(data.dir,"/station_info.csv",sep=""))
colnames(stat.pts) = c("Station_Name","Lat","Long","Elev")
stat.pts$Elev = NULL;

for( i in files ){
  d = read.csv( file=i ); d$X=NULL
  ds = d[d$Date <= 1701000,]

  #Create gstat object
  #coordinates(ds) = c("Long", "Lat" )
  g <- gstat(id = "vals", formula = vals~Date+Hour, locations = ~Long+Lat
    , data = ds)
  
  #Compute empirical variogram and fit a model to it.  Should consider
  #spatial anisotropy as well...
  v = variogram( g, dX=0 )
  f = fit.variogram(v, model=vgm(model='Sph', range=2))
  plot( v, model=f )

  stat.pts = merge( stat.pts, ds[,c("Date","Hour")])
  pred = predict(g, newdata=stat.pts )
  pred = merge( pred, )
}

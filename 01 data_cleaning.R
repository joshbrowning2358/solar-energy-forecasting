machine = "linux-master"
source("C:/users/jbrowning/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/rockclimber112358/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/josh/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")

install.packages("ncdf")
install.packages(paste(data.dir,"/ncdf4_1.9.tar.gz",sep=""), repos=NULL, type="source")
library(ncdf4)
#Override directory with location of .nc files:
setwd("C:/Users/jbrowning/Documents/Personal/Kaggle/Solar Energy Forecasting/Data/Train")
files = list.files()
files = files[grepl(".nc", files)]
memory.limit(16000)
for( j in files ){
  train = nc_open(filename=j)
  d = ncvar_get(nc=train)
  dav = (d[,,,1,] + d[,,,2,] + d[,,,3,] + d[,,,4,] + d[,,,5,] + d[,,,6,] +
     d[,,,7,] + d[,,,8,] + d[,,,9,] + d[,,,10,] + d[,,,11,])/11
  d.names = lapply( 1:5, function(x)train$var[[3]]$dim[[x]]$vals )
  d.names = d.names[-4]
  file.name = j
  file.name = paste0(train.dir, "/train_", sub( "_latlon_subset_19940101_20071231.nc", "_avgd.csv", j ) )
  rm( d )
  d.df = data.frame( Long=rep(d.names[[1]], 9*5*5113)
      ,Lat=rep(rep(d.names[[2]],each=16),5*5113)
      ,Hour=rep(rep(d.names[[3]],each=16*9),5113)
      ,Date=rep(d.names[[4]],each=16*9*5)
      ,vals=as.numeric(dav) )
  write.csv( d.df, file.name, row.names=F )
  rm(d.df, dav )
  nc_close(train); rm(train)
}

#Override directory with location of .nc files:
setwd("C:/Users/jbrowning/Documents/Personal/Kaggle/Solar Energy Forecasting/Data/Test")
files = list.files()
files = files[grepl(".nc", files)]
memory.limit(16000)
for( j in files ){
  train = nc_open(j)
  d = ncvar_get(train)
  dav = (d[,,,1,] + d[,,,2,] + d[,,,3,] + d[,,,4,] + d[,,,5,] + d[,,,6,] +
     d[,,,7,] + d[,,,8,] + d[,,,9,] + d[,,,10,] + d[,,,11,])/11
  d.names = lapply( 1:5, function(x)train$var[[3]]$dim[[x]]$vals )
  d.names = d.names[-4]
  file.name = j
  file.name = paste0(test.dir, "/test_", sub( "_latlon_subset_20080101_20121130.nc", "_avgd.csv", j ) )
  rm( d )
  d.df = data.frame( Long=rep(d.names[[1]], 9*5*1796)
      ,Lat=rep(rep(d.names[[2]],each=16),5*1796)
      ,Hour=rep(rep(d.names[[3]],each=16*9),1796)
      ,Date=rep(d.names[[4]],each=16*9*5)
      ,vals=as.numeric(dav) )
  write.csv( d.df, file.name, row.names=F )
  nc_close(train); rm(train)
}

machine = "linux-master"
source("C:/users/jbrowning/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/rockclimber112358/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")
source("/home/josh/Ubuntu One/Solar Energy Forecasting/R Scripts/libraries.R")

setwd(train.dir)
files = list.files()
files = files[grepl("Ensem[0-9]*.csv", files)]

for( j in 1:(length(files)/11) ){
  d = read.csv(files[(j-1)*11+1])[,6]/11
  for( i in 2:11){
    d = d + read.csv(files[(j-1)*11+i])[,6]/11
    print(paste0("i=",i," j=",j))
  }
  file.name = gsub("_Ensem1.csv", "_avged.csv", files[(j-1)*11+1] )
  write.csv( file=file.name, d, row.names=F )
}

setwd(test.dir)
files = list.files()
files = files[grepl("Ensem[0-9]*.csv", files)]

for( j in 1:(length(files)/11) ){
  d = read.csv(files[(j-1)*11+1])[,6]/11
  for( i in 2:11){
    d = d + read.csv(files[(j-1)*11+i])[,6]/11
    print(paste0("i=",i," j=",j))
  }
  file.name = gsub("_Ensem1.csv", "_avged.csv", files[(j-1)*11+1] )
  write.csv( file=file.name, d, row.names=F )
}

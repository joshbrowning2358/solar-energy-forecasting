library(ggplot2)
library(plyr)
library(reshape)
library(neuralnet) #Fitting neural nets to all data, may not use...
library(sp) #Spatial library
library(spacetime) #for spacetime variograms/objects
library(gstat) #for computing variograms
library(lattice) #for 3d variogram plots

#Use UTC time:
Sys.setenv(TZ='GMT')

if(machine=="Windows"){
  train.dir = "C:/users/jbrowning/Documents/Personal/kaggle/solar energy forecasting/data/train"
  test.dir = "C:/users/jbrowning/Documents/Personal/kaggle/solar energy forecasting/data/test"
  data.dir = "C:/users/jbrowning/Documents/Personal/kaggle/solar energy forecasting/data"
  plot.dir = "C:/users/jbrowning/Documents/Personal/kaggle/solar energy forecasting/Plots"
}

if(machine=="Dino"){
  train.dir = "/home/rockclimber112358/Desktop/Solar Energy Forecasting/Data/Train"
  test.dir = "/home/rockclimber112358/Desktop/Solar Energy Forecasting/Data/Test"
  data.dir = "/home/rockclimber112358/Desktop/Solar Energy Forecasting/Data"
  data.dir = "/home/rockclimber112358/Desktop/Solar Energy Forecasting/Plots"
}

if(machine=="linux-master"){
  train.dir = "/home/josh/Documents/Kaggle/Solar Energy Forecasting/Data/Train"
  test.dir = "/home/josh/Documents/Kaggle/Solar Energy Forecasting/Data/Test"
  data.dir = "/home/josh/Documents/Kaggle/Solar Energy Forecasting/Data"
  plot.dir = "/home/josh/Documents/Kaggle/Solar Energy Forecasting/Plots"
}

plot_theme = theme(plot.title   = element_text(family = "sans", size = 20, face = "bold"),
  axis.title.x = element_text(family = "sans", colour = "black", size = 18),
  axis.title.y = element_text(family = "sans", colour = "black", size = 18, angle = 90, vjust = 0.25),
  legend.title = element_text(family = "sans", colour = "black", size = 18), 
  axis.text.x  = element_text(family = "sans", colour = "black", size = 16, angle = 45, hjust = 1, vjust = 1),
  axis.text.y  = element_text(family = "sans", colour = "black", size = 16),
  strip.text.x = element_text(family = "sans", colour = "black", size = 16),
  strip.text.y = element_text(family = "sans", colour = "black", size = 16),
  legend.text  = element_text(family = "sans", colour = "black", size = 16),
  panel.grid.major = element_line(colour = "#AAAAAA"),
  panel.grid.minor = element_line(colour = "#EEEEEE"),
  panel.background = element_rect(fill = "transparent", colour = NA),
  plot.margin = unit(c(1, 1, 0, 4), "lines"));

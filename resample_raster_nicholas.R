library(sf)
library(raster)
library(automap)
library(tidyverse)
library(viridis)
library(ggspatial)
library(automap)
library(ggplot2)
library(magrittr)
library(geodata)
library(tidyverse)
library(terra)
#library(climateR)
#library(AOI)
library(raster)
library(rasterVis)
library(dplyr)
library(ggpmisc)
library(ggpubr)
library(ggpp)
library(devtools)

#install.packages("AOI")

# Ler shapefile da Amazônia
shp_am <- read_sf('amazon_250.shp')
shp_am = st_transform(shp_am, 4674)
shp_am

# Ler e limpar dados climáticos
amazon_clim_df10_clean<-read.csv("amazon_clim_df10_naless.csv", header = TRUE)
head(amazon_clim_df10_clean)
amazon_clim_df10_naless<-na.omit(amazon_clim_df10_clean)
amazon_clim_df10_naless
gridded(amazon_clim_df10_naless)<-~x+y
extent(amazon_clim_df10_naless)

#dataframe with auxiliary variables (MAP, MAT, etc...)
data<-read.csv("2024_10_07_Results_Complete_LEI_Isabela.csv")
head(data)
summary(data)

ood_evals = TRUE
if (ood_evals) {
  train_df<-read.csv("12_16_filtered_train_random_grouped.csv")
  test_df<-read.csv("12_16_filtered_test_random_grouped.csv")
  validation_df<-read.csv("12_16_filtered_validation_random_grouped.csv")
  train_df$Code
  data$code
  # Filter
  full_data<-data
  data<-data[data$code %in% train_df$Code, ]
}
nrow(validation_df)+nrow(train_df)+nrow(test_df)
df<-data
##grided longitude and latitude of data
x<-data$longitude
y<-data$latitude
xy <- SpaCodexy <- SpatialPointsDataFrame(matrix(c(x,y), ncol=2), data.frame(ID=seq(1:length(x))),
                                          proj4string=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))
xy <- spTransform(xy, CRS("+init=epsg:27700 +datum=WGS84"))


## Grouping nearby geographic coordinates. 
#To improve the interpolation we grouped the nearby geographic coordinates using a d of 200000 meters
chc <- hclust(dist(data.frame(rownames=rownames(xy@data), x=coordinates(xy)[,1],
                              y=coordinates(xy)[,2])), method="complete")

plot(chc)
#d= 200000 # Set distance (in meters) so that points are grouped (1? = 111000 meters) 
d=200
chc.dist <- cutree(chc, h=d) 
plot(chc.dist)
xy@data <- data.frame(xy@data, Clust=chc.dist)
xy@data$Clust->data$Clust
data$Clust

## Grouping all groups generated according to the mean for d13C
#Here we made a mean by clusters
data$Clust<-as.factor(data$Clust)
data
data
summary(data)
options(dplyr.print_max = 1e9)
pontos<-dplyr::group_by(data, Clust)
head(pontos)
str(pontos)
#pontos_vap<-dplyr::summarise(pontos, longitude = mean(longitude), latitude = mean(latitude),C = mean (C_wood, na.rm=TRUE), N = mean (N_wood, na.rm=TRUE), density = mean (density, na.rm=TRUE), d18O = mean(d18O, na.rm=TRUE), d13C = mean(d13C_wood, na.rm=TRUE), d15N = mean(d15N_wood, na.rm=TRUE), vpd = mean(vpd, na.rm=TRUE), rh = mean(rh, na.rm=TRUE), pet = mean(pet, na.rm=TRUE), dem = mean(dem, na.rm=TRUE), pa = mean(pa, na.rm=TRUE), MAT = mean(mat, na.rm=TRUE), MAP = mean(map, na.rm=TRUE), d15N_soil = mean(d15N_soil, na.rm=TRUE), d15N_foliar = mean(d15N_foliar, na.rm=TRUE), d13C_foliar = mean(d13C_foliar, na.rm=TRUE))
pontos_vap<-dplyr::summarise(pontos, longitude = mean(longitude), latitude = mean(latitude), d18O = mean(d18O, na.rm=TRUE), MAP = mean(map, na.rm=TRUE), d13C_foliar = mean(d13C_foliar, na.rm=TRUE))
head(pontos_vap)
pontos_vap

nrow(pontos)
nrow(pontos_vap)

#grid the new data frame
coordinates(pontos_vap) = ~ longitude+latitude

###Finally, we will start the interpolations
pontos_vap_df<-as.data.frame(pontos_vap,xy=T)
pontos_vap_df

####Universal kriging
autogrik_d18O_map<-autoKrige(d18O ~ MAP+d13C_foliar,  pontos_vap, amazon_clim_df10_naless)
autogrik_d18O_map
summary(autogrik_d18O_map)
autogrik_d18O_map
as.data.frame(autogrik_d18O_map$var_model)

##### resample raster ##############
raster_coarse_df <- as.data.frame(autogrik_d18O_map$krige_output[,"var1.pred"], xy = T, na.rm = TRUE)
raster_coarse_pts <- terra::vect(raster_coarse_df, geom = c("x", "y"))
crs(raster_coarse_pts) <- 'epsg:5880'

# Create an empty raster limited by the extent of the shapefile
r <- rast(nrow=127, ncol=183, ext=shp_am)
r
crs(r) <- 'epsg:5880' #Define the CRS of raster

values(r) <- runif(ncell(r))

# Limit the extent of the AutoKrige output vector using the created empty raster
r <- mask(r,raster_coarse_pts) 
plot(r)

# Create an empty raster limited according the need
fine<- rast(ext=shp_am,nrow=1024,ncol=1476)
fine
crs(fine) <- 'epsg:5880'

###
### Export Means
###

# Rasterize the vect of the isoscape according limit the extent of the shapefile
raster_output <- rasterize(terra::vect(autogrik_d18O_map$krige_output[,"var1.pred"]), r, field="var1.pred", fun=mean)
crs(raster_output) <- 'epsg:5880'
plot(raster_output)

# Resample isoscape using the the empty raster already generated
resample_raster_output <- resample(raster_output, fine, "bilinear")
plot(resample_raster_output)

#save
writeRaster(resample_raster_output, "gabi_iso_d18O_wood_map_random_ood_split.tiff", overwrite = T)

### 
### Export Variance
### 
# Rasterize the vect of the isoscape according limit the extent of the shapefile
raster_output <- rasterize(terra::vect(autogrik_d18O_map$krige_output[,"var1.var"]), r, field="var1.var", fun=mean)
crs(raster_output) <- 'epsg:5880'
plot(raster_output)

# Resample isoscape using the the empty raster already generated
resample_raster_output <- resample(raster_output, fine, "bilinear")
plot(resample_raster_output)

#save
writeRaster(resample_raster_output, "gabi_iso_d18O_wood_map_random_ood_split_var.tiff", overwrite = T)

dir(autogrik_d18O_map)

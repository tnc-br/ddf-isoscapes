#isoscape C e N wood - regression kriging 
## Loading packages
#install.packages("automap")
#install.packages("tidyverse")
#install.packages('ggpmisc')
#install.packages('ggpp')
#install.packages('ggspatial')
#remotes::install_github("mikejohnson51/AOI")
#remotes::install_github("mikejohnson51/climateR", force=TRUE)
setwd('/home/nicholasroth/regression_kriging_repro')
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
library(climateR)
library(AOI)
library(raster)
library(rasterVis)
library(dplyr)
library(ggpmisc)
library(ggpubr)
library(ggpp)
library(devtools)
#install_github("https://github.com/aphalo/ggpp")

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
  train_df<-read.csv("12_16_filtered_train_random_iid_nonan.csv")
  test_df<-read.csv("12_16_filtered_test_random_iid_nonan.csv")
  validation_df<-read.csv("12_16_filtered_validation_random_iid_nonan.csv")
  train_df$Code
  data$code
  # Filter
  full_data<-data
  data<-data[data$code %in% train_df$Code, ]
}
nrow(validation_df)+nrow(train_df)+nrow(test_df)
df<-data
##grided longitude and latitude of data
data$longitude->x
data$latitude->y

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

write.csv(pontos_vap, "cluster_points.csv")
pontos_vap<-read.csv("cluster_points.csv")
pontos_vap <- na.omit(pontos_vap)
pontos_vap


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
##########VARIOGRAM#############
variogram_model_exp <- autofitVariogram(
  d18O ~ MAP+d13C_foliar,             # Formula for the target variable
  pontos_vap,                   # Spatial data
  model = "Exp"  # List of variogram models to test
)
plot(variogram_model_exp)

variogram_model_sph <- autofitVariogram(
  d18O~MAP +d13C_foliar,             # Formula for the target variable
  pontos_vap,                   # Spatial data
  model = "Sph"  # List of variogram models to test
)
plot(variogram_model_sph)

variogram_model_gau <- autofitVariogram(
  d18O~MAP+d13C_foliar,             # Formula for the target variable
  pontos_vap,                   # Spatial data
  model = "Ste"  # List of variogram models to test
)
plot(variogram_model_gau)

############################################ Write Raster
krige_bounds <- as.matrix(extent(autogrik_d18O_map$krige_output))
x_extent <- krige_bounds["x","max"] - krige_bounds["x","min"]
y_extent <- krige_bounds["y","max"] - krige_bounds["y","min"]
x_extent
(y_extent/x_extent)*1024

# 2. Define your desired resolution
desired_resolution_x <- 0.0025 # Smaller value means higher resolution
desired_resolution_y <- 0.0025

# 3. Create a template raster
# It will automatically use the extent of your points_sv
# and the CRS from points_sv
template_raster <- rast(autogrik_d18O_map$krige_output, resolution = c(desired_resolution_x, desired_resolution_y))
raster_output <- rasterize(terra::vect(autogrik_d18O_map$krige_output[,"var1.pred"]), template_raster, field="var1.pred", fun=mean)

# Check the result
print(raster_output)
plot(raster_output)
plot(points_sv, add=TRUE, col="red", cex=0.5) # Overlay
map_pred_d18O_map<- rasterFromXYZ(autogrik_d18O_map$krige_output[,"var1.pred"], res=c(1024,1))
map_pred_d18O_map_var<- rasterFromXYZ(autogrik_d18O_map$krige_output[,"var1.var"], res=c(1024,1024*(y_extent/x_extent)))
map_pred_d18O_map[c('x','min')]
writeRaster(map_pred_d18O_map, "iso_d18O_wood_map_random_iid_split.tiff", overwrite = T,  format = "GTiff")
writeRaster(map_pred_d18O_map_var, "iso_d18O_wood_map_random_iid_split_var.tiff", overwrite = T,  format = "GTiff")
plot(map_pred_d18O_map,  main = "d18O~MAP+d13C_foliar", xlab='Latitude', ylab="Longitude", xlim=c(-75,-35), col=rainbow(100), alpha = 0.7)
plot(st_geometry(shp_am), add= TRUE)

##############################OOD Evals##########################
test_points <- SpatialPoints(coords=test_df[c('long', 'lat')], proj4string=CRS("+init=epsg:27700 +datum=WGS84"))
test_points
map_pred_d18O_map
test_predictions<-extract(x=map_pred_d18O_map, y=test_points)
test_predictions_var<-extract(x=map_pred_d18O_map_var, y=test_points)
rmse(test_predictions, test_df$d18O_cel_mean)
rmse(test_predictions_var, test_df$d18O_cel_variance)
summary(test_predictions)
autogrik_d18O_map$var_model

##############################CV##########################
#AUTOGRIGE.CV~ MAP + d13C_foliar
#autogrik_d18O_map<-autoKrige.cv(d18O ~ MAP+d13C_foliar,  pontos_vap, new_data=amazon_clim_df10_naless, nfold=10)
cv_map_pet<-autoKrige.cv(d18O ~ MAP+ d13C_foliar, pontos_vap, nfold = 10) 
cv_map_pet
pontos_vap
summary(cv_map_pet)
summary(cv_map_pet$krige.cv_output$residual)
length(cv_map_pet$krige.cv_output$residual)
cv_map_pet$krige.cv_output$residual
hist(cv_map_pet$krige.cv_output$residual, breaks = 5)

#d18O~MAP + d13C_foliar
qqnorm(cv_map_pet$krige.cv_output$residual, pch = 19, cex = 1.4, main = NULL)
qqline(cv_map_pet$krige.cv_output$residual, col = "black", lwd = 2)
plot(cv_map_pet$krige.cv_output$residual~cv_map_pet$krige.cv_output$var1.pred, xlab = "Isoscape-predicted values", ylab = "Residual", pch = 19, cex = 1.5)


###Cross-validation of kriging
cv_map_pet$krige.cv_output
pred<-cv_map_pet$krige.cv_output$var1.pred
observed<-cv_map_pet$krige.cv_output$observed
modelito<-cbind(pred,observed)
write.csv(modelito,"modelito_MAP_vap.csv", row.names = F)
modelito<-read.csv("modelito_MAP_vap.csv", h = T)
nrow(observed)
lm.cv<-lm(observed~pred, modelito)
summary(lm.cv)
library(Metrics)
rmse(observed, pred)

graph_cross_validation_map_pet<-ggplot(modelito, aes(observed, pred)) + 
  geom_point(shape=19, size = 2.5)+  
  geom_smooth(method = "lm", se = T, colour = "black", size = 0.5) +
  geom_abline(intercept = 0, slope = 1, colour = "black", linetype = "dashed") +  
  scale_x_continuous(name = "Observed", breaks = seq(from = -32, to = -26, by = 2))+
  scale_y_continuous(name = "Predicted", breaks = seq(from = -32, to = -26, by = 2))+
  labs(title = "") +
  coord_fixed(ratio = 1, xlim = c(-32,-26), ylim = c(-32,-26), expand = TRUE, clip = "on")+
  theme(axis.line.x = element_line(size = 0.5, colour = "black"),
        axis.line.y = element_line(size = 0.5, colour = "black"),
        axis.line = element_line(size=1, colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill=NA, linetype=1, colour="black"),
        panel.background = element_blank(),
        axis.text.x=element_text(colour="black", size = 12, face="bold"),
        axis.text.y=element_text(colour="black", size = 12, face="bold"),
        axis.title.y =element_text(colour="black", size = 12, face = "bold"),
        axis.title.x =element_text(colour="black", size = 12, face = "bold"),
        legend.title = element_blank(),
        legend.text = element_text(size=9))
graph_cross_validation_map_pet
ggsave("d13C_wood_observed_predicted.jpeg", units="cm", width=24, height=24, dpi=600)
dev.off()

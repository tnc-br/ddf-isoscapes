// This script is used to fetch the water mask from Earth Engine.
// Copy and paste it into Earth Engine code editor.
//
// Load MODIS water_mask (250m) and select the water mask.
var watermask = ee.ImageCollection('MODIS/006/MOD44W')
  .select(['water_mask'])
  .sort('system:time_start', false)
  .first();
print(watermask);

// Load MODIS land cover (500m) and select
// Land Cover Type 1: Annual International
// Geosphere-Biosphere Programme (IGBP) classification
// Key: http://www.eomf.ou.edu/static/IGBP.pdf
// Selected: Forest and Cropland/natural vegetation mosaics
var tree_selector = '(b("LC_Type1") >= 1 && b("LC_Type1") <= 5) || b("LC_Type1") == 14';
var treemask = ee.ImageCollection('MODIS/006/MCD12Q1')
  .select(['LC_Type1'])
  .sort('system:time_start', false)
  .first()
  .expression(tree_selector)
  .rename('tree_mask');

print(treemask);

// Define the visualization parameters.
var vizParamsWater = {
  bands: ['water_mask'],
  min: 0,
  max: 0.5,
  gamma: [1],
  opacity: 0.5
};
var vizParamsTree = {
  bands: ['tree_mask'],
  min: 0,
  max: 0.5,
  gamma: [1],
  opacity: 0.5
};

// Center the map and display the image.
Map.setCenter(-50,-20,4); // Brazil
Map.addLayer(watermask, vizParamsWater, 'grayscale');
Map.addLayer(treemask, vizParamsTree, 'grayscale');

// Reproject based on Martinelli's GeoTiffs
var proj_str = 'EPSG:4326';
var projection = ee.Projection(proj_str);
//var output = watermask.reproject(projection);
var output_projection_info = projection.getInfo();
print(output_projection_info);

// Save to GeoTIFFs
print("Watermask CRS:");
var watermask_crs = watermask.getInfo().bands[0].crs;
print(watermask_crs);

// Note: export_region should specify a projection that matches its input.
// Used with Export.image.toDrive, this should be the projection of the input image.
// Used with image.clip(), this should be the projection of `image`.
var export_region = ee.Geometry.Rectangle([[-73.975139313, -34.808472803], [-33.733472448, 5.266527396]], proj_str);
print("Export area (m^2): ")
print(export_region.area());

watermask = watermask.reproject({crs: proj_str, scale: 250.0});
treemask = treemask.reproject({crs: proj_str, scale: 250.0});

// Export the images
/*
Export.image.toDrive({
  image: watermask,
  description: 'Land_Water_Brazil_MODIS',
  crs: proj_str,
  region: export_region,
  scale: 250, // meters
  maxPixels: 2100712614
});*/

Export.image.toDrive({
  image: treemask,
  description: 'Possible_Trees_Brazil_MODIS',
  crs: proj_str,
  region: export_region,
  scale: 500, // meters
  maxPixels: 2100712614
});

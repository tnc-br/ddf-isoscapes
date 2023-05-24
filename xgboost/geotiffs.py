"""
Helper functions for GeoTIFFs.
"""

from dataclasses import dataclass
import raster
import numpy as np

@dataclass
class Geotiffs:
  """
  Class to pass around GeoTIFFs.
  """

  def __init__(self, load_water_mask: bool = False, load_tree_mask: bool = False, regenerate_plant_nitrogen: bool = False, path: str = ""):
    self.load_water_mask = load_water_mask
    self.load_tree_mask = load_tree_mask
    self.regenerate_plant_nitrogen = regenerate_plant_nitrogen
    self.get_raster_path = lambda filename : f'{path}{filename}'

  def brazil_map_geotiff(self):
    return raster.load_raster(self.get_raster_path("brasil_clim_raster.tiff"))

  def relative_humidity_geotiff(self):
    return raster.load_raster(self.get_raster_path("R.rh_Stack.tif"))

  def temperature_geotiff(self):
    return raster.load_raster(self.get_raster_path("Temperatura_Stack.tif"))

  def vapor_pressure_deficit_geotiff(self):
    return raster.load_raster(self.get_raster_path("R.vpd_Stack.tif"))

  def atmosphere_isoscape_geotiff(self):
    return raster.load_raster(self.get_raster_path("Iso_Oxi_Stack.tif"))

  def cellulose_isoscape_geotiff(self):
    return raster.load_raster(self.get_raster_path("iso_O_cellulose.tif"))

  def soil_plant_nitrogen_difference_isoscape_geotiff(self):
    return raster.load_raster(self.get_raster_path("raster_krig_d15N_soil_plant.tiff"))

  def soil_nitrogen_isoscape_geotiff(self):
    return raster.load_raster(self.get_raster_path("raster_krig_d15N_soil.tiff"))

  def plant_nitrogen_isoscape_geotiff(self):
    return raster.load_raster(self.get_raster_path("plant_nitrogen_isoscape.tiff"))

  def carbon_means_krig_isoscape_geotiff(self):
    return raster.load_raster(self.get_raster_path("Brasil_Raster_Krig_iso_d13C.tiff"))

  def land_water_mask_geotiff(self):
    return raster.load_raster(self.get_raster_path("Land_Water_Brazil_MODIS.tif")) if self.load_water_mask else None

  def possible_tree_mask_geotiff(self):
    return raster.load_raster(self.get_raster_path("Possible_Trees_Brazil_MODIS.tif")) if self.load_tree_mask else None

  def plant_nitrogen_isoscape_geotiff(self):
    if self.regenerate_plant_nitrogen:
      plant_nitrogen_array = self.soil_nitrogen_isoscape_geotiff().yearly_masked_image - self.soil_plant_nitrogen_difference_isoscape_geotiff().yearly_masked_image
      raster.save_numpy_to_geotiff(self.soil_plant_nitrogen_difference_isoscape_geotiff(),
                                   np.expand_dims(np.flip(plant_nitrogen_array.T, axis=1), axis=2),
                                   self.get_raster_path("plant_nitrogen_isoscape.tiff"))
    return raster.load_raster(self.get_raster_path("plant_nitrogen_isoscape.tiff"))
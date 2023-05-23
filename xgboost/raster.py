"""
Package for raster functions.
"""

from dataclasses import dataclass
import math
import matplotlib.animation as animation
import matplotlib.pyplot as plt
import numpy as np
from osgeo import gdal, gdal_array
from typing import List


@dataclass
class AmazonGeoTiff:
  """Represents a geotiff from our dataset."""
  gdal_dataset: gdal.Dataset
  image_value_array: np.ndarray # ndarray of floats
  image_mask_array: np.ndarray # ndarray of uint8
  masked_image: np.ma.masked_array
  yearly_masked_image: np.ma.masked_array


@dataclass
class Bounds:
  """Represents geographic bounds and size information."""
  minx: float
  maxx: float
  miny: float
  maxy: float
  pixel_size_x: float
  pixel_size_y: float
  raster_size_x: float
  raster_size_y: float

  def to_matplotlib(self) -> List[float]:
    return [self.minx, self.maxx, self.miny, self.maxy]


def print_raster_info(raster):
  dataset = raster
  print("Driver: {}/{}".format(dataset.GetDriver().ShortName,
                               dataset.GetDriver().LongName))
  print("Size is {} x {} x {}".format(dataset.RasterXSize,
                                      dataset.RasterYSize,
                                      dataset.RasterCount))
  print("Projection is {}".format(dataset.GetProjection()))
  geotransform = dataset.GetGeoTransform()
  if geotransform:
    print("Origin = ({}, {})".format(geotransform[0], geotransform[3]))
    print("Pixel Size = ({}, {})".format(geotransform[1], geotransform[5]))

  for band in range(dataset.RasterCount):
    band = dataset.GetRasterBand(band+1)
    #print("Band Type={}".format(gdal.GetDataTypeName(band.DataType)))

    min = band.GetMinimum()
    max = band.GetMaximum()
    if not min or not max:
      (min,max) = band.ComputeRasterMinMax(False)
    #print("Min={:.3f}, Max={:.3f}".format(min,max))

    if band.GetOverviewCount() > 0:
      print("Band has {} overviews".format(band.GetOverviewCount()))

    if band.GetRasterColorTable():
      print("Band has a color table with {} entries".format(band.GetRasterColorTable().GetCount()))


def load_raster(path: str, use_only_band_index: int = -1) -> AmazonGeoTiff:
  """
  TODO: Refactor (is_single_band, etc., should be a better design)
  --> Find a way to simplify this logic. Maybe it needs to be more abstract.
  """
  dataset = gdal.Open(path, gdal.GA_ReadOnly)
  try:
    print_raster_info(dataset)
  except AttributeError as e:
    raise OSError("Failed to print raster. This likely means it did not load properly from "+ path)
  image_datatype = dataset.GetRasterBand(1).DataType
  mask_datatype = dataset.GetRasterBand(1).GetMaskBand().DataType
  image = np.zeros((dataset.RasterYSize, dataset.RasterXSize, 12),
                   dtype=gdal_array.GDALTypeCodeToNumericTypeCode(image_datatype))
  mask = np.zeros((dataset.RasterYSize, dataset.RasterXSize, 12),
                  dtype=gdal_array.GDALTypeCodeToNumericTypeCode(image_datatype))

  if use_only_band_index == -1:
    if dataset.RasterCount != 12 and dataset.RasterCount != 1:
      raise ValueError(f"Expected 12 raster bands (one for each month) or one annual average, but found {dataset.RasterCount}")
    if dataset.RasterCount == 1:
      use_only_band_index = 0

  is_single_band = use_only_band_index != -1

  if is_single_band and use_only_band_index >= dataset.RasterCount:
    raise IndexError(f"Specified raster band index {use_only_band_index}"
                     f" but there are only {dataset.RasterCount} rasters")

  for band_index in range(12):
    band = dataset.GetRasterBand(use_only_band_index+1 if is_single_band else band_index+1)
    image[:, :, band_index] = band.ReadAsArray()
    mask[:, :, band_index] = band.GetMaskBand().ReadAsArray()
  masked_image = np.ma.masked_where(mask == 0, image)
  yearly_masked_image = masked_image.mean(axis=2)

  return AmazonGeoTiff(dataset, image, mask, masked_image, yearly_masked_image)

def get_extent(dataset):
  geoTransform = dataset.GetGeoTransform()
  minx = geoTransform[0]
  maxy = geoTransform[3]
  maxx = minx + geoTransform[1] * dataset.RasterXSize
  miny = maxy + geoTransform[5] * dataset.RasterYSize
  return Bounds(minx, maxx, miny, maxy, geoTransform[1], geoTransform[5], dataset.RasterXSize, dataset.RasterYSize)

def plot_band(geotiff: AmazonGeoTiff, month_index, figsize=None):
  if figsize:
    plt.figure(figsize=figsize)
  im = plt.imshow(geotiff.masked_image[:,:,month_index], extent=get_extent(geotiff.gdal_dataset).to_matplotlib(), interpolation='none')
  plt.colorbar(im)

def animate(geotiff: AmazonGeoTiff, nSeconds, fps):
  fig = plt.figure( figsize=(8,8) )

  months = []
  labels = []
  for m in range(12):
    months.append(geotiff.masked_image[:,:,m])
    labels.append(f"Month: {m+1}")
  a = months[0]
  extent = get_extent(geotiff.gdal_dataset).to_matplotlib()
  ax = fig.add_subplot()
  im = fig.axes[0].imshow(a, interpolation='none', aspect='auto', extent = extent)
  txt = fig.text(0.3,0,"", fontsize=24)
  fig.colorbar(im)

  def animate_func(i):
    if i % fps == 0:
      print( '.', end ='' )

    im.set_array(months[i])
    txt.set_text(labels[i])
    return [im, txt]

  anim = animation.FuncAnimation(
      fig,
      animate_func,
      frames = nSeconds * fps,
      interval = 1000 / fps, # in ms
  )
  plt.close()

  return anim

def save_numpy_to_geotiff(bounds: Bounds, prediction: np.ma.MaskedArray, path: str):
  """Copy metadata from a base geotiff and write raster data + mask from `data`"""
  driver = gdal.GetDriverByName("GTiff")
  metadata = driver.GetMetadata()
  if metadata.get(gdal.DCAP_CREATE) != "YES":
    raise RuntimeError("GTiff driver does not support required method Create().")
  if metadata.get(gdal.DCAP_CREATECOPY) != "YES":
    raise RuntimeError("GTiff driver does not support required method CreateCopy().")

  dataset = driver.Create(path, bounds.raster_size_x, bounds.raster_size_y, prediction.shape[2], eType=gdal.GDT_Float64)
  dataset.SetGeoTransform([bounds.minx, bounds.pixel_size_x, 0, bounds.maxy, 0, bounds.pixel_size_y])
  dataset.SetProjection('GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433],AUTHORITY["EPSG","4326"]]')

  #dataset = driver.CreateCopy(path, base.gdal_dataset, strict=0)
  if len(prediction.shape) != 3 or prediction.shape[0] != bounds.raster_size_x or prediction.shape[1] != bounds.raster_size_y:
    raise ValueError("Shape of prediction does not match base geotiff")
  #if prediction.shape[2] > base.gdal_dataset.RasterCount:
  #  raise ValueError(f"Expected fewer than {dataset.RasterCount} bands in prediction but found {prediction.shape[2]}")

  prediction_transformed = np.flip(np.transpose(prediction, axes=[1,0,2]), axis=0)
  for band_index in range(dataset.RasterCount):
    band = dataset.GetRasterBand(band_index+1)
    if band.CreateMaskBand(0) == gdal.CE_Failure:
      raise RuntimeError("Failed to create mask band")
    mask_band = band.GetMaskBand()
    band.WriteArray(np.choose(prediction_transformed[:, :, band_index].mask, (prediction_transformed[:, :, band_index].data,np.array(band.GetNoDataValue()),)))
    mask_band.WriteArray(np.logical_not(prediction_transformed[:, :, band_index].mask))

def coords_to_indices(bounds: Bounds, x: float, y: float):
  if x < bounds.minx or x > bounds.maxx or y < bounds.miny or y > bounds.maxy:
    raise ValueError("Coordinates out of bounds")

  # X => lat, Y => lon
  x_idx = bounds.raster_size_y - int(math.ceil((y - bounds.miny) / abs(bounds.pixel_size_y)))
  y_idx = int((x - bounds.minx) / abs(bounds.pixel_size_x))

  return x_idx, y_idx


def get_data_at_coords(dataset: AmazonGeoTiff, x: float, y: float, month: int) -> float:
  # x = longitude
  # y = latitude
  bounds = get_extent(dataset.gdal_dataset)
  x_idx, y_idx = coords_to_indices(bounds, x, y)
  if month == -1:
    value = dataset.yearly_masked_image[x_idx, y_idx]
  else:
    value = dataset.masked_image[x_idx, y_idx, month]
  if np.ma.is_masked(value):
    raise ValueError("Coordinates are masked")
  else:
    return value
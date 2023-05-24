"""
Tests for raster.py.
"""

import unittest
import raster


class TestRaster(unittest.TestCase):
  def test_coords_to_indices(self):
    bounds = raster.Bounds(50, 100, 50, 100, 1, 1, 50, 50)
    x, y = raster.coords_to_indices(bounds, 55, 55)
    assert x == 45
    assert y == 5

    bounds = raster.Bounds(-100, -50, -100, -50, 1, 1, 50, 50)
    x, y = raster.coords_to_indices(bounds, -55, -55)
    assert x == 5
    assert y == 45

    bounds = raster.Bounds(-10, 50, -10, 50, 1, 1, 60, 60)
    x, y = raster.coords_to_indices(bounds, -1, 13)
    assert x == 37
    assert y == 9

    bounds = raster.Bounds(minx=-73.97513931345594, maxx=-34.808472803053895, miny=-33.73347244751509, maxy=5.266527396029211, pixel_size_x=0.04166666650042771, pixel_size_y=-0.041666666499513144, raster_size_x=937, raster_size_y=941)
    x, y = raster.coords_to_indices(bounds, -67.14342073173958, -7.273271869467912e-05)
    assert x == 131 # was: 132
    assert y == 163
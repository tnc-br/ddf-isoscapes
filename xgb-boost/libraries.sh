#from osgeo import gdal, gdal_array
sudo apt-get update
sudo apt-get install gdal-bin
sudo apt-get install libgdal-dev
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal
pip install GDAL==$(gdal-config --version) --global-option=build_ext --global- option="-I/usr/include/gdal"

#import pandas as pd
pip install pandas

#from tqdm import tqdm
pip install tqdm

#import xgboost as xgb
pip install xgboost
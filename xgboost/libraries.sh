sudo apt-get update

sudo apt-get install gdal-bin
sudo apt-get install libgdal-dev
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal
pip install --break-system-packages GDAL==$(gdal-config --version) --global-option=build_ext --global- option="-I/usr/include/gdal"

# Used to install packages directly into virtual environments.
sudo apt-get install pipx

# xgboost dependency that isn't picked up by xgboost
# This might no longer be necessary now that we're using pipx --install-dependencies,
# but leaving this here until we can verify.
# Tracked in: https://github.com/tnc-br/ddf-isoscapes/issues/73
sudo apt install python3-sklearn
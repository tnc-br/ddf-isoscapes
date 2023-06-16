sudo apt-get update


# xgboost dependency that isn't picked up by xgboost
# This might no longer be necessary now that we're using pipx --install-dependencies,
# but leaving this here until we can verify.
# Tracked in: https://github.com/tnc-br/ddf-isoscapes/issues/73
sudo apt install python3-sklearn

# Used to install packages directly into virtual environments
sudo apt-get install pipx

# Used to install GDAL
sudo apt-get install gdal-bin
sudo apt-get install libgdal-dev
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal

# Virtual environment used to run local runtime
python3 -m venv pyEnv
source pyEnv/bin/activate
python -m pip install -r requirements.txt

python -m pip install GDAL==$(gdal-config --version) --global-option=build_ext

python -m jupyter notebook --NotebookApp.allow_origin='https://colab.research.google.com' --port=8888 --NotebookApp.port_retries=0

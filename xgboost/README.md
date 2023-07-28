# XGBoost

This package contains a Colab notebook that uses XGBoost plus a Gaussian kernel
to infer isoscapes.

For details on XGBoost,
see: https://xgboost.readthedocs.io/en/stable/tutorials/model.html

# Running `main.ipynb` Notebook

See `ddf-isoscapes/README.md` for details on using different runtimes.

Point `raster.RASTER_BASE`, `raster.SAMPLE_DATA_BASE`, `raster.TEST_DATA_BASE`,
`raster.ANIMATIONS_BASE`, `raster.MODEL_BASE` to data. You'll have to download the
data to local disk if running with a local runtime as reading from GDrive is not
supported on local runtimes.

If you run into any issues,
please [file a new issue](https://github.com/tnc-br/ddf-isoscapes/issues/new). 
If possible, copy the failing cell, the error output, which data is being used,
and point to the affected commit.

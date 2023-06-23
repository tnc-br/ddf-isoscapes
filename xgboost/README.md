# XGBoost

This package contains a Colab notebook that uses XGBoost plus a Gaussian kernel
to infer isoscapes.

For details on XGBoost,
see: https://xgboost.readthedocs.io/en/stable/tutorials/model.html

# Running `main.ipynb` Notebook

See `ddf-isoscapes/README.md` for details on using different runtimes.

Running `chmod +x setup.sh && ./setup.sh` should start a Jupyter server that can be used as a local runtime.

1. Run `libraries.sh`. Note you'll be asked for a `sudo` password.
2. Point `RASTER_BASE`, `SAMPLE_DATA_BASE`, `TEST_DATA_BASE`, `ANIMATIONS_BASE`,
   `MODEL_BASE` to data. You'll have to download the data to local disk as
   reading
   from GDrive is not currently supported.
3. Set `GDRIVE_BASE` to `None`.

If you run into any issues,
please [file a new issue](https://github.com/tnc-br/ddf-isoscapes/issues/new)
and assign to [jmogarrio](https://github.com/jmogarrio). If possible, copy the
failing cell, the error output, which data is being used, and point to the
affected commit.

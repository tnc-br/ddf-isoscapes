# ddf-isoscapes

This repo contains different Colab Notebooks used to generate isoscape models.

# GitHub pre-reqs for Googlers

The steps are detailed
at [go/github](https://opensource.corp.google.com/github/), what follows is a
summary:

1. Register GitHub account
   at [go/github](https://opensource.corp.google.com/github/).
    1. Register your GitHub username above.
    2. [Add your google.com email address to your GitHub account.](https://help.github.com/articles/adding-an-email-address-to-your-github-account/)
    3. Set `git` to use your corp email
       address: `git config --global user.email "email@example.com"`
    4. Enable 2FA in your GitHub
       account: [go/github-docs/2fa](https://goto.google.com/github-docs/2fa)
2. Add your GitHub username
   to [go/tnc-tracker](https://docs.google.com/spreadsheets/d/1TtjoT3b_iRmRWzap5MC-hLt7V9m2R4fzSfovLJLQOTQ/edit#gid=0).
3. Get invited to https://github.com/tnc-br/ddf-isoscapes.

# Known Issues

Please consult this document for known issues. Feel free to report one by adding
a new row.

http://go/ddf-github-known-issues

# Running the Colabs

## Using GitHub

1. connect to your external Colab. https://colab.research.google.com/

> **NOTE**: Googlers might be redirected to the internal Colab, so check that
> the URL matches the one above. Otherwise, there should be a toggle near the top
> that reads `Switch to prod`.

2. From the window choose GitHub tab and select "Include private repos".

3. Enter your GitHub username.

4. `main.ipynb` should show up, if it does not, refresh the tab or open a new
   one, make sure that you are connected to your account.

5. open it, and follow next steps.

## Using GDrive

1. After [connecting to colab](#using-github),
   click `Connect > Connect to a hosted runtime` (you may also just
   click `Connect`).

2. Replace the parameters in
   the [Imports](https://colab.research.google.com/github/kazob1998/DDF-ML-Model/blob/main/main.ipynb#scrollTo=K0tG92Yw1CYk&line=8&uniqifier=1)
   with the location of the Amazon data files. (By default, the parameters point
   to the top level of `MyDrive`, assuming external folks don’t have access to
   our internal shared drive. Replace the prefix of these params
   with `"/content/drive/Shareddrives/TNC Fellowship 🌳/4. Isotope Research & Signals/code/amazon_rainforest_files"`
   to point to the shared drive we own. For example, `RASTER_BASE = "
   /content/drive/Shareddrives/TNC Fellowship 🌳/4. Isotope Research &
   Signals/code/amazon_rainforest_files/amazon_rasters"`)

3. Run as normal. When you
   reach [this part of the code](https://colab.research.google.com/github/kazob1998/DDF-ML-Model/blob/main/main.ipynb#scrollTo=RQC9hqqUWso9&line=3&uniqifier=1),
   grant it permission to access GDrive.

## Using Local Runtime

Steps 1-4 only need to be run once.

1. connect to your local machine (cloudtop, gLinux ...)
   [`git clone`](https://git-scm.com/docs/git-clone) a new branch of this project into a local folder

2. Install Jupyter and pip
    * gLinux: Run `sudo apt install jupyter` and `sudo apt install pip`.

3. Install and enable the `jupyter_http_over_ws jupyter` extension.
   The `jupyter_http_over_ws` extension is authored by the Colab team and
   available on GitHub.
   Note that you may need `--break-system-packages` to install jupyter on system
   level packages.

```
pip install jupyter_http_over_ws --break-system-packages
jupyter serverextension enable --py jupyter_http_over_ws
```

4. (Optional) Install `virtualenv` to create a virtual python env that
   allows `pip install` to run within the Notebook.

```
sudo apt install python3.11-venv
python3 -m venv ~/py --system-site-packages
source ~/py/bin/activate
python -m ipykernel install --user --name=py
```

You may also optionally run `jupyter notebook --generate-config` and set the
line `c.MutiKernelManager.default_kernel_name='py'`. This will automatically
choose the py virtual environment as the default kernel in jupyter.

5. (For `./xgboost` only) Run the script `libraries.sh` to install necessary
   libraries:
    1. `cd` to the directory where you cloned the git repo.
    2. run `chmod +x ./libraries.sh`
    3. execute `./libraries.sh`

6. Start server and authenticate:
   New notebook servers are started normally, though you will need to set a flag
   to explicitly trust WebSocket connections from the Colaboratory frontend.

```
jupyter notebook \
  --NotebookApp.allow_origin='https://colab.research.google.com' \
  --port=8888 \
  --NotebookApp.port_retries=0
```

Once the server has started, it will print a message with the initial backend
URL used for authentication. Make a copy of this URL as you'll need to provide
this in the next step.

7.Connect to the local runtime. In Colab, click the `Connect` button and
select `Connect to local runtime...`. Enter the URL from the previous step in
the dialog that appears and click the `Connect` button. After this, you should
now be connected to your local runtime.

# Editing

One option is to use VSCode, which has Jupyter support. Googlers
see [go/vscode/install](https://go/vscode/install).

Intellij also has Jupyter support.

Remember
to [exclude working directories from backups](https://support.google.com/techstop/answer/3288893).

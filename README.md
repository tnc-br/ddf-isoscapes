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

1. Connect to your external Colab. https://colab.research.google.com/

> **NOTE**: Googlers might be redirected to the internal Colab, so check that
> the URL matches the one above. Otherwise, there should be a toggle near the
> top
> that reads `Switch to prod`.

2. From the window choose GitHub tab and select `Include private repos`.

3. Enter your GitHub username.

4. `main.ipynb` should show up; if it does not, refresh the tab or open a new
   one, making sure that you are connected to your account. Open it, and follow
   next steps.

## Using local runtimes, scripted setup


This assumes `python3` is installed.


1. `git clone` to a local folder.

2. Run `chmod +x setup.sh`.

3. Run `./setup.sh`.

4. Copy the provided URL and proceed with the next sections.

## Using local runtimes, manual setup

Steps 1-4 only need to be run once.

1. Connect to your local machine (cloudtop, gLinux ...)
   [`git clone`](https://git-scm.com/docs/git-clone) a new branch of this
   project into a local folder

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

## Using GDrive in hosted runtimes

GDrive is currently not supported in local runtimes, but can be used in hosted
runtimes.

1. After [connecting to colab](#using-github),
   click `Connect > Connect to a hosted runtime` (you may also just
   click `Connect`).

2. In the **Parent Directories** cell, set `USE_GDRIVE = True`. If using your
   own GDrive, set `USE_SHARED_GDRIVE = False` and
   set `PERSONAL_GDRIVE_PARENT_DIR` to the name of the folder containing all the
   data. Otherwise, set `USE_SHARED_GDRIVE = True` and
   set `SHARED_GDRIVE_PARENT_DIR` to the folder in the shared drive containing
   all the data, prefixed by the shared drive name.

3. Run as normal. When you reach the **Mount GDrive** cell, grant Colab
   permission to access GDrive.

# Editing

One option is to use VSCode, which has Jupyter support. Googlers
see [go/vscode/install](https://go/vscode/install).

Intellij also has Jupyter support.

Remember
to [exclude working directories from backups](https://support.google.com/techstop/answer/3288893).

# Viewing diffs on GitHub

Consider [enabling Rich Jupyter Notebook Diffs](https://github.blog/changelog/2023-03-01-feature-preview-rich-jupyter-notebook-diffs/)
via [Feature Previews](https://docs.github.com/en/get-started/using-github/exploring-early-access-releases-with-feature-preview#exploring-beta-releases-with-feature-preview)
to make Notebook diffs easy to read.
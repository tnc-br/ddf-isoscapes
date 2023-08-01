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

## Using local runtimes


Please use the official docker container for running a local runtime.
See [`the official colab instructions`](https://research.google.com/colaboratory/local-runtimes.html) for more details.

Once the server has started, it will print a message with the initial backend
URL used for authentication. Make a copy of this URL as you'll need to provide
this in the next step.

In Colab, click the `Connect` button and
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

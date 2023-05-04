# DDF-ML-Model

# GitHub pre-reqs for Googlers

The steps are detailed at [go/github](https://opensource.corp.google.com/github/), what follows is a summary:

1. Register GitHub account at [go/github](https://opensource.corp.google.com/github/).
    1. Register your GitHub username above.
    2. [Add your google.com email address to your GitHub account.](https://help.github.com/articles/adding-an-email-address-to-your-github-account/)
    3. Set `git` to use your corp email address: `git config --global user.email "email@example.com"`
    4. Enable 2FA in your GitHub account: [go/github-docs/2fa](https://goto.google.com/github-docs/2fa)
2. Add GitHub username in [go/tnc-tracker](https://docs.google.com/spreadsheets/d/1TtjoT3b_iRmRWzap5MC-hLt7V9m2R4fzSfovLJLQOTQ/edit#gid=0).
3. Get invited to https://github.com/kazob1998/DDF-ML-Model.


# Steps to execute:

# Known Issues:
Please consult this document for known issues. Feel free to report one by adding a new row.

http://go/ddf-github-known-issues

## Github
1. connect to your external colab. https://colab.research.google.com/
> **NOTE**: Googlers might be redirected to the internal Colab, so check that the URL matches the one above. Otherwise, there should be a toggle near the top that reads `Switch to prod`.

2. from the window choose Github tab and select "Include private repos".

3. Enter your GitHub username.

4. main.ipynb should show up, if it does not, refresh the tab or open a new one, make sure that you are connected to your account.

5. open it, and follow next steps.

## Local Runtime
1. connect to your local  machine (cloudtop, gLinux ...)

2. Install Jupyter and pip
   * gLinux: Run `sudo apt install jupyter` and `sudo apt install pip`.

3. Install and enable the `jupyter_http_over_ws jupyter` extension (one-time)
The `jupyter_http_over_ws` extension is authored by the Colaboratory team and available on GitHub.

```
pip install jupyter_http_over_ws
jupyter serverextension enable --py jupyter_http_over_ws
```

4. run the script libraries.sh to install the missing libraries:
   1. upload the script from https://github.com/kazob1998/DDF-ML-Model/blob/main/libraries.sh
   2. run `chmod +x ./libraries.sh`
   3. execute `./libraries.sh`

5. Start server and authenticate: 
New notebook servers are started normally, though you will need to set a flag to explicitly trust WebSocket connections from the Colaboratory frontend.

```
jupyter notebook \
  --NotebookApp.allow_origin='https://colab.research.google.com' \
  --port=8888 \
  --NotebookApp.port_retries=0
```
    
Once the server has started, it will print a message with the initial backend URL used for authentication. Make a copy of this URL as you'll need to provide this in the next step.

6. Connect to the local runtime
In Colaboratory, click the "Connect" button and select "Connect to local runtime...". Enter the URL from the previous step in the dialog that appears and click the "Connect" button. After this, you should now be connected to your local runtime.


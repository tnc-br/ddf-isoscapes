# DDF-ML-Model


# Intro:



# Steps to execute:

## Github
1- connect to your external colab. https://colab.research.google.com/

2- from the window choose Github tab and select "Include private repos".

3- Enter your GitHub username.

4- main.ipynb should show up, open it.

## Local Runtime
1- connect to your local  machine (cloudtop, gLinux ...)

2 - Install Jupyter : 
Install Jupyter on your local machine.

3- Install and enable the jupyter_http_over_ws jupyter extension (one-time)
The jupyter_http_over_ws extension is authored by the Colaboratory team and available on GitHub.

pip install jupyter_http_over_ws
jupyter serverextension enable --py jupyter_http_over_ws

4- run the script libraries.sh to install the missing libraries:
upload the script from "https://github.com/kazob1998/DDF-ML-Model/blob/main/libraries.sh"
run "chmod +x ./libraries.sh"
execute "./libraries.sh"

5- Start server and authenticate: 
New notebook servers are started normally, though you will need to set a flag to explicitly trust WebSocket connections from the Colaboratory frontend.

jupyter notebook \
  --NotebookApp.allow_origin='https://colab.research.google.com' \
  --port=8888 \
  --NotebookApp.port_retries=0
    
Once the server has started, it will print a message with the initial backend URL used for authentication. Make a copy of this URL as you'll need to provide this in the next step.

6- Connect to the local runtime
In Colaboratory, click the "Connect" button and select "Connect to local runtime...". Enter the URL from the previous step in the dialog that appears and click the "Connect" button. After this, you should now be connected to your local runtime.

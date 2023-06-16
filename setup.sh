python3 -m venv pyEnv
source pyEnv/bin/activate
python -m pip install -r requirements.txt
python -m jupyter serverextension enable --py jupyter_http_over_ws
python -m jupyter notebook --NotebookApp.allow_origin='https://colab.research.google.com' --port=8888 --NotebookApp.port_retries=0 --no-browser

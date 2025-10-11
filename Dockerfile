1)FROM python:3.10-slim-bookworm

4) WORKDIR /app

# Install only dependencies first (better caching, smaller layers)
COPY requirements.txt .
3) RUN pip install --no-cache-dir -r requirements.txt

# Then copy source code
COPY . .

EXPOSE 8501
ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
#FROM python:3.10-slim-buster
#EXPOSE 8501

#RUN apt-get update && apt-get install -y \
#   build-essential \
#  software-properties-common \
# git \
#&& rm -rf /var/lib/apt/lists/*

#WORKDIR /app

#COPY . /app

2)#RUN pip3 install -r requirements.txt

#ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]

FROM python:3.8-slim
RUN apt-get update -q \
  && apt-get install --no-install-recommends -qy \
  gcc \ 
  inetutils-ping \
  && rm -rf /var/lib/apt/lists/*
ADD . /app
WORKDIR /app
RUN pip install -r /app/requirements.txt

CMD cd /app && python run.py

EXPOSE 5000
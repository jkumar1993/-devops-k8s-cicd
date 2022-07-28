FROM ubuntu:bionic
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install \
    python3 python3-pip python3-wheel \
    mysql-client libsqlclient-dev libssl-dev default-libmysqlclient-dev
RUN apt-get install python3-pip
RUN pip3 --version

ADD . /app
WORKDIR /app
RUN pip3 install -r requirements.txt
EXPOSE 8000
ENTRYPOINT [ "python3", "manage.py", "runserver" "0.0.0.0:8000" ]


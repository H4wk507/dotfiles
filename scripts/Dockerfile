FROM ubuntu:24.04

RUN apt update && apt install -y \
    git \
    curl \
    wget \
    vim \
    sudo

WORKDIR /usr/local/bin
ARG DEBIAN_FRONTEND=noninteractive
COPY . .

CMD ["sh", "-c", "./setup.sh"]

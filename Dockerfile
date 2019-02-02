FROM debian:9

RUN apt update && apt install -y build-essential autoconf automake libtool liblzma-dev zlib1g-dev ccache libglib2.0-dev git gawk unzip libncurses5-dev u-boot-tools && rm -rf /var/lib/apt/lists/*

COPY . /fw-tool

RUN cd /fw-tool && make && make install

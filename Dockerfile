FROM ubuntu:20.04

RUN apt-get upgrade && apt-get update
ENV DEBIAN_FRONTEND=noninteractive

# Install base packages
RUN apt-get -y --no-install-recommends install \
    wget \
    git \
    pkg-config \
    cmake \
    automake \
    ca-certificates \
    openssl \
    libssl-dev \
    libcurl4 \
    libcurl4-openssl-dev \
    liblog4cplus-1.1-9 \
    nginx \
    libnginx-mod-rtmp \
    golang

# Install gstreamer
RUN apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav libgstreamer1.0-0 gstreamer1.0-doc \
    gstreamer1.0-tools

WORKDIR /opt/

# Build kvssink
RUN git clone --recursive --single-branch --branch debug-v5 https://github.com/mwildehahn/amazon-kinesis-video-streams-producer-sdk-cpp.git aws-kvs-sdk
RUN mkdir -p aws-kvs-sdk/build; cd aws-kvs-sdk/build; cmake .. -DBUILD_GSTREAMER_PLUGIN=ON; make

ENV LD_LIBRARY_PATH=/opt/aws-kvs-sdk/open-source/local/lib:$LD_LIBRARY_PATH
ENV PATH=/opt/aws-kvs-sdk/open-source/local/bin:/opt/bin:$PATH
ENV GST_PLUGIN_PATH=/opt/aws-kvs-sdk/build:$GST_PLUGIN_PATH
ENV GOPATH=/opt/go

# Forward logs to Docker
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 1935

RUN mkdir /opt/config
RUN mkdir /opt/bin
RUN mkdir -p /opt/go/src/github.com/mwildehahn/nginx-rtmp-kinesis

RUN apt-get install -y gdb

COPY health-check.go /opt/go/src/github.com/mwildehahn/nginx-rtmp-kinesis
WORKDIR /opt/go/src/github.com/mwildehahn/nginx-rtmp-kinesis
RUN go build -o /opt/bin/health-check health-check.go
WORKDIR /opt

COPY nginx.conf /etc/nginx/nginx.conf
COPY docker-entrypoint.sh /opt/bin
COPY kvs-log-config /opt/config
COPY kvs-producer.template /opt/bin
COPY docker-cmd.sh /opt/bin

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["docker-cmd.sh"]

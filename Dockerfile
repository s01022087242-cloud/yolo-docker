FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone https://github.com/pjreddie/darknet

WORKDIR /app/darknet
RUN make

RUN wget https://data.pjreddie.com/files/yolov3.weights

RUN echo '#!/bin/bash' > /app/darknet/run_yolo.sh && \
    echo 'echo "Downloading image from $1..."' >> /app/darknet/run_yolo.sh && \
    echo 'wget -O input.jpg "$1"' >> /app/darknet/run_yolo.sh && \
    echo 'echo "Running YOLO detection..."' >> /app/darknet/run_yolo.sh && \
    echo './darknet detector test cfg/coco.data cfg/yolov3.cfg yolov3.weights input.jpg' >> /app/darknet/run_yolo.sh

RUN chmod +x /app/darknet/run_yolo.sh

ENTRYPOINT ["./run_yolo.sh"]
# 1. 기본 이미지 설정 (Ubuntu 20.04)
FROM ubuntu:20.04

# 2. 패키지 설치 및 환경 설정
# build-essential을 설치하여 gcc, make, libc-dev 등 필수 도구를 모두 확보합니다.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 3. Darknet 소스 코드 클론
WORKDIR /app
RUN git clone https://github.com/pjreddie/darknet

# 4. Darknet 컴파일
WORKDIR /app/darknet
RUN make

# 5. YOLOv3 가중치 파일 다운로드
RUN wget https://data.pjreddie.com/files/yolov3.weights

# 6. 실행 스크립트 생성
RUN echo '#!/bin/bash' > /app/darknet/run_yolo.sh && \
    echo 'echo "Downloading image from $1..."' >> /app/darknet/run_yolo.sh && \
    echo 'wget -O input.jpg "$1"' >> /app/darknet/run_yolo.sh && \
    echo 'echo "Running YOLO detection..."' >> /app/darknet/run_yolo.sh && \
    echo './darknet detector test cfg/coco.data cfg/yolov3.cfg yolov3.weights input.jpg' >> /app/darknet/run_yolo.sh

# 7. 스크립트 실행 권한 부여
RUN chmod +x /app/darknet/run_yolo.sh

# 8. 컨테이너 실행 시 기본 명령어 설정
ENTRYPOINT ["./run_yolo.sh"]
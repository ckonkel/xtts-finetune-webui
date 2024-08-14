# Use an official NVIDIA CUDA runtime image as a parent image
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu20.04

# Set the working directory in the container
WORKDIR /app

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install necessary system packages and Python 3.9
RUN apt-get update && apt-get install -y \
    tzdata \
    git \
    curl \
    net-tools \
    python3.9 \
    python3.9-venv \
    python3.9-dev \
    python3-pip \
    libncurses5-dev \
    libncursesw5-dev \
    libudev-dev \
    libsystemd-dev \
    libdrm-dev \
    build-essential \
    pkg-config \
    && apt-get remove -y cmake \
    && curl -L https://github.com/Kitware/CMake/releases/download/v3.26.4/cmake-3.26.4-linux-x86_64.sh -o cmake.sh \
    && chmod +x cmake.sh \
    && ./cmake.sh --skip-license --prefix=/usr/local \
    && rm cmake.sh

# Set Python 3.9 as the default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

# Clone the nvtop repository and build it
RUN git clone https://github.com/Syllo/nvtop.git /app/nvtop && \
    mkdir -p /app/nvtop/build && \
    cd /app/nvtop/build && \
    cmake .. && \
    make && \
    make install

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the current directory contents into the container at /app
COPY . /app

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install Python dependencies individually
RUN python3 -m pip install faster_whisper==1.0.2
RUN python3 -m pip install gradio==4.13.0
RUN python3 -m pip install spacy==3.7.4
RUN python3 -m pip install coqui-tts[languages]==0.24.1
RUN python3 -m pip install cutlet
RUN python3 -m pip install fugashi[unidic-lite]

# Install specific versions of torch and torchaudio
RUN python3 -m pip install torch==2.1.1+cu118 torchaudio==2.1.1+cu118 --index-url https://download.pytorch.org/whl/cu118

# Define environment variable
ENV CUDA_VISIBLE_DEVICES=0

# Run the webui when the container launches
CMD ["python3", "xtts_demo.py"]

# Use an official Python runtime as a parent image
FROM python:3.10

# Set the working directory in the container
WORKDIR /app

# Install necessary system packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    net-tools\
    cmake \
    libncurses5-dev \
    libncursesw5-dev \
    libudev-dev \
    libsystemd-dev \
    libdrm-dev \
    build-essential \
    pkg-config

# Clone the nvtop repository and build it
RUN git clone https://github.com/Syllo/nvtop.git /app/nvtop && \
    mkdir -p /app/nvtop/build && \
    cd /app/nvtop/build && \
    cmake .. && \
    make && \
    make install

WORKDIR /app

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the current directory contents into the container at /app
COPY . /app

# Upgrade pip
RUN python -m pip install --upgrade pip

# Install requirements
# RUN pip install -r requirements.txt

# Install each dependency individually
RUN pip install faster_whisper==1.0.2
RUN pip install gradio==4.13.0
RUN pip install spacy==3.7.4
RUN pip install coqui-tts[languages]==0.24.1
RUN pip install cutlet
RUN pip install fugashi[unidic-lite]

# Install specific versions of torch and torchaudio
RUN pip install torch==2.1.1+cu118 torchaudio==2.1.1+cu118 --index-url https://download.pytorch.org/whl/cu118

# Define environment variable
ENV CUDA_VISIBLE_DEVICES=0

# Run the webui when the container launches
CMD ["python", "xtts_demo.py"]

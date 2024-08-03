# Use an official Python runtime as a parent image
FROM python:3.10

# Set the working directory in the container
WORKDIR /app

# Install necessary system packages
RUN apt-get update && apt-get install -y git

# Copy the current directory contents into the container at /app
COPY . /app

# Install other dependencies from requirements.txt
RUN pip install -r requirements.txt
RUN pip install torch==2.1.1+cu118 torchaudio==2.1.1+cu118 --index-url https://download.pytorch.org/whl/cu118

# Make port 8010 available to the world outside this container
EXPOSE 8010

# Define environment variable
ENV CUDA_VISIBLE_DEVICES=0

# Run the webui when the container launches
CMD ["python", "xtts_webui.py", "--host", "0.0.0.0", "--port", "8010"]

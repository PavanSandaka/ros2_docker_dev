# Base image
FROM ubuntu:22.04

# Metadata
LABEL maintainer="pavansandaka11@gmail.com"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    ROS_DISTRO=humble \
    COLCON_DEFAULTS_FILE=/root/ros2_ws/colcon.defaults.yaml

# Update and install base packages
RUN apt update && apt install -y --no-install-recommends \
    curl \
    wget \
    gnupg2 \
    lsb-release \
    build-essential \
    cmake \
    git \
    locales \
    sudo \
    bash-completion \
    python3-pip \
    python3-colcon-common-extensions \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Add ROS 2 GPG key and repo
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add - && \
    echo "deb http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2.list

# Install ROS 2
RUN apt update && apt install -y ros-${ROS_DISTRO}-desktop && \
    apt install -y python3-rosdep && \
    rosdep init && \
    rosdep update && \
    rm -rf /var/lib/apt/lists/*

# Setup environment
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc

# Create ROS 2 workspace
WORKDIR /root/ros2_ws
RUN mkdir -p src

# Copy optional requirements (comment if not needed)
# COPY requirements.txt ./requirements.txt
# RUN pip install -r requirements.txt

COPY requirements/dev_requirements.txt ./dev_requirements.txt
RUN pip install -r dev_requirements.txt

# Pre-install common Python packages
RUN pip install --upgrade pip && \
    pip install colcon-common-extensions vcstool

# Source environment and build (will rebuild when container is run)
CMD ["/bin/bash"]

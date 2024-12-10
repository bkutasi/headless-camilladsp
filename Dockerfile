FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libasound2-dev \
    libssl-dev \
    curl \
    alsa-utils \
    ffmpeg \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Build and install CamillaDSP
WORKDIR /camilladsp
RUN git clone --depth 1 https://github.com/HEnquist/camilladsp .
RUN cargo build --release
RUN cp target/release/camilladsp /usr/local/bin/

# Set up working directory
WORKDIR /root/camilladsp

# Sartup script
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'if [ $# -eq 0 ]; then' >> /start.sh && \
    echo '    echo "No arguments provided, using default: config.yml"' >> /start.sh && \
    echo '    camilladsp -v /root/camilladsp/config.yml' >> /start.sh && \
    echo 'else' >> /start.sh && \
    echo '    echo "Starting CamillaDSP with arguments: $@"' >> /start.sh && \
    echo '    camilladsp "$@"' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
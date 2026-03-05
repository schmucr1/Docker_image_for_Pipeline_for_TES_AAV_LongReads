FROM ubuntu:22.04

# Set environment variables to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:${PATH}"

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libncurses5-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    autoconf \
    libgsl-dev \
    gsl-bin \
    pkg-config \
    libfreetype6-dev \
    libpng-dev \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA and install Python 3.12
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3.12-distutils \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.12 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install Python packages with Snakemake 9.x
RUN pip3 install --no-cache-dir \
    cutadapt \
    pandas \
    "numpy>=1.21.0" \
    "scipy>=1.7.0" \
    "biopython>=1.79" \
    "matplotlib>=3.4.0" \
    "snakemake>=9.0" \
    "pytest>=7.0.0"

# Install minimap2
RUN curl -L https://github.com/lh3/minimap2/releases/download/v2.26/minimap2-2.26_x64-linux.tar.bz2 | tar -jxvf - && \
    cp minimap2-2.26_x64-linux/minimap2 /usr/local/bin/ && \
    rm -rf minimap2-2.26_x64-linux

# Install bedtools
RUN wget https://github.com/arq5x/bedtools2/releases/download/v2.31.1/bedtools-2.31.1.tar.gz && \
    tar -zxvf bedtools-2.31.1.tar.gz && \
    cd bedtools2 && \
    make && \
    make install && \
    cd .. && \
    rm -rf bedtools2 bedtools-2.31.1.tar.gz

# Install samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.19.2/samtools-1.19.2.tar.bz2 && \
    tar -xjf samtools-1.19.2.tar.bz2 && \
    cd samtools-1.19.2 && \
    ./configure --prefix=/usr/local && \
    make && \
    make install && \
    cd .. && \
    rm -rf samtools-1.19.2 samtools-1.19.2.tar.bz2

# Install sniffles
RUN wget https://github.com/fritzsedlazeck/Sniffles/archive/refs/tags/v2.3.3.tar.gz && \
    tar -xzf v2.3.3.tar.gz && \
    cd Sniffles-2.3.3 && \
    pip3 install . && \
    cd .. && \
    rm -rf Sniffles-2.3.3 v2.3.3.tar.gz

# Install seqkit
RUN wget https://github.com/shenwei356/seqkit/releases/download/v2.7.0/seqkit_linux_amd64.tar.gz && \
    tar -xzf seqkit_linux_amd64.tar.gz && \
    mv seqkit /usr/local/bin/ && \
    rm seqkit_linux_amd64.tar.gz

# Install ART (ART_Illumina)
RUN wget https://www.niehs.nih.gov/research/resources/assets/docs/artbinmountrainier2016.06.05linux64.tgz && \
    tar -xzf artbinmountrainier2016.06.05linux64.tgz && \
    cd art_bin_MountRainier && \
    cp art_illumina art_454 art_SOLiD /usr/local/bin/ && \
    cd .. && \
    rm -rf art_bin_MountRainier artbinmountrainier2016.06.05linux64.tgz

# Verify installations
RUN echo "Verifying installations..." && \
    echo "=== Python Version ===" && \
    python3 --version && \
    echo "=== Bioinformatics Tools ===" && \
    cutadapt --version && \
    minimap2 --version && \
    bedtools --version && \
    samtools --version && \
    sniffles --version && \
    seqkit version && \
    art_illumina --help 2>&1 | head -n 5 && \
    echo "=== Python Packages ===" && \
    python3 -c "import pandas; print(f'pandas: {pandas.__version__}')" && \
    python3 -c "import numpy; print(f'numpy: {numpy.__version__}')" && \
    python3 -c "import scipy; print(f'scipy: {scipy.__version__}')" && \
    python3 -c "import Bio; print(f'biopython: {Bio.__version__}')" && \
    python3 -c "import matplotlib; print(f'matplotlib: {matplotlib.__version__}')" && \
    python3 -c "import snakemake; print(f'snakemake: {snakemake.__version__}')" && \
    python3 -c "import pytest; print(f'pytest: {pytest.__version__}')"

# Set working directory
WORKDIR /data

# Default command
CMD ["/bin/bash"]

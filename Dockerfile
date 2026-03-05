FROM ubuntu:24.04

# Set environment variables to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/root/.local/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Update and install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    ca-certificates \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Upgrade pip
RUN python3.12 -m pip install --break-system-packages --upgrade pip setuptools wheel

# Install Python packages with Snakemake 9.x
RUN pip3 install --break-system-packages --no-cache-dir \
    cutadapt \
    pandas \
    "numpy>=1.21.0" \
    "scipy>=1.7.0" \
    "biopython>=1.79" \
    "matplotlib>=3.4.0" \
    "snakemake>=9.0" \
    "pytest>=7.0.0"

# Install minimap2
RUN curl -fsSL https://github.com/lh3/minimap2/releases/download/v2.26/minimap2-2.26_x64-linux.tar.bz2 \
    | tar -xj -C /tmp \
    && mv /tmp/minimap2-2.26_x64-linux/minimap2 /usr/local/bin/ \
    && rm -rf /tmp/minimap2-2.26_x64-linux

# Install bedtools
RUN wget -q https://github.com/arq5x/bedtools2/releases/download/v2.31.1/bedtools-2.31.1.tar.gz \
    && tar -xzf bedtools-2.31.1.tar.gz \
    && cd bedtools2 \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf bedtools2 bedtools-2.31.1.tar.gz

# Install samtools
RUN wget -q https://github.com/samtools/samtools/releases/download/1.19.2/samtools-1.19.2.tar.bz2 \
    && tar -xjf samtools-1.19.2.tar.bz2 \
    && cd samtools-1.19.2 \
    && ./configure --prefix=/usr/local \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf samtools-1.19.2 samtools-1.19.2.tar.bz2

# Install sniffles
RUN wget -q https://github.com/fritzsedlazeck/Sniffles/archive/refs/tags/v2.3.3.tar.gz \
    && tar -xzf v2.3.3.tar.gz \
    && cd Sniffles-2.3.3 \
    && pip3 install --break-system-packages --no-cache-dir . \
    && cd .. \
    && rm -rf Sniffles-2.3.3 v2.3.3.tar.gz

# Install seqkit
RUN wget -q https://github.com/shenwei356/seqkit/releases/download/v2.7.0/seqkit_linux_amd64.tar.gz \
    && tar -xzf seqkit_linux_amd64.tar.gz \
    && mv seqkit /usr/local/bin/ \
    && chmod +x /usr/local/bin/seqkit \
    && rm seqkit_linux_amd64.tar.gz

# Install ART (ART_Illumina)
RUN wget -q https://www.niehs.nih.gov/research/resources/assets/docs/artbinmountrainier2016.06.05linux64.tgz \
    && tar -xzf artbinmountrainier2016.06.05linux64.tgz \
    && cd art_bin_MountRainier \
    && cp art_illumina art_454 art_SOLiD /usr/local/bin/ \
    && chmod +x /usr/local/bin/art_* \
    && cd .. \
    && rm -rf art_bin_MountRainier artbinmountrainier2016.06.05linux64.tgz

# Verify installations
RUN echo "Verifying installations..." && \
    python3.12 --version && \
    cutadapt --version && \
    minimap2 --version && \
    bedtools --version && \
    samtools --version && \
    sniffles --version && \
    seqkit version && \
    python3 -c "import snakemake; print(f'snakemake: {snakemake.__version__}')"

WORKDIR /data

LABEL maintainer="your-email@example.com" \
      description="Bioinformatics pipeline tools with Snakemake 9.x" \
      version="1.0"

CMD ["/bin/bash"]

FROM ubuntu:24.04

# Set environment variables to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive \
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
    automake \
    libtool \
    libgsl-dev \
    gsl-bin \
    pkg-config \
    libfreetype6-dev \
    libpng-dev \
    ca-certificates \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    less \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create and activate virtual environment
RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Now upgrade pip in the virtual environment
RUN pip install --upgrade pip setuptools wheel

# Install Python packages with Snakemake 9.x
RUN pip install --no-cache-dir \
    cutadapt \
    pandas \
    "numpy>=1.21.0" \
    "scipy>=1.7.0" \
    "biopython>=1.79" \
    "matplotlib>=3.4.0" \
    "snakemake>=9.0" \
    "pytest>=7.0.0"

# Install Badread
RUN git clone https://github.com/rrwick/Badread.git \
    && pip install --no-cache-dir ./Badread \
    && rm -rf Badread

# Install minimap2 2.30
RUN curl -fsSL https://github.com/lh3/minimap2/releases/download/v2.30/minimap2-2.30_x64-linux.tar.bz2 \
    | tar -xj -C /tmp \
    && mv /tmp/minimap2-2.30_x64-linux/minimap2 /usr/local/bin/ \
    && chmod +x /usr/local/bin/minimap2 \
    && rm -rf /tmp/minimap2-2.30_x64-linux

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

# Install bcftools
RUN wget -q https://github.com/samtools/bcftools/releases/download/1.19/bcftools-1.19.tar.bz2 \
    && tar -xjf bcftools-1.19.tar.bz2 \
    && cd bcftools-1.19 \
    && ./configure --prefix=/usr/local \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf bcftools-1.19 bcftools-1.19.tar.bz2

# Install sniffles
RUN wget -q https://github.com/fritzsedlazeck/Sniffles/archive/refs/tags/v2.3.3.tar.gz \
    && tar -xzf v2.3.3.tar.gz \
    && cd Sniffles-2.3.3 \
    && pip install --no-cache-dir . \
    && cd .. \
    && rm -rf Sniffles-2.3.3 v2.3.3.tar.gz

# Install seqkit
RUN wget -q https://github.com/shenwei356/seqkit/releases/download/v2.7.0/seqkit_linux_amd64.tar.gz \
    && tar -xzf seqkit_linux_amd64.tar.gz \
    && mv seqkit /usr/local/bin/ \
    && chmod +x /usr/local/bin/seqkit \
    && rm seqkit_linux_amd64.tar.gz

# Install seqtk
RUN git clone https://github.com/lh3/seqtk.git \
    && cd seqtk \
    && make -j$(nproc) \
    && cp seqtk /usr/local/bin/ \
    && chmod +x /usr/local/bin/seqtk \
    && cd .. \
    && rm -rf seqtk

# Install vsearch
RUN wget -q https://github.com/torognes/vsearch/archive/v2.30.4.tar.gz \
    && tar -xzf v2.30.4.tar.gz \
    && cd vsearch-2.30.4 \
    && ./autogen.sh \
    && ./configure CFLAGS="-O2" CXXFLAGS="-O2" --prefix=/usr/local \
    && make ARFLAGS="cr" -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf vsearch-2.30.4 v2.30.4.tar.gz

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
    echo "=== Python Version ===" && \
    python3 --version && \
    echo "\n=== System Tools ===" && \
    less --version && \
    echo "\n=== Bioinformatics Tools ===" && \
    cutadapt --version && \
    minimap2 --version && \
    bedtools --version && \
    samtools --version && \
    bcftools --version && \
    sniffles --version && \
    seqkit version && \
    seqtk 2>&1 | head -n 3 && \
    vsearch --version && \
    badread --version && \
    art_illumina --help 2>&1 | head -n 5 && \
    echo "\n=== Python Packages ===" && \
    python3 -c "import pandas; print(f'pandas: {pandas.__version__}')" && \
    python3 -c "import numpy; print(f'numpy: {numpy.__version__}')" && \
    python3 -c "import scipy; print(f'scipy: {scipy.__version__}')" && \
    python3 -c "import Bio; print(f'biopython: {Bio.__version__}')" && \
    python3 -c "import matplotlib; print(f'matplotlib: {matplotlib.__version__}')" && \
    python3 -c "import snakemake; print(f'snakemake: {snakemake.__version__}')" && \
    python3 -c "import pytest; print(f'pytest: {pytest.__version__}')"

WORKDIR /data

LABEL maintainer="your-email@example.com" \
      description="Bioinformatics pipeline tools with Snakemake 9.x" \
      version="1.0"

CMD ["/bin/bash"]

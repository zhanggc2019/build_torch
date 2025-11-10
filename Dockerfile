ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES}

# 配置阿里云 apt 源 (兼容 Ubuntu 22.04 和 24.04)
RUN if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then \
        sed -i 's|http://archive.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list.d/ubuntu.sources && \
        sed -i 's|http://security.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list.d/ubuntu.sources; \
    elif [ -f /etc/apt/sources.list ]; then \
        sed -i 's|http://archive.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list && \
        sed -i 's|http://security.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list; \
    fi

# 配置 APT 以处理可能的签名问题,并安装软件包
RUN echo 'Acquire::AllowInsecureRepositories "true";' > /etc/apt/apt.conf.d/99allow-insecure && \
    echo 'Acquire::AllowDowngradeToInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99allow-insecure && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    apt-get update && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
        wget build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev \
        libreadline-dev libffi-dev libsqlite3-dev libbz2-dev liblzma-dev && \
    rm /etc/apt/apt.conf.d/99allow-insecure && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

ARG PYTHON_VERSION

# 配置 pip 使用清华源
RUN mkdir -p /root/.pip && \
    echo "[global]" > /root/.pip/pip.conf && \
    echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> /root/.pip/pip.conf && \
    echo "trusted-host = pypi.tuna.tsinghua.edu.cn" >> /root/.pip/pip.conf

RUN cd /tmp && \
    wget --no-check-certificate https://mirrors.huaweicloud.com/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar -xvf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make && make install && \
    cd .. && rm Python-${PYTHON_VERSION}.tgz && rm -r Python-${PYTHON_VERSION} && \
    ln -s /usr/local/bin/python3 /usr/local/bin/python && \
    ln -s /usr/local/bin/pip3 /usr/local/bin/pip && \
    rm -rf /root/.cache/pip

ARG PYTORCH_VERSION
ARG PYTORCH_VERSION_SUFFIX
ARG TORCHVISION_VERSION
ARG TORCHVISION_VERSION_SUFFIX
ARG TORCHAUDIO_VERSION
ARG TORCHAUDIO_VERSION_SUFFIX
ARG PYTORCH_DOWNLOAD_URL

RUN if [ -z "$TORCHAUDIO_VERSION" ]; \
    then \
        TORCHAUDIO=""; \
    else \
        TORCHAUDIO="torchaudio==${TORCHAUDIO_VERSION}${TORCHAUDIO_VERSION_SUFFIX}"; \
    fi && \
    if [ -z "$PYTORCH_DOWNLOAD_URL" ]; \
    then \
        pip install \
            torch==${PYTORCH_VERSION}${PYTORCH_VERSION_SUFFIX} \
            torchvision==${TORCHVISION_VERSION}${TORCHVISION_VERSION_SUFFIX} \
            ${TORCHAUDIO}; \
    else \
        pip install \
            torch==${PYTORCH_VERSION}${PYTORCH_VERSION_SUFFIX} \
            torchvision==${TORCHVISION_VERSION}${TORCHVISION_VERSION_SUFFIX} \
            ${TORCHAUDIO} \
            -f ${PYTORCH_DOWNLOAD_URL}; \
    fi && \
    rm -r /root/.cache/pip

# 复制并安装 requirements.txt 中的依赖
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt && \
    rm -r /root/.cache/pip

WORKDIR /workspace

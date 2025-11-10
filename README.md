# PyTorch Docker 镜像构建项目

这是一个用于构建 PyTorch Docker 镜像的项目，支持自定义 Python 版本、PyTorch 版本和 CUDA 版本。镜像使用国内镜像源（阿里云、华为云）加速构建过程。

## 📋 目录

- [项目特性](#项目特性)
- [快速开始](#快速开始)
- [版本配置](#版本配置)
- [详细说明](#详细说明)
- [常见问题](#常见问题)
- [注意事项](#注意事项)

## ✨ 项目特性

- ✅ **参数化构建**: 通过 `build.sh` 脚本灵活配置各种版本
- ✅ **国内镜像源**: 使用阿里云 apt 源和 pip 源，加速下载
- ✅ **CUDA 支持**: 支持 CUDA 12.4 的 PyTorch 版本
- ✅ **自动依赖安装**: 自动安装 requirements.txt 中的 Python 依赖
- ✅ **优化构建**: 最小化镜像大小，清理构建缓存
- ✅ **兼容性好**: 支持 Ubuntu 22.04 和 24.04

## 🚀 快速开始

### 1. 克隆或下载项目

```bash
cd /path/to/build_torch
```

### 2. 使用默认配置构建

```bash
# Linux/Mac
./build.sh

# Windows (PowerShell)
sh build.sh
```

默认配置会构建：
- **基础镜像**: Ubuntu 24.04
- **Python**: 3.12.11
- **PyTorch**: 2.6.0 (CUDA 12.4)
- **TorchVision**: 0.21.0
- **TorchAudio**: 2.6.0

### 3. 运行容器

```bash
# 基本运行
docker run -it zgc/pytorch:py3.12-cuda12.4.0-ubuntu24.04 bash

# 挂载本地目录
docker run -it -v /path/to/your/code:/workspace zgc/pytorch:py3.12-cuda12.4.0-ubuntu24.04 bash

# 使用 GPU (需要 nvidia-docker)
docker run --gpus all -it zgc/pytorch:py3.12-cuda12.4.0-ubuntu24.04 bash
```

## ⚙️ 版本配置

### 修改 build.sh 配置不同版本

编辑 `build.sh` 文件，修改以下变量：

```bash
#!/bin/sh
# 基础镜像
export BASE_IMAGE=ubuntu:24.04

# Python 版本
export PYTHON_VERSION=3.12.11

# PyTorch 相关版本
export PYTORCH_VERSION=2.6.0
export TORCHVISION_VERSION=0.21.0
export TORCHAUDIO_VERSION=2.6.0

# PyTorch 下载源 (CUDA 版本)
export PYTORCH_INDEX_URL=https://download.pytorch.org/whl/cu124

# 镜像标签
export IMAGE_TAG=py3.12-cuda12.4.0-ubuntu24.04
```

### 常用版本组合示例

#### 示例 1: PyTorch 2.6.0 + CUDA 12.4 (默认)

```bash
export PYTORCH_VERSION=2.6.0
export TORCHVISION_VERSION=0.21.0
export TORCHAUDIO_VERSION=2.6.0
export PYTORCH_INDEX_URL=https://download.pytorch.org/whl/cu124
export IMAGE_TAG=py3.12-cuda12.4.0-ubuntu24.04
```

#### 示例 2: PyTorch 2.5.1 + CUDA 12.1

```bash
export PYTORCH_VERSION=2.5.1
export TORCHVISION_VERSION=0.20.1
export TORCHAUDIO_VERSION=2.5.1
export PYTORCH_INDEX_URL=https://download.pytorch.org/whl/cu121
export IMAGE_TAG=py3.12-cuda12.1.0-ubuntu24.04
```

#### 示例 3: CPU 版本 (无 CUDA)

```bash
export PYTORCH_VERSION=2.6.0
export TORCHVISION_VERSION=0.21.0
export TORCHAUDIO_VERSION=2.6.0
export PYTORCH_INDEX_URL=""  # 留空使用默认 PyPI 源
export IMAGE_TAG=py3.12-cpu-ubuntu24.04
```

#### 示例 4: Python 3.11 + PyTorch 2.4.1

```bash
export PYTHON_VERSION=3.11.9
export PYTORCH_VERSION=2.4.1
export TORCHVISION_VERSION=0.19.1
export TORCHAUDIO_VERSION=2.4.1
export PYTORCH_INDEX_URL=https://download.pytorch.org/whl/cu124
export IMAGE_TAG=py3.11-cuda12.4.0-ubuntu24.04
```

### 查找可用的 PyTorch 版本

访问 [PyTorch 官方网站](https://pytorch.org/get-started/previous-versions/) 查看历史版本和对应的安装命令。

常用 CUDA 版本对应的下载 URL:
- CUDA 12.4: `https://download.pytorch.org/whl/cu124`
- CUDA 12.1: `https://download.pytorch.org/whl/cu121`
- CUDA 11.8: `https://download.pytorch.org/whl/cu118`
- CPU 版本: 留空或使用 `https://download.pytorch.org/whl/cpu`

## 📖 详细说明

### 项目结构

```
build_torch/
├── Dockerfile              # Docker 镜像构建文件
├── build.sh               # 构建脚本 (配置版本参数)
├── requirements.txt       # Python 依赖包列表
├── README.md             # 项目说明文档
└── docs/
    └── 参数传递说明.md    # 参数传递机制详细说明
```

### Dockerfile 说明

Dockerfile 采用参数化设计，主要步骤：

1. **配置 apt 源**: 使用阿里云镜像源加速系统包下载
2. **安装系统依赖**: 安装编译 Python 所需的系统库
3. **配置 pip 源**: 使用阿里云 PyPI 镜像源
4. **编译安装 Python**: 从华为云下载并编译指定版本的 Python
5. **安装 PyTorch**: 从 PyTorch 官方源安装指定版本
6. **安装项目依赖**: 安装 requirements.txt 中的包

### requirements.txt 说明

当前包含的依赖：

```
# 核心依赖
transformers==4.53.0      # Hugging Face Transformers
diffusers==0.35.1         # Diffusion 模型库

# Web 框架
fastapi>=0.119.0          # FastAPI Web 框架
uvicorn[standard]>=0.37.0 # ASGI 服务器

# 数据验证
pydantic>=2.12.0          # 数据验证
pydantic-settings>=2.11.0 # 配置管理

# 图像处理
Pillow>=10.0.0            # 图像处理库

# 日志
loguru>=0.7.0             # 日志库

# 工具
python-multipart>=0.0.6   # 文件上传支持
aiofiles>=23.0.0          # 异步文件操作
redis[hiredis]            # Redis 客户端
httpx>=0.28.1             # HTTP 客户端
```

**修改依赖**: 直接编辑 `requirements.txt` 文件，然后重新构建镜像。

### 镜像源配置

#### APT 源 (阿里云)

- Ubuntu 24.04: 使用 DEB822 格式 (`/etc/apt/sources.list.d/ubuntu.sources`)
- Ubuntu 22.04 及更早: 使用传统格式 (`/etc/apt/sources.list`)

#### PIP 源 (阿里云)

配置文件位置: `/root/.pip/pip.conf`

```ini
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
trusted-host = mirrors.aliyun.com
```

#### Python 源 (华为云)

下载地址: `https://mirrors.huaweicloud.com/python/`

## ❓ 常见问题

### 1. 构建失败: GPG 签名错误

**问题**: 
```
W: GPG error: http://mirrors.aliyun.com/ubuntu noble InRelease: At least one invalid signature was encountered.
```

**解决方案**: 
Dockerfile 已经配置了临时允许未认证的包，如果仍然出现问题，可以尝试：
```bash
docker system prune -a  # 清理 Docker 缓存
```

### 2. 构建失败: 磁盘空间不足

**问题**: 
```
no space left on device
```

**解决方案**:
```bash
# 清理 Docker 系统
docker system prune -a

# 检查磁盘空间
df -h

# 清理未使用的镜像
docker image prune -a
```

### 3. PyTorch 版本找不到

**问题**: 
```
ERROR: Could not find a version that satisfies the requirement torch==2.x.x
```

**解决方案**:
- 检查 PyTorch 官方是否支持该版本
- 确认 CUDA 版本与 PyTorch 版本兼容
- 访问 https://download.pytorch.org/whl/cu124/ 查看可用版本

### 4. requirements.txt 安装失败

**问题**: 某些包需要先安装 torch

**解决方案**: 
Dockerfile 已经调整为先安装 PyTorch，再安装 requirements.txt。如果仍有问题，检查包的依赖关系。

### 5. 如何安装 flash-attn?

flash-attn 需要编译且耗时较长，建议在容器运行后手动安装：

```bash
# 进入容器
docker run -it zgc/pytorch:py3.12-cuda12.4.0-ubuntu24.04 bash

# 安装 flash-attn
pip install flash-attn --no-build-isolation
```

## ⚠️ 注意事项

### 1. 版本兼容性

- **Python 版本**: 确保 Python 版本与 PyTorch 兼容
- **CUDA 版本**: PyTorch 版本需要与 CUDA 版本匹配
- **系统要求**: 使用 GPU 需要安装 nvidia-docker

### 2. 构建时间

- **首次构建**: 约 10-20 分钟（取决于网络速度）
- **Python 编译**: 约 5-8 分钟
- **PyTorch 下载**: 约 2-5 分钟（CUDA 版本较大）

### 3. 镜像大小

- **基础镜像**: 约 2-3 GB
- **完整镜像**: 约 8-12 GB（包含 CUDA 版本的 PyTorch）

### 4. 网络问题

如果国内镜像源访问失败，可以尝试：
- 更换其他镜像源（清华、中科大等）
- 使用代理
- 直接使用官方源（速度较慢）

### 5. GPU 支持

使用 GPU 需要：
1. 宿主机安装 NVIDIA 驱动
2. 安装 nvidia-docker2
3. 运行时添加 `--gpus all` 参数

验证 GPU:
```bash
docker run --gpus all -it zgc/pytorch:py3.12-cuda12.4.0-ubuntu24.04 python -c "import torch; print(torch.cuda.is_available())"
```

### 6. 修改配置后重新构建

修改 `build.sh` 或 `requirements.txt` 后，需要重新构建镜像：

```bash
./build.sh
```

如果需要强制重新构建（不使用缓存）：

```bash
docker build --no-cache \
    --build-arg BASE_IMAGE=ubuntu:24.04 \
    --build-arg PYTHON_VERSION=3.12.11 \
    --build-arg PYTORCH_VERSION=2.6.0 \
    --build-arg TORCHVISION_VERSION=0.21.0 \
    --build-arg TORCHAUDIO_VERSION=2.6.0 \
    --build-arg PYTORCH_INDEX_URL=https://download.pytorch.org/whl/cu124 \
    -t zgc/pytorch:py3.12-cuda12.4.0-ubuntu24.04 \
    -f Dockerfile \
    .
```

## 📚 参考资料

- [PyTorch 官方文档](https://pytorch.org/docs/stable/index.html)
- [PyTorch 历史版本](https://pytorch.org/get-started/previous-versions/)
- [Docker 官方文档](https://docs.docker.com/)
- [NVIDIA Docker 文档](https://github.com/NVIDIA/nvidia-docker)

## 📝 更新日志

- **2025-11-10**: 初始版本
  - 支持 Ubuntu 24.04
  - 支持 Python 3.12.11
  - 支持 PyTorch 2.6.0 + CUDA 12.4
  - 配置国内镜像源加速构建

## 📄 许可证

本项目仅供学习和研究使用。


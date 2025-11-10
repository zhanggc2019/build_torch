#!/bin/sh
export BASE_IMAGE=ubuntu:24.04
export PYTHON_VERSION=3.12.11
export PYTORCH_VERSION=2.6.0
export TORCHVISION_VERSION=0.21.0
export TORCHAUDIO_VERSION=2.6.0
export PYTORCH_INDEX_URL=https://download.pytorch.org/whl/cu124

export IMAGE_TAG=py3.12-cuda12.4.0-ubuntu24.04

docker build \
    --build-arg BASE_IMAGE=${BASE_IMAGE} \
    --build-arg PYTHON_VERSION=${PYTHON_VERSION} \
    --build-arg PYTORCH_VERSION=${PYTORCH_VERSION} \
    --build-arg TORCHVISION_VERSION=${TORCHVISION_VERSION} \
    --build-arg TORCHAUDIO_VERSION=${TORCHAUDIO_VERSION} \
    --build-arg PYTORCH_INDEX_URL=${PYTORCH_INDEX_URL} \
    -t zgc/pytorch:${IMAGE_TAG} \
    -f Dockerfile \
    .

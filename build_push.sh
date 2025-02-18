#!/bin/bash

# 定义仓库和镜像名称的前缀
REPOSITORY="ghcr.io/kalicyh/poetry"

# 检查输入的参数
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <python_version> [poetry_version]"
    exit 1
fi

# 获取传入的 Python 和 Poetry 版本
PYTHON_VERSION=$1
POETRY_VERSION=${2:-latest}  # 如果没有传入 Poetry 版本，则使用 "latest" 作为默认值

# 如果 Poetry 版本是 "latest"，则默认使用最新版本的 Poetry
if [ "$POETRY_VERSION" == "latest" ]; then
    echo "No Poetry version specified. Using the latest version..."
    POETRY_VERSION="latest"
fi

IMAGE_NAME="${REPOSITORY}:v${PYTHON_VERSION}_${POETRY_VERSION}"

# 输出正在构建的镜像信息
echo "Building Docker image with Python ${PYTHON_VERSION} and Poetry ${POETRY_VERSION}..."
echo "Image name: ${IMAGE_NAME}"

# 创建 Dockerfile
cat > Dockerfile <<EOF
FROM python:${PYTHON_VERSION}-slim AS builder
ARG POETRY_VERSION=${POETRY_VERSION}
ENV POETRY_HOME=/opt/poetry
ENV POETRY_VIRTUALENVS_IN_PROJECT=1
ENV POETRY_VIRTUALENVS_CREATE=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV POETRY_CACHE_DIR=/opt/.cache
RUN if [ "\${POETRY_VERSION}" = "latest" ]; then \
    pip install poetry; \
    else \
    pip install "poetry==\${POETRY_VERSION}"; \
    fi

WORKDIR /app
RUN rm -rf \$POETRY_CACHE_DIR
ENTRYPOINT ["bash"]
EOF

# 使用 buildx 构建并推送多架构镜像
docker buildx build --platform linux/amd64,linux/arm64 -t ${IMAGE_NAME} --push .

# 检查构建和推送是否成功
if [ $? -eq 0 ]; then
    echo "镜像构建并推送成功！"
else
    echo "构建或推送失败！"
fi

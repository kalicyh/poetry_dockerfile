# poetry dockerfile

预装poetry的python镜像

便于dockerfile内使用

## 使用

ccr.ccs.tencentyun.com/kalicyh/poetry:v3.10_2.1

示例：

```dockerfile
FROM ccr.ccs.tencentyun.com/kalicyh/poetry:v3.10_2.1 AS builder

WORKDIR /app

COPY pyproject.toml poetry.lock  /app/

# 安装依赖并在安装后清理缓存。
# 这样可以节省一些空间。
RUN poetry install --no-root
RUN rm -rf $POETRY_CACHE_DIR

# # 现在，我们从构建器创建运行时镜像。
# # 我们将复制环境变量和 PATH 路径引用。
FROM python:3.10-slim AS runtime

ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:$PATH"

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

CMD ["python", "main.py"]

```

## 开发

### 脚本一键上传到自己仓库

#### 设置自己的仓库名

修改sh文件中的`REPOSITORY`

#### 仅传入python版本

```sh
./build_and_push.sh 3.10
```

#### 更新多个py版本

./build_and_push.sh 3.10 && ./build_and_push.sh 3.11 && ./build_and_push.sh 3.12 && ./build_and_push.sh 3.13

#### 传入poetry版本

```sh
./build_and_push.sh 3.10 2.1
```

#### 权限不足

`zsh: permission denied: ./build_push.sh`

```sh
sudo chmod 777 build_push.sh
```

### 编译命令

docker build -t ccr.ccs.tencentyun.com/kalicyh/poetry:v3.10_2.1 .

### 运行命令

docker run -it ccr.ccs.tencentyun.com/kalicyh/poetry:v3.10_2.1

### 推送

docker push ccr.ccs.tencentyun.com/kalicyh/poetry:v3.10_2.1
# ===========================================================================
# Stage 1: Build
# ===========================================================================
FROM golang:1.25-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

# 先复制依赖文件，利用 Docker 缓存层
COPY go.mod go.sum ./
RUN go mod download

# 复制源代码并编译
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/server ./cmd

# ===========================================================================
# Stage 2: Runtime
# ===========================================================================
FROM alpine:3.20

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

# 从 builder 阶段复制编译产物
COPY --from=builder /app/server /app/server

# 复制配置文件和迁移文件
COPY config.yml /app/config.yml
COPY migrations/ /app/migrations/

# 暴露应用端口
EXPOSE 8083

# 启动应用
CMD ["/app/server"]

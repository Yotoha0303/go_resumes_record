# 架构设计

本文档描述 `go-resumes-record` 项目的整体架构、分层设计、请求处理流程和技术栈。

## 1. 系统架构总览

```text
┌─────────────────────────────────────────────────────────────┐
│                        Client                               │
│              (curl / 前端 / Postman)                         │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTP
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                     Gin HTTP Server                         │
│  ┌─────────────┐  ┌──────────────────────────────────────┐  │
│  │  Middleware  │  │           Router                     │  │
│  │  - Logger    │──│  GET /ping                           │  │
│  │  - Recovery  │  │  POST /work                          │  │
│  └─────────────┘  └──────────────┬───────────────────────┘  │
└──────────────────────────────────┼──────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────┐
│                     Handler 层                              │
│         WorkInfoRecordHandler                               │
│         参数绑定 → 调用 Service → 返回响应                    │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   Server / Service 层                        │
│         WorkInfoRecordServer                                │
│         业务逻辑处理 → 调用 DAO                               │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      DAO 层                                 │
│         WorkInfoRecordDAO                                   │
│         GORM 数据库操作                                       │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      Model 层                               │
│         WorkInfoRecord (GORM Model)                         │
│         表结构定义 + 枚举常量                                  │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      MySQL                                  │
│         go_resumes_record 数据库                             │
│         companies / work_info_records /                     │
│         recruitment_progress_records                        │
└─────────────────────────────────────────────────────────────┘
```

## 2. 分层架构

项目采用经典的四层架构，各层职责清晰，依赖单向向下传递。

| 层级 | 包路径 | 职责 | 依赖 |
| --- | --- | --- | --- |
| Handler | `internal/handler` | HTTP 请求参数绑定、校验、调用 Service、返回响应 | Service |
| Server | `internal/server` | 业务逻辑处理、数据转换 | DAO |
| DAO | `internal/dao` | 数据库 CRUD 操作（GORM） | Model |
| Model | `internal/model` | 数据库表结构定义、枚举常量 | 无 |

辅助层：

| 包路径 | 职责 |
| --- | --- |
| `internal/request` | 请求 DTO（Request），用于参数绑定和校验 |
| `internal/response` | 统一响应结构和错误码定义 |
| `internal/apperror` | 业务错误类型，携带 HTTP 状态码和业务码 |
| `internal/middleware` | HTTP 中间件（请求 ID、访问日志、panic 恢复） |
| `config` | 配置加载（YAML + .env） |
| `pkg/database` | 数据库连接初始化 |
| `router` | 路由注册和 Gin Engine 组装 |

## 3. 目录结构

```text
go-resumes-record/
├── cmd/                          # 程序入口
│   └── main.go                   # main 函数，调用 app.Run()
├── config/                       # 配置结构体与加载逻辑
│   └── config.go                 # YAML 解析 + .env 加载
├── docs/                         # 项目文档
│   ├── architecture.md           # 架构设计（本文件）
│   ├── product_design.md         # 产品设计
│   ├── table_design.md           # 数据库表设计
│   ├── api_design.md             # API 设计
│   └── project_evolution.md      # 项目演进记录
├── internal/                     # 业务代码（不对外暴露）
│   ├── app/                      # 应用启动与依赖注入
│   │   ├── app.go                # Run() 启动入口
│   │   ├── deps.go               # InitDeps() 依赖组装
│   │   └── server.go             # http.Server 工厂
│   ├── apperror/                 # 业务错误类型
│   ├── dao/                      # 数据访问层
│   ├── handler/                  # HTTP Handler
│   ├── middleware/                # HTTP 中间件
│   ├── model/                    # GORM Model 与枚举
│   ├── request/                  # 请求 DTO
│   ├── response/                 # 统一响应与错误码
│   └── server/                   # 业务 Service 层
├── migrations/                   # goose SQL 迁移文件
├── pkg/                          # 可复用的公共包
│   └── database/                 # 数据库初始化
├── router/                       # Gin 路由注册
├── config.yml                    # 应用配置（非敏感）
├── .env                          # 环境变量（敏感，不提交）
├── .env.example                  # 环境变量示例
├── .golangci.yml                 # golangci-lint 配置
├── Dockerfile                    # Docker 构建文件
├── docker-compose.yml            # Docker Compose 编排
├── Makefile                      # 常用命令
├── go.mod                        # Go 模块定义
└── README.md                     # 项目说明
```

## 4. 请求处理流程

以 `POST /work` 创建岗位投递记录为例：

```text
1. HTTP 请求进入 Gin Router
       │
2. Middleware 处理（Logger、Recovery）
       │
3. Handler.WorkInfoRecordHandler.CreateWorkInfoRecordHandler()
       │  - c.ShouldBindJSON() 绑定请求体到 CreateWorkInfoRecordRequest
       │  - 校验必填字段（binding:"required"）
       │
4. Server.WorkInfoRecordServer.CreateWorkInfoRecord()
       │  - 将 Request DTO 转换为 Model
       │  - 调用 DAO 层
       │
5. DAO.CreateWorkInfoRecord()
       │  - db.WithContext(ctx).Create(&workInfoRecord)
       │  - GORM 生成 INSERT SQL 并执行
       │
6. MySQL 写入 work_info_records 表
       │
7. 逐层返回，Handler 调用 response.Success(c, nil) 返回 JSON
```

响应格式：

```json
{
  "code": 200,
  "message": "success",
  "data": null
}
```

## 5. 配置管理

项目采用 **敏感信息与非敏感信息分离** 的策略：

| 配置来源 | 文件 | 内容 | 是否提交 Git |
| --- | --- | --- | --- |
| YAML 配置 | `config.yml` | MySQL host/port/database/user、Server port | 是 |
| 环境变量 | `.env` | `MYSQL_PASSWORD` | 否 |
| 环境变量示例 | `.env.example` | `MYSQL_PASSWORD=your_password` | 是 |

加载顺序：

1. `config.LoadEnv()` — 调用 `godotenv.Load()` 读取 `.env`
2. `config.LoadConfig("config.yml")` — 读取 YAML 文件并反序列化
3. `database.InitDB(cfg)` — 从 `os.Getenv("MYSQL_PASSWORD")` 读取密码，拼接 DSN

## 6. 数据库设计

### 核心表

| 表名 | 说明 |
| --- | --- |
| `companies` | 公司基础信息 |
| `work_info_records` | 岗位投递记录 |
| `recruitment_progress_records` | 招聘进度与跟进节点 |

### 表关系

```text
companies 1 ─── N work_info_records 1 ─── N recruitment_progress_records
```

- 一个公司可以对应多个岗位投递记录
- 一个岗位投递记录可以对应多条招聘进度/沟通节点

### Migration 管理

使用 [goose](https://github.com/pressly/goose) 管理数据库迁移：

```bash
make migrate-up          # 执行迁移
make migrate-down        # 回滚最近一次
make migrate-status      # 查看状态
make migrate-create name=xxx  # 创建新迁移
```

详细表设计见 `docs/table_design.md`。

## 7. 技术栈

| 技术 | 版本 | 用途 |
| --- | --- | --- |
| Go | 1.25+ | 后端开发语言 |
| Gin | v1.12.0 | HTTP Web 框架 |
| GORM | v1.31.2 | ORM / 数据库访问 |
| MySQL | 8.0+ | 业务数据存储 |
| goose | latest | 数据库 migration 管理 |
| goccy/go-yaml | v1.19.2 | YAML 配置解析 |
| godotenv | v1.5.1 | 本地 .env 加载 |
| golangci-lint | latest | 代码静态检查 |
| Docker | latest | 容器化部署 |
| Docker Compose | v2 | 多容器编排 |

## 8. 启动流程

```text
main()
  └── app.Run()
        ├── slog.New()              创建日志器
        ├── InitDeps()              依赖注入
        │     ├── config.LoadEnv()         加载 .env
        │     ├── config.LoadConfig()      加载 config.yml
        │     ├── database.InitDB()        初始化 MySQL 连接
        │     ├── server.NewWorkInfoRecord() 创建 Service
        │     ├── handler.NewWorkInfoRecordHandler() 创建 Handler
        │     └── router.SetRouter()       注册路由
        ├── NewHTTPServer()         创建 HTTP Server
        └── server.ListenAndServe() 启动监听
```

## 9. Docker 部署

使用 `docker compose up --build` 一键启动：

- **app** 服务：Go 应用，多阶段构建
- **mysql** 服务：MySQL 8.0，数据持久化

详见项目根目录的 `Dockerfile` 和 `docker-compose.yml`。

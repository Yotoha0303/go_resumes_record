# Go Resumes Record

`go-resumes-record` 是一个基于 **Go + Gin + GORM + MySQL** 的个人求职投递记录系统，用于记录公司、岗位、投递渠道、招聘进度、HR 反馈和最终结果，帮助求职过程从“零散记录”变成“可查询、可跟进、可复盘”的结构化数据。

## 1. 项目定位

本项目当前定位为 **个人求职投递管理系统 MVP**。

核心目标不是做一个完整招聘平台，而是解决个人求职过程中的几个实际问题：

- 投递了哪些岗位？
- 哪些岗位需要继续跟进？
- 哪些公司、岗位、渠道更有效？
- 面试反馈和拒绝原因是否被沉淀？
- 后续如何根据数据调整投递策略和简历内容？

## 2. 核心功能

### 已实现

| 功能 | 状态 | 说明 |
| --- | --- | --- |
| Gin HTTP 服务 | 已实现 | 基础路由和服务启动 |
| MySQL 连接 | 已实现 | 基于 GORM 初始化数据库连接 |
| 配置加载 | 已实现 | 使用 `config.yml` + `.env` |
| 健康检查 | 已实现 | `GET /ping` |
| 创建岗位投递记录 | 初版已实现 | 当前接口为 `POST /work` |
| 数据库 migration | 已实现 | 使用 goose 管理表结构 |

### 设计中 / 待实现

| 功能 | 优先级 | 说明 |
| --- | --- | --- |
| 公司信息管理 | P0 | `companies` 表已设计并生成 migration |
| 投递记录列表查询 | P0 | 支持分页、状态筛选、关键词搜索 |
| 投递详情查询 | P0 | 展示岗位、公司、进度时间线 |
| 招聘进度记录 | P0 | 记录一面、二面、HR 面、拒绝、Offer 等节点 |
| 待跟进列表 | P0 | 根据 `next_follow_up_time` 查询需要跟进的岗位 |
| 渠道统计 | P1 | 分析 BOSS、猎聘、内推、社群等渠道效果 |
| AI 辅助分析 | P3 | 后续提取岗位关键词、总结能力缺口 |

## 3. 技术栈

| 技术 | 用途 |
| --- | --- |
| Go | 后端开发语言 |
| Gin | HTTP Web 框架 |
| GORM | ORM / 数据库访问 |
| MySQL | 业务数据存储 |
| goose | 数据库 migration 管理 |
| goccy/go-yaml | YAML 配置解析 |
| godotenv | 本地环境变量加载 |
| Makefile | 常用命令封装 |

## 4. 项目结构

```text
.
├── cmd/                         # 程序入口
│   └── main.go
├── config/                      # 配置结构与配置加载
├── docs/                        # 项目文档
│   ├── product_design.md        # 产品设计
│   ├── table_design.md          # 数据库表设计
│   ├── api_design.md            # API 设计
│   └── project_evolution.md     # 项目演进记录
├── internal/
│   ├── app/                     # 依赖初始化与 HTTP Server
│   ├── apperror/                # 业务错误
│   ├── dao/                     # 数据访问层
│   ├── handler/                 # HTTP Handler
│   ├── middleware/              # HTTP 中间件
│   ├── model/                   # GORM Model / 枚举
│   ├── request/                 # 请求 DTO
│   ├── response/                # 统一响应结构
│   └── server/                  # 业务服务层
├── migrations/                  # goose migration SQL
├── pkg/database/                # 数据库初始化
├── router/                      # 路由注册
├── config.yml                   # 本地配置文件
├── Makefile                     # 常用命令
└── README.md
```

## 5. 快速开始

### 5.1 环境要求

- Go 1.25+
- MySQL 8.0+
- goose CLI
- make，可选

安装 goose：

```bash
go install github.com/pressly/goose/v3/cmd/goose@latest
```

### 5.2 准备数据库

创建数据库：

```sql
CREATE DATABASE IF NOT EXISTS go_resumes_record
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;
```

### 5.3 配置环境变量

复制环境变量示例：

```bash
cp .env.example .env
```

编辑 `.env`：

```env
MYSQL_PASSWORD=your_password
```

确认 `config.yml` 中的数据库配置：

```yaml
mysql:
  user: root
  host: "127.0.0.1"
  port: 3306
  database: go_resumes_record
server:
  port: 8083
```

### 5.4 执行 migration

校验 migration：

```bash
make migrate-validate
```

执行 migration：

```bash
make migrate-up
```

如果不使用 Makefile，也可以直接执行：

```bash
goose -dir migrations mysql "root:${MYSQL_PASSWORD}@tcp(127.0.0.1:3306)/go_resumes_record?parseTime=true" up
```

### 5.5 启动服务

```bash
make run
```

服务默认监听：

```text
http://127.0.0.1:8083
```

## 6. 当前可用接口

### 健康检查

```bash
curl http://127.0.0.1:8083/ping
```

成功响应：

```json
{
  "code": 200,
  "message": "success"
}
```

### 创建岗位投递记录，当前初版接口

```bash
curl -X POST http://127.0.0.1:8083/work \
  -H "Content-Type: application/json" \
  -d '{
    "job_name": "Go 后端开发工程师",
    "company_name": "示例科技有限公司",
    "education_background": 2,
    "work_place": "广州天河"
  }'
```

> 注意：当前代码仍是初版接口。执行 `migrations/00002_evolve_job_application_tables.sql` 后，后端需要同步改造为 `company_id` / 自动创建公司模式，否则创建投递记录时会缺少 `company_id`。

完整 API 目标设计见：

```text
docs/api_design.md
```

## 7. 数据库设计

当前核心表：

| 表名 | 说明 |
| --- | --- |
| `companies` | 公司基础信息 |
| `work_info_records` | 岗位投递记录 |
| `recruitment_progress_records` | 招聘进度与跟进节点 |

表关系：

```text
companies 1 ─── N work_info_records 1 ─── N recruitment_progress_records
```

详细设计见：

```text
docs/table_design.md
```

## 8. 常用命令

| 命令 | 说明 |
| --- | --- |
| `make run` | 启动本地服务 |
| `make tidy` | 整理 Go 依赖 |
| `make migrate-validate` | 校验 migration 文件 |
| `make migrate-status` | 查看 migration 状态 |
| `make migrate-up` | 执行 migration |

## 9. 文档索引

| 文档 | 说明 |
| --- | --- |
| `docs/product_design.md` | 产品设计与版本规划 |
| `docs/table_design.md` | 数据库表设计 |
| `docs/api_design.md` | API 设计 |
| `docs/project_evolution.md` | 项目阶段演进记录 |
| `docs/bussiness_rules.md` | 业务规则草稿 |

## 10. 开发注意事项

1. 不要把 `.env`、数据库密码、HR 联系方式提交到 Git。
2. 不要在日志中打印完整请求体，联系方式、手机号、邮箱属于敏感信息。
3. migration 要保持可回滚，避免直接修改已提交的历史 migration。
4. 当前 `00002` migration 已将表结构演进到公司表 + 投递表 + 进度表，后端代码需要继续跟进改造。
5. 新增接口时优先使用 `/api/v1` 前缀，逐步替换当前初版 `/work` 接口。

## 11. Roadmap

### V1：基础记录闭环

- [ ] 公司创建 / 查询
- [ ] 岗位投递记录创建 / 查询 / 更新
- [ ] 招聘进度节点创建 / 查询
- [ ] 待跟进列表
- [ ] 基础状态统计

### V2：投递策略分析

- [ ] 渠道转化率统计
- [ ] 公司维度统计
- [ ] 岗位类型统计
- [ ] 简历版本与投递结果关联

### V3：AI 辅助

- [ ] 岗位关键词提取
- [ ] 公司信息半自动补全
- [ ] 简历优化建议
- [ ] 求职周报生成

## 12. 简历描述参考

> 基于 Go + Gin + GORM + MySQL 实现个人求职投递管理系统，支持公司信息管理、岗位投递记录、招聘进度时间线、待跟进提醒和渠道转化统计。通过结构化数据沉淀求职过程，辅助分析投递策略和简历优化方向。

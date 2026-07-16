.DEFAULT_GOAL := help

# ---------------------------------------------------------------------------
# 环境变量：自动加载 .env（如果存在）
# ---------------------------------------------------------------------------
-include .env

# ---------------------------------------------------------------------------
# 工具与变量
# ---------------------------------------------------------------------------
GOOSE        ?= goose
GOLANGCI_LINT ?= golangci-lint

MIGRATIONS_DIR ?= migrations
DB_HOST        ?= 127.0.0.1
DB_PORT        ?= 3306
DB_USER        ?= root
DB_NAME        ?= go_resumes_record
MIGRATION_DSN  ?= $(DB_USER):$(MYSQL_PASSWORD)@tcp($(DB_HOST):$(DB_PORT))/$(DB_NAME)?parseTime=true

# ---------------------------------------------------------------------------
# Phony targets
# ---------------------------------------------------------------------------
.PHONY: help tidy run \
        lint lint-fix \
        migrate-validate migrate-status migrate-up migrate-down migrate-create

# ---------------------------------------------------------------------------
# 帮助
# ---------------------------------------------------------------------------
help:
	@echo ""
	@echo "  可用命令："
	@echo ""
	@echo "  基础"
	@echo "    make run               启动本地服务"
	@echo "    make tidy              go mod tidy"
	@echo ""
	@echo "  Lint"
	@echo "    make lint              运行 golangci-lint 检查"
	@echo "    make lint-fix          运行 golangci-lint 并自动修复"
	@echo ""
	@echo "  Migration（需设置 MYSQL_PASSWORD，或在 .env 中配置）"
	@echo "    make migrate-validate  校验 migration 文件"
	@echo "    make migrate-status    查看 migration 状态"
	@echo "    make migrate-up        执行 migration"
	@echo "    make migrate-down      回滚最近一次 migration"
	@echo "    make migrate-create    创建新 migration，需传 name 参数"
	@echo "                         示例：make migrate-create name=add_index_to_companies"
	@echo ""

# ---------------------------------------------------------------------------
# 基础
# ---------------------------------------------------------------------------
tidy:
	go mod tidy

run:
	go run ./cmd

# ---------------------------------------------------------------------------
# Lint
# ---------------------------------------------------------------------------
lint:
	$(GOLANGCI_LINT) run ./...

lint-fix:
	$(GOLANGCI_LINT) run --fix ./...

# ---------------------------------------------------------------------------
# Migration
# ---------------------------------------------------------------------------
migrate-validate:
	$(GOOSE) -dir "$(MIGRATIONS_DIR)" validate

migrate-status:
	@$(GOOSE) -dir "$(MIGRATIONS_DIR)" mysql "$(MIGRATION_DSN)" status

migrate-up:
	@$(GOOSE) -dir "$(MIGRATIONS_DIR)" mysql "$(MIGRATION_DSN)" up

migrate-down:
	@$(GOOSE) -dir "$(MIGRATIONS_DIR)" mysql "$(MIGRATION_DSN)" down

migrate-create:
	@$(GOOSE) -dir "$(MIGRATIONS_DIR)" create $(name) sql

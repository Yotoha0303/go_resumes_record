# API 设计文档

## 1. 文档说明

本文档描述 `go-resumes-record` 的目标 API 设计，用于指导后续接口实现和前后端联调。

当前代码已实现的接口较少：

| 方法 | 路径 | 状态 | 说明 |
| --- | --- | --- | --- |
| GET | `/ping` | 已实现 | 健康检查 |
| POST | `/work` | 初版已实现 | 创建岗位投递记录，后续建议迁移到 `/api/v1/work-records` |

后续新增接口建议统一使用：

```text
/api/v1
```

---

## 2. 通用约定

### 2.1 Base URL

本地开发环境：

```text
http://127.0.0.1:8083
```

V1 API 前缀：

```text
/api/v1
```

### 2.2 Content-Type

请求体统一使用 JSON：

```http
Content-Type: application/json
```

### 2.3 时间格式

接口层统一使用 ISO 8601 / RFC3339 字符串：

```text
2026-07-16T15:30:00+08:00
```

数据库层使用：

```text
DATETIME(3)
```

### 2.4 分页参数

列表接口统一支持分页：

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| page | int | 1 | 页码，从 1 开始 |
| page_size | int | 20 | 每页数量，建议最大 100 |

分页响应结构：

```json
{
  "items": [],
  "page": 1,
  "page_size": 20,
  "total": 100
}
```

### 2.5 排序参数

如无特殊说明，列表接口默认按创建时间倒序：

```text
created_at desc
```

可选参数：

| 参数 | 类型 | 示例 | 说明 |
| --- | --- | --- | --- |
| sort_by | string | `created_at` | 排序字段 |
| sort_order | string | `desc` | `asc` 或 `desc` |

---

## 3. 统一响应结构

### 3.1 成功响应

```json
{
  "code": 200,
  "message": "success",
  "data": {}
}
```

### 3.2 失败响应

```json
{
  "code": 10000,
  "message": "request parameter failed"
}
```

### 3.3 字段说明

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| code | int | 业务状态码。当前成功码为 `200` |
| message | string | 响应说明 |
| data | any | 响应数据，失败时可省略或为 `null` |

### 3.4 HTTP 状态码建议

| HTTP 状态码 | 使用场景 |
| --- | --- |
| 200 | 查询成功、更新成功 |
| 201 | 创建成功 |
| 400 | 参数错误、枚举值非法 |
| 404 | 资源不存在 |
| 409 | 唯一键冲突、状态冲突 |
| 500 | 服务端内部错误 |

> 当前代码中参数错误使用了 `404`，后续建议调整为 `400`。

### 3.5 业务错误码建议

| 错误码 | 含义 |
| --- | --- |
| 200 | 成功 |
| 10000 | 请求参数错误 |
| 10001 | 资源不存在 |
| 10002 | 数据冲突 |
| 10003 | 状态流转非法 |
| 20000 | 创建投递记录失败 |
| 20001 | 查询投递记录失败 |
| 20002 | 更新投递记录失败 |
| 30000 | 创建公司失败 |
| 30001 | 查询公司失败 |
| 40000 | 创建招聘进度失败 |
| 40001 | 查询招聘进度失败 |
| 50000 | 统计查询失败 |

---

## 4. 枚举定义

### 4.1 education_background

| 值 | 含义 |
| --- | --- |
| 0 | 不限 |
| 1 | 大专 |
| 2 | 本科 |
| 3 | 硕士 |
| 4 | 博士 |

### 4.2 job_type

| 值 | 含义 |
| --- | --- |
| 1 | 直招 |
| 2 | 外包 |
| 3 | 猎头 |
| 4 | 劳务派遣 |
| 5 | 其他 |

### 4.3 source_channel

| 值 | 含义 |
| --- | --- |
| 0 | 未知 |
| 1 | BOSS直聘 |
| 2 | 猎聘 |
| 3 | 拉勾 |
| 4 | 官网 |
| 5 | 内推 |
| 6 | 微信/社群 |
| 7 | 邮件 |
| 8 | 其他 |

### 4.4 send_resume_result

| 值 | 含义 |
| --- | --- |
| 0 | 未投递 |
| 1 | 等待回复 |
| 2 | 投递成功 |
| 3 | 投递失败 |

### 4.5 final_status

| 值 | 含义 | 是否结束态 |
| --- | --- | --- |
| 0 | 暂无 | 否 |
| 1 | 流程中 | 否 |
| 2 | Offer | 是 |
| 3 | 被拒 | 是 |
| 4 | 主动放弃 | 是 |
| 5 | 失联 | 是 |
| 6 | 已入职 | 是 |

### 4.6 progress_status

| 值 | 含义 |
| --- | --- |
| 0 | 简历筛选中 |
| 1 | 一面 |
| 2 | 二面 |
| 3 | HR面 |
| 4 | Offer |
| 5 | 已拒 |
| 6 | 已放弃 |
| 7 | 待跟进 |
| 8 | 其他 |

---

## 5. API 总览

| 模块 | 方法 | 路径 | 说明 | 优先级 |
| --- | --- | --- | --- | --- |
| Health | GET | `/ping` | 健康检查 | P0 |
| WorkRecord | POST | `/api/v1/work-records` | 新增岗位投递记录 | P0 |
| WorkRecord | GET | `/api/v1/work-records` | 查询岗位投递列表 | P0 |
| WorkRecord | GET | `/api/v1/work-records/{id}` | 查询岗位投递详情 | P0 |
| WorkRecord | PATCH | `/api/v1/work-records/{id}` | 更新岗位投递记录 | P1 |
| WorkRecord | PATCH | `/api/v1/work-records/{id}/status` | 更新投递/最终状态 | P0 |
| Progress | POST | `/api/v1/work-records/{id}/progress` | 新增招聘进度节点 | P0 |
| Progress | GET | `/api/v1/work-records/{id}/progress` | 查询招聘进度时间线 | P0 |
| FollowUp | GET | `/api/v1/follow-ups/due` | 查询到期跟进记录 | P0 |
| Company | POST | `/api/v1/companies` | 新增公司 | P1 |
| Company | GET | `/api/v1/companies` | 查询公司列表 | P1 |
| Company | GET | `/api/v1/companies/{id}` | 查询公司详情 | P1 |
| Statistics | GET | `/api/v1/statistics/overview` | 查询投递概览统计 | P1 |
| Statistics | GET | `/api/v1/statistics/channels` | 查询渠道转化统计 | P1 |

---

## 6. Health API

### 6.1 健康检查

```http
GET /ping
```

成功响应：

```json
{
  "code": 200,
  "message": "success"
}
```

---

## 7. 岗位投递记录 API

### 7.1 新增岗位投递记录

```http
POST /api/v1/work-records
```

#### 请求体

```json
{
  "company": {
    "company_id": 0,
    "company_name": "广州示例科技有限公司",
    "company_short_name": "示例科技",
    "industry": "互联网",
    "company_size": "100-500人",
    "company_address": "广州天河"
  },
  "job_name": "Go 后端开发工程师",
  "job_information": "负责订单系统、库存系统、接口开发和性能优化",
  "work_experience": "1-3年",
  "education_background": 2,
  "workplace": "广州天河",
  "job_type": 1,
  "job_url": "https://example.com/jobs/123",
  "source_channel": 1,
  "source_channel_remark": "BOSS直聘主动沟通",
  "contact_name": "张 HR",
  "contact_method": "微信：example_hr",
  "promise_note": "3 天内反馈",
  "send_resume_time": "2026-07-16T15:30:00+08:00",
  "next_follow_up_time": "2026-07-19T10:00:00+08:00",
  "send_resume_result": 1,
  "remark": "岗位要求 Go、MySQL、Redis"
}
```

#### 字段规则

| 字段 | 必填 | 说明 |
| --- | --- | --- |
| company.company_id | 否 | 已存在公司 ID。传入时优先使用该公司 |
| company.company_name | 条件必填 | 当 `company_id` 为空或为 0 时必填 |
| job_name | 是 | 岗位名称 |
| education_background | 否 | 默认 0 |
| workplace | 否 | 工作地点 |
| job_type | 否 | 默认 1 |
| source_channel | 否 | 默认 0 |
| send_resume_result | 否 | 默认 0 |

#### 业务规则

1. 如果传入 `company_id`，系统校验公司是否存在。
2. 如果未传 `company_id`，系统根据 `company_name` 查找公司。
3. 如果公司不存在，先创建 `companies`，再创建 `work_info_records`。
4. 如果传入 `send_resume_time`，`send_resume_result` 建议设置为 `1` 或 `2`。

#### 成功响应

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1001,
    "company_id": 2001
  }
}
```

#### 当前初版接口兼容说明

当前代码已实现的创建接口为：

```http
POST /work
```

当前请求体：

```json
{
  "job_name": "Go 后端开发工程师",
  "company_name": "示例科技有限公司",
  "education_background": 2,
  "work_place": "广州天河"
}
```

后续建议将 `/work` 迁移到 `/api/v1/work-records`，并兼容新的 `company_id` 表结构。

---

### 7.2 查询岗位投递列表

```http
GET /api/v1/work-records
```

#### Query 参数

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| page | int | 否 | 页码，默认 1 |
| page_size | int | 否 | 每页数量，默认 20 |
| keyword | string | 否 | 搜索岗位名、公司名、岗位摘要 |
| company_id | int64 | 否 | 公司 ID |
| source_channel | int | 否 | 投递渠道 |
| send_resume_result | int | 否 | 投递结果 |
| final_status | int | 否 | 最终状态 |
| job_type | int | 否 | 岗位类型 |
| start_time | string | 否 | 创建时间起点 |
| end_time | string | 否 | 创建时间终点 |
| need_follow_up | bool | 否 | 是否只查需要跟进的记录 |

#### 示例

```http
GET /api/v1/work-records?page=1&page_size=20&send_resume_result=1&source_channel=1
```

#### 成功响应

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      {
        "id": 1001,
        "job_name": "Go 后端开发工程师",
        "company_id": 2001,
        "company_name": "广州示例科技有限公司",
        "workplace": "广州天河",
        "source_channel": 1,
        "send_resume_result": 1,
        "final_status": 0,
        "next_follow_up_time": "2026-07-19T10:00:00+08:00",
        "created_at": "2026-07-16T15:30:00+08:00"
      }
    ],
    "page": 1,
    "page_size": 20,
    "total": 1
  }
}
```

---

### 7.3 查询岗位投递详情

```http
GET /api/v1/work-records/{id}
```

#### 成功响应

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1001,
    "job_name": "Go 后端开发工程师",
    "job_information": "负责订单系统、库存系统、接口开发和性能优化",
    "work_experience": "1-3年",
    "education_background": 2,
    "workplace": "广州天河",
    "job_type": 1,
    "job_url": "https://example.com/jobs/123",
    "source_channel": 1,
    "contact_name": "张 HR",
    "contact_method": "微信：example_hr",
    "send_resume_result": 1,
    "final_status": 0,
    "next_follow_up_time": "2026-07-19T10:00:00+08:00",
    "company": {
      "id": 2001,
      "company_name": "广州示例科技有限公司",
      "company_short_name": "示例科技",
      "industry": "互联网",
      "company_size": "100-500人",
      "company_address": "广州天河"
    },
    "progress_records": [
      {
        "id": 3001,
        "progress_status": 7,
        "event_time": "2026-07-17T10:00:00+08:00",
        "content": "HR 表示本周内反馈",
        "next_action": "7月19日追问结果"
      }
    ]
  }
}
```

#### 失败响应

```json
{
  "code": 10001,
  "message": "work record not found"
}
```

---

### 7.4 更新岗位投递记录

```http
PATCH /api/v1/work-records/{id}
```

#### 请求体

只传需要修改的字段：

```json
{
  "job_information": "补充：要求熟悉 Docker、Redis、消息队列",
  "job_url": "https://example.com/jobs/456",
  "contact_name": "李 HR",
  "contact_method": "邮箱：hr@example.com",
  "promise_note": "下周一前反馈",
  "next_follow_up_time": "2026-07-20T10:00:00+08:00",
  "remark": "岗位更偏业务系统开发"
}
```

#### 成功响应

```json
{
  "code": 200,
  "message": "success"
}
```

---

### 7.5 更新投递/最终状态

```http
PATCH /api/v1/work-records/{id}/status
```

#### 请求体

```json
{
  "send_resume_result": 2,
  "final_status": 1,
  "final_result": "已进入一面流程",
  "next_follow_up_time": "2026-07-20T10:00:00+08:00"
}
```

#### 业务规则

- `send_resume_result` 和 `final_status` 至少传一个。
- 如果 `final_status` 是结束态，可以清空或忽略 `next_follow_up_time`。
- 如果从结束态改回流程中，需要记录操作原因，后续可通过进度节点沉淀。

#### 成功响应

```json
{
  "code": 200,
  "message": "success"
}
```

---

## 8. 招聘进度 API

### 8.1 新增招聘进度节点

```http
POST /api/v1/work-records/{id}/progress
```

#### 请求体

```json
{
  "progress_status": 1,
  "event_time": "2026-07-20T15:00:00+08:00",
  "contact_name": "张 HR",
  "contact_method": "微信",
  "content": "一面，主要问 Go 并发、MySQL 索引、项目部署",
  "next_action": "等待二面通知",
  "next_follow_up_time": "2026-07-23T10:00:00+08:00",
  "sync_work_record_status": true,
  "work_record_status_patch": {
    "send_resume_result": 2,
    "final_status": 1
  }
}
```

#### 字段说明

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| progress_status | int | 是 | 招聘进度节点 |
| event_time | string | 否 | 不传则使用当前时间 |
| content | string | 否 | 沟通内容或反馈 |
| next_action | string | 否 | 下一步动作 |
| next_follow_up_time | string | 否 | 下一次跟进时间 |
| sync_work_record_status | bool | 否 | 是否同步更新主表状态 |
| work_record_status_patch | object | 否 | 主表状态更新内容 |

#### 成功响应

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 3001
  }
}
```

---

### 8.2 查询招聘进度时间线

```http
GET /api/v1/work-records/{id}/progress
```

#### Query 参数

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| page | int | 否 | 页码 |
| page_size | int | 否 | 每页数量 |
| progress_status | int | 否 | 按节点筛选 |

#### 成功响应

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      {
        "id": 3001,
        "work_info_record_id": 1001,
        "progress_status": 1,
        "event_time": "2026-07-20T15:00:00+08:00",
        "contact_name": "张 HR",
        "contact_method": "微信",
        "content": "一面，主要问 Go 并发、MySQL 索引、项目部署",
        "next_action": "等待二面通知",
        "next_follow_up_time": "2026-07-23T10:00:00+08:00"
      }
    ],
    "page": 1,
    "page_size": 20,
    "total": 1
  }
}
```

---

## 9. 跟进 API

### 9.1 查询到期跟进记录

```http
GET /api/v1/follow-ups/due
```

#### Query 参数

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| before | string | 当前时间 | 查询该时间之前需要跟进的记录 |
| page | int | 1 | 页码 |
| page_size | int | 20 | 每页数量 |

#### 查询规则

查询满足以下条件的投递记录：

```text
next_follow_up_time <= before
AND final_status NOT IN (2, 3, 4, 5, 6)
```

#### 成功响应

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      {
        "id": 1001,
        "job_name": "Go 后端开发工程师",
        "company_name": "广州示例科技有限公司",
        "contact_name": "张 HR",
        "contact_method": "微信",
        "next_follow_up_time": "2026-07-19T10:00:00+08:00",
        "promise_note": "3 天内反馈"
      }
    ],
    "page": 1,
    "page_size": 20,
    "total": 1
  }
}
```

---

## 10. 公司 API

### 10.1 新增公司

```http
POST /api/v1/companies
```

#### 请求体

```json
{
  "company_name": "广州示例科技有限公司",
  "company_short_name": "示例科技",
  "industry": "互联网",
  "company_size": "100-500人",
  "financing_stage": "未融资",
  "company_address": "广州天河",
  "official_website_url": "https://example.com",
  "recruitment_url": "https://example.com/jobs",
  "remark": "通勤可接受"
}
```

#### 成功响应

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 2001
  }
}
```

#### 冲突响应

```json
{
  "code": 10002,
  "message": "company already exists"
}
```

---

### 10.2 查询公司列表

```http
GET /api/v1/companies
```

#### Query 参数

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| page | int | 否 | 页码 |
| page_size | int | 否 | 每页数量 |
| keyword | string | 否 | 公司名/简称关键词 |
| industry | string | 否 | 行业 |
| address_keyword | string | 否 | 地址关键词 |

#### 成功响应

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      {
        "id": 2001,
        "company_name": "广州示例科技有限公司",
        "company_short_name": "示例科技",
        "industry": "互联网",
        "company_size": "100-500人",
        "company_address": "广州天河"
      }
    ],
    "page": 1,
    "page_size": 20,
    "total": 1
  }
}
```

---

### 10.3 查询公司详情

```http
GET /api/v1/companies/{id}
```

#### 成功响应

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 2001,
    "company_name": "广州示例科技有限公司",
    "company_short_name": "示例科技",
    "industry": "互联网",
    "company_size": "100-500人",
    "financing_stage": "未融资",
    "company_address": "广州天河",
    "official_website_url": "https://example.com",
    "recruitment_url": "https://example.com/jobs",
    "remark": "通勤可接受",
    "work_record_count": 3
  }
}
```

---

## 11. 统计 API

### 11.1 查询投递概览

```http
GET /api/v1/statistics/overview
```

#### Query 参数

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| start_time | string | 否 | 统计开始时间 |
| end_time | string | 否 | 统计结束时间 |

#### 成功响应

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total_records": 100,
    "not_sent_count": 20,
    "waiting_count": 30,
    "in_progress_count": 10,
    "offer_count": 2,
    "rejected_count": 25,
    "abandoned_count": 5,
    "lost_contact_count": 8,
    "due_follow_up_count": 6
  }
}
```

---

### 11.2 查询渠道统计

```http
GET /api/v1/statistics/channels
```

#### Query 参数

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| start_time | string | 否 | 统计开始时间 |
| end_time | string | 否 | 统计结束时间 |

#### 成功响应

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      {
        "source_channel": 1,
        "source_channel_name": "BOSS直聘",
        "total_records": 50,
        "reply_count": 20,
        "interview_count": 8,
        "offer_count": 1,
        "reply_rate": 0.4,
        "interview_rate": 0.16,
        "offer_rate": 0.02,
        "channel_label": "normal"
      }
    ]
  }
}
```

#### channel_label 建议值

| 值 | 含义 |
| --- | --- |
| high_value | 高价值渠道 |
| normal | 普通渠道 |
| low_efficiency | 低效渠道 |
| insufficient_data | 数据不足 |

---

## 12. 输入校验规则

### 12.1 创建投递记录

| 字段 | 规则 |
| --- | --- |
| job_name | 必填，长度 1-100 |
| company.company_id | 可选，大于 0 时必须存在 |
| company.company_name | 当 company_id 不存在时必填，长度 1-100 |
| job_information | 可选，最大 1024 |
| education_background | 必须在枚举范围内 |
| job_type | 必须在枚举范围内 |
| source_channel | 必须在枚举范围内 |
| contact_method | 可选，最大 100；敏感信息不要输出到日志 |

### 12.2 新增进度节点

| 字段 | 规则 |
| --- | --- |
| progress_status | 必填，必须在枚举范围内 |
| event_time | 可选，不传默认为当前时间 |
| content | 可选，建议限制最大长度，例如 5000 |
| next_follow_up_time | 可选，结束态不建议设置 |

---

## 13. 状态同步规则

新增招聘进度节点时，可以选择同步主表状态。

建议规则：

| progress_status | 建议同步到 send_resume_result | 建议同步到 final_status |
| --- | --- | --- |
| 简历筛选中 | 等待回复 | 暂无 |
| 一面 | 投递成功 | 流程中 |
| 二面 | 投递成功 | 流程中 |
| HR面 | 投递成功 | 流程中 |
| Offer | 投递成功 | Offer |
| 已拒 | 投递成功 | 被拒 |
| 已放弃 | 投递成功 | 主动放弃 |
| 待跟进 | 等待回复 | 暂无或流程中 |

---

## 14. 隐私与日志要求

1. `contact_method`、手机号、邮箱、微信号等字段不应打印到日志。
2. access log 只记录路径、状态码、耗时、request_id。
3. 错误响应中不要返回原始 SQL 错误。
4. 后续接入认证后，所有 `/api/v1` 接口都应要求登录。
5. 后续接入 AI 时，默认脱敏联系人信息。

---

## 15. 实现顺序建议

### 第一阶段：接口基础闭环

1. 调整路由前缀为 `/api/v1`。
2. 实现公司查找/创建逻辑。
3. 改造创建投递记录接口，支持 `company_id`。
4. 实现投递列表查询。
5. 实现投递详情查询。

### 第二阶段：跟进闭环

1. 实现新增招聘进度节点。
2. 实现招聘进度时间线查询。
3. 实现待跟进列表。
4. 实现状态同步规则。

### 第三阶段：统计分析

1. 实现概览统计。
2. 实现渠道统计。
3. 根据统计结果标记渠道质量。

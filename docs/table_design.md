# 数据库表设计

本项目用于记录岗位投递、公司信息、沟通跟进节点和最终结果，核心目标是让求职过程可查询、可复盘、可统计。

## 0. 设计原则

1. **公司信息独立成表**：同一家公司可能有多个岗位，岗位投递记录通过 `company_id` 关联公司。
2. **投递记录只保存当前快照**：`work_info_records` 保存岗位、投递状态、下次跟进时间、最终结果等当前状态。
3. **跟进过程单独成表**：每一次沟通、面试、反馈都记录到 `recruitment_progress_records`，避免只保留最后一次结果导致无法复盘。
4. **枚举字段用 TINYINT**：便于筛选、统计和索引；展示层再转换成中文文案。
5. **时间字段统一使用 `DATETIME(3)`**：保留毫秒，和 Go `time.Time` / GORM 更容易对应。
6. **MVP 不做过度拆分**：联系人信息先冗余在投递记录和跟进记录中；后续联系人变多时再拆 `company_contacts` 表。

## 1. 公司信息表：companies

用于记录公司基础信息，减少重复录入，并支持按行业、规模、地点分析投递效果。

| 字段名 | 类型 | 是否为空 | 默认值 | 说明 |
| --- | --- | --- | --- | --- |
| id | BIGINT | NOT NULL | AUTO_INCREMENT | 主键 |
| company_name | VARCHAR(100) | NOT NULL | 无 | 公司全称，例如“广州某某科技有限公司” |
| company_short_name | VARCHAR(50) | NOT NULL | '' | 公司简称或招聘平台展示名称 |
| industry | VARCHAR(50) | NOT NULL | '' | 所属行业，例如互联网、新能源、快消、外包、人力资源等 |
| company_size | VARCHAR(50) | NOT NULL | '' | 公司规模，例如 1-50人、100-500人、1000人以上 |
| financing_stage | VARCHAR(50) | NOT NULL | '' | 融资/上市情况，例如未融资、A轮、上市、国企、事业单位 |
| company_address | VARCHAR(255) | NOT NULL | '' | 公司地址，可具体到区、商圈或办公楼 |
| official_website_url | VARCHAR(512) | NULL | NULL | 公司官网 |
| recruitment_url | VARCHAR(512) | NULL | NULL | 公司招聘主页或招聘平台主页 |
| remark | VARCHAR(512) | NULL | NULL | 备注，例如公司风险、通勤情况、业务评价 |
| created_at | DATETIME(3) | NOT NULL | CURRENT_TIMESTAMP(3) | 创建时间 |
| updated_at | DATETIME(3) | NOT NULL | CURRENT_TIMESTAMP(3) | 更新时间，数据更新时自动刷新 |

### 索引

| 索引名 | 字段 | 用途 |
| --- | --- | --- |
| PRIMARY | id | 主键查询 |
| uk_company_name | company_name | 避免公司全称重复 |
| idx_industry | industry | 按行业筛选 |
| idx_company_address | company_address | 按地区/商圈模糊筛选的辅助索引 |

### 约束

| 约束名 | 规则 |
| --- | --- |
| uk_company_name | `company_name` 唯一 |

---

## 2. 岗位投递记录表：work_info_records

用于记录岗位信息、公司关联、投递渠道、联系人、当前投递状态和最终反馈结果。

| 字段名 | 类型 | 是否为空 | 默认值 | 说明 |
| --- | --- | --- | --- | --- |
| id | BIGINT | NOT NULL | AUTO_INCREMENT | 主键 |
| company_id | BIGINT | NOT NULL | 无 | 公司 ID，关联 `companies.id` |
| job_name | VARCHAR(100) | NOT NULL | 无 | 岗位名称，例如 Go 后端开发工程师 |
| job_information | VARCHAR(1024) | NOT NULL | '' | 岗位信息/岗位描述摘要，建议只记录关键要求 |
| work_experience | VARCHAR(25) | NOT NULL | '不限' | 岗位要求的工作经验，例如不限、1-3年、3-5年 |
| education_background | TINYINT | NOT NULL | 0 | 学历要求：0-不限，1-大专，2-本科，3-硕士，4-博士 |
| workplace | VARCHAR(150) | NOT NULL | '' | 工作地点，例如广州天河、深圳南山、远程 |
| job_type | TINYINT | NOT NULL | 1 | 岗位类型：1-直招，2-外包，3-猎头，4-劳务派遣，5-其他 |
| job_url | VARCHAR(512) | NULL | NULL | 岗位链接 |
| source_channel | TINYINT | NOT NULL | 0 | 投递途径：0-未知，1-BOSS直聘，2-猎聘，3-拉勾，4-官网，5-内推，6-微信/社群，7-邮件，8-其他 |
| source_channel_remark | VARCHAR(100) | NULL | NULL | 投递途径补充说明，例如具体群名、内推人 |
| contact_name | VARCHAR(50) | NULL | NULL | 联系人/HR/猎头姓名 |
| contact_method | VARCHAR(100) | NULL | NULL | 联系方式，例如微信、电话、邮箱；注意不要公开到简历或 README |
| promise_note | VARCHAR(255) | NULL | NULL | 对方承诺，例如“本周五前反馈”“可推 Java/Go 岗” |
| send_resume_time | DATETIME(3) | NULL | NULL | 投递时间；未投递时为空 |
| next_follow_up_time | DATETIME(3) | NULL | NULL | 下次跟进时间，用于提醒 |
| send_resume_result | TINYINT | NOT NULL | 0 | 投递结果：0-未投递，1-等待回复，2-投递成功，3-投递失败 |
| final_status | TINYINT | NOT NULL | 0 | 最终状态：0-暂无，1-流程中，2-Offer，3-被拒，4-主动放弃，5-失联，6-已入职 |
| final_result | VARCHAR(255) | NULL | NULL | 最终反馈说明，例如拒绝原因、薪资范围、复盘结论 |
| remark | VARCHAR(512) | NULL | NULL | 其他备注 |
| created_at | DATETIME(3) | NOT NULL | CURRENT_TIMESTAMP(3) | 创建时间 |
| updated_at | DATETIME(3) | NOT NULL | CURRENT_TIMESTAMP(3) | 更新时间，数据更新时自动刷新 |

### 索引

| 索引名 | 字段 | 用途 |
| --- | --- | --- |
| PRIMARY | id | 主键查询 |
| idx_company_id | company_id | 查询某公司的所有投递记录 |
| idx_send_resume_result_created_at | send_resume_result, created_at | 按投递状态筛选，并按创建时间排序 |
| idx_final_status_updated_at | final_status, updated_at | 按最终状态筛选，并按更新时间排序 |
| idx_next_follow_up_time | next_follow_up_time | 查询需要跟进的记录 |
| idx_source_channel_created_at | source_channel, created_at | 统计不同投递渠道效果 |

### 约束

| 约束名 | 规则 |
| --- | --- |
| fk_work_info_records_company_id | `company_id` 关联 `companies.id` |
| chk_education_background | `education_background` 只能是 0、1、2、3、4 |
| chk_job_type | `job_type` 只能是 1、2、3、4、5 |
| chk_source_channel | `source_channel` 只能是 0、1、2、3、4、5、6、7、8 |
| chk_send_resume_result | `send_resume_result` 只能是 0、1、2、3 |
| chk_final_status | `final_status` 只能是 0、1、2、3、4、5、6 |

### 设计说明

- `company_id` 是主关联字段，后续不建议继续只存 `company_name`。
- `final_status` 用于统计，`final_result` 用于记录具体文字反馈，两者不要混用。
- `next_follow_up_time` 放在主表，方便快速查询“今天需要跟进哪些岗位”。
- 如果一个岗位有多次沟通记录，应写入 `recruitment_progress_records`，不要只覆盖主表备注。

---

## 3. 招聘进度与跟进节点表：recruitment_progress_records

用于记录每一次沟通、面试、反馈、跟进行为。它是投递记录的过程明细表。

| 字段名 | 类型 | 是否为空 | 默认值 | 说明 |
| --- | --- | --- | --- | --- |
| id | BIGINT | NOT NULL | AUTO_INCREMENT | 主键 |
| work_info_record_id | BIGINT | NOT NULL | 无 | 投递记录 ID，关联 `work_info_records.id` |
| progress_status | TINYINT | NOT NULL | 0 | 当前节点：0-简历筛选中，1-一面，2-二面，3-HR面，4-Offer，5-已拒，6-已放弃，7-待跟进，8-其他 |
| event_time | DATETIME(3) | NOT NULL | CURRENT_TIMESTAMP(3) | 节点发生时间，例如面试时间、沟通时间、反馈时间 |
| contact_name | VARCHAR(50) | NULL | NULL | 本次沟通联系人 |
| contact_method | VARCHAR(100) | NULL | NULL | 本次沟通方式，例如微信、电话、邮箱、平台 IM |
| content | TEXT | NULL | NULL | 沟通内容、面试反馈、拒绝原因、薪资信息等 |
| next_action | VARCHAR(255) | NULL | NULL | 下一步动作，例如“7月18日追问结果”“补发项目链接” |
| next_follow_up_time | DATETIME(3) | NULL | NULL | 该节点产生的下次跟进时间 |
| created_at | DATETIME(3) | NOT NULL | CURRENT_TIMESTAMP(3) | 创建时间 |
| updated_at | DATETIME(3) | NOT NULL | CURRENT_TIMESTAMP(3) | 更新时间，数据更新时自动刷新 |

### 索引

| 索引名 | 字段 | 用途 |
| --- | --- | --- |
| PRIMARY | id | 主键查询 |
| idx_work_info_record_id_event_time | work_info_record_id, event_time | 查询某条投递记录的完整时间线 |
| idx_progress_status_event_time | progress_status, event_time | 按招聘节点筛选和统计 |
| idx_next_follow_up_time | next_follow_up_time | 查询需要跟进的节点 |

### 约束

| 约束名 | 规则 |
| --- | --- |
| fk_recruitment_progress_work_info_record_id | `work_info_record_id` 关联 `work_info_records.id` |
| chk_progress_status | `progress_status` 只能是 0、1、2、3、4、5、6、7、8 |

### 设计说明

- 主表 `work_info_records` 只保存当前状态；本表保存历史过程。
- 创建新的进度节点时，可以同步更新主表的 `final_status`、`send_resume_result`、`next_follow_up_time`。
- `content` 可能包含隐私信息，不建议在日志、接口错误信息或公开文档中直接输出。

---

## 4. 枚举定义汇总

### 4.1 education_background：学历要求

| 值 | 含义 |
| --- | --- |
| 0 | 不限 |
| 1 | 大专 |
| 2 | 本科 |
| 3 | 硕士 |
| 4 | 博士 |

### 4.2 job_type：岗位类型

| 值 | 含义 |
| --- | --- |
| 1 | 直招 |
| 2 | 外包 |
| 3 | 猎头 |
| 4 | 劳务派遣 |
| 5 | 其他 |

### 4.3 source_channel：投递途径

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

### 4.4 send_resume_result：投递结果

| 值 | 含义 |
| --- | --- |
| 0 | 未投递 |
| 1 | 等待回复 |
| 2 | 投递成功 |
| 3 | 投递失败 |

### 4.5 final_status：最终状态

| 值 | 含义 |
| --- | --- |
| 0 | 暂无 |
| 1 | 流程中 |
| 2 | Offer |
| 3 | 被拒 |
| 4 | 主动放弃 |
| 5 | 失联 |
| 6 | 已入职 |

### 4.6 progress_status：招聘进度节点

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

## 5. 表关系

```text
companies 1 ─── N work_info_records 1 ─── N recruitment_progress_records
```

- 一个公司可以对应多个岗位投递记录。
- 一个岗位投递记录可以对应多条招聘进度/沟通节点。
- 创建投递记录时：如果公司不存在，先创建 `companies`，再创建 `work_info_records`。
- 创建跟进节点时：写入 `recruitment_progress_records`，必要时同步更新 `work_info_records` 的当前状态。

---

## 6. 建议建表 SQL

> 说明：当前项目已有 `work_info_records` 的初版迁移。下面 SQL 是目标设计，可按后续 migration 分步演进，不建议直接覆盖线上表。

```sql
CREATE TABLE IF NOT EXISTS companies (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    company_short_name VARCHAR(50) NOT NULL DEFAULT '',
    industry VARCHAR(50) NOT NULL DEFAULT '',
    company_size VARCHAR(50) NOT NULL DEFAULT '',
    financing_stage VARCHAR(50) NOT NULL DEFAULT '',
    company_address VARCHAR(255) NOT NULL DEFAULT '',
    official_website_url VARCHAR(512) NULL DEFAULT NULL,
    recruitment_url VARCHAR(512) NULL DEFAULT NULL,
    remark VARCHAR(512) NULL DEFAULT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    UNIQUE KEY uk_company_name (company_name),
    KEY idx_industry (industry),
    KEY idx_company_address (company_address)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS work_info_records (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT NOT NULL,
    job_name VARCHAR(100) NOT NULL,
    job_information VARCHAR(1024) NOT NULL DEFAULT '',
    work_experience VARCHAR(25) NOT NULL DEFAULT '不限',
    education_background TINYINT NOT NULL DEFAULT 0,
    workplace VARCHAR(150) NOT NULL DEFAULT '',
    job_type TINYINT NOT NULL DEFAULT 1,
    job_url VARCHAR(512) NULL DEFAULT NULL,
    source_channel TINYINT NOT NULL DEFAULT 0,
    source_channel_remark VARCHAR(100) NULL DEFAULT NULL,
    contact_name VARCHAR(50) NULL DEFAULT NULL,
    contact_method VARCHAR(100) NULL DEFAULT NULL,
    promise_note VARCHAR(255) NULL DEFAULT NULL,
    send_resume_time DATETIME(3) NULL DEFAULT NULL,
    next_follow_up_time DATETIME(3) NULL DEFAULT NULL,
    send_resume_result TINYINT NOT NULL DEFAULT 0,
    final_status TINYINT NOT NULL DEFAULT 0,
    final_result VARCHAR(255) NULL DEFAULT NULL,
    remark VARCHAR(512) NULL DEFAULT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    KEY idx_company_id (company_id),
    KEY idx_send_resume_result_created_at (send_resume_result, created_at),
    KEY idx_final_status_updated_at (final_status, updated_at),
    KEY idx_next_follow_up_time (next_follow_up_time),
    KEY idx_source_channel_created_at (source_channel, created_at),
    CONSTRAINT fk_work_info_records_company_id FOREIGN KEY (company_id) REFERENCES companies (id),
    CONSTRAINT chk_education_background CHECK (education_background IN (0, 1, 2, 3, 4)),
    CONSTRAINT chk_job_type CHECK (job_type IN (1, 2, 3, 4, 5)),
    CONSTRAINT chk_source_channel CHECK (source_channel IN (0, 1, 2, 3, 4, 5, 6, 7, 8)),
    CONSTRAINT chk_send_resume_result CHECK (send_resume_result IN (0, 1, 2, 3)),
    CONSTRAINT chk_final_status CHECK (final_status IN (0, 1, 2, 3, 4, 5, 6))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS recruitment_progress_records (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    work_info_record_id BIGINT NOT NULL,
    progress_status TINYINT NOT NULL DEFAULT 0,
    event_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    contact_name VARCHAR(50) NULL DEFAULT NULL,
    contact_method VARCHAR(100) NULL DEFAULT NULL,
    content TEXT NULL,
    next_action VARCHAR(255) NULL DEFAULT NULL,
    next_follow_up_time DATETIME(3) NULL DEFAULT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    KEY idx_work_info_record_id_event_time (work_info_record_id, event_time),
    KEY idx_progress_status_event_time (progress_status, event_time),
    KEY idx_next_follow_up_time (next_follow_up_time),
    CONSTRAINT fk_recruitment_progress_work_info_record_id FOREIGN KEY (work_info_record_id) REFERENCES work_info_records (id),
    CONSTRAINT chk_progress_status CHECK (progress_status IN (0, 1, 2, 3, 4, 5, 6, 7, 8))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;
```

---

## 7. 后续迁移建议

当前 migration 中 `work_info_records` 已存在 `company_name` 字段。建议按以下步骤演进，避免一次性大改导致接口和数据同时失效。

1. 新增 `companies` 表。
2. 从已有 `work_info_records.company_name` 去重生成公司数据。
3. 给 `work_info_records` 增加 `company_id`、`job_url`、`source_channel`、`contact_name`、`contact_method`、`promise_note`、`next_follow_up_time`、`final_status`、`remark` 等字段。
4. 根据原 `company_name` 回填 `company_id`。
5. 后端请求结构从 `company_name` 改为优先使用 `company_id`；创建时支持“公司不存在则先创建公司”。
6. 新增 `recruitment_progress_records` 表和对应接口。
7. 确认数据稳定后，再决定是否删除 `company_name`，或者保留为 `company_name_snapshot` 用于历史展示。

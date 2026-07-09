## 岗位投递记录表：work_info_records

用于记录岗位信息、公司信息、简历投递状态和最终反馈结果。

| 字段名 | 类型 | 是否为空 | 默认值 | 说明 |
| --- | --- | --- | --- | --- |
| id | BIGINT | NOT NULL | AUTO_INCREMENT | 主键 |
| job_name | VARCHAR(100) | NOT NULL | 无 | 岗位名称 |
| job_information | VARCHAR(512) | NOT NULL | '' | 岗位信息/岗位描述摘要 |
| work_experience | VARCHAR(25) | NOT NULL | '不限' | 岗位要求的工作经验 |
| company_name | VARCHAR(50) | NOT NULL | 无 | 公司名称 |
| education_background | TINYINT | NOT NULL | 0 | 学历要求：0-不限，1-大专，2-本科，3-研究生，4-博士 |
| workplace | VARCHAR(150) | NOT NULL | '' | 工作地点 |
| job_type | TINYINT | NOT NULL | 1 | 岗位类型：1-直招，2-外包，3-其他 |
| send_resume_time | DATETIME(3) | NULL | NULL | 投递时间；未投递时为空 |
| send_resume_result | TINYINT | NOT NULL | 0 | 投递结果：0-未投递，1-等待回复，2-投递成功，3-投递失败 |
| final_result | VARCHAR(255) | NULL | NULL | 最终反馈结果 |
| created_at | DATETIME(3) | NOT NULL | CURRENT_TIMESTAMP(3) | 创建时间 |
| updated_at | DATETIME(3) | NOT NULL | CURRENT_TIMESTAMP(3) | 更新时间，数据更新时自动刷新 |

### 索引

| 索引名 | 字段 | 用途 |
| --- | --- | --- |
| PRIMARY | id | 主键查询 |
| idx_send_resume_result_created_at | send_resume_result, created_at | 按投递状态筛选，并按创建时间排序 |

### 约束

| 约束名 | 规则 |
| --- | --- |
| chk_education_background | education_background 只能是 0、1、2、3、4 |
| chk_job_type | job_type 只能是 1、2、3 |
| chk_send_resume_result | send_resume_result 只能是 0、1、2、3 |
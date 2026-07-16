-- +goose Up
-- 1. Create company master table.
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

-- 2. Backfill companies from existing work_info_records.company_name.
INSERT INTO companies (company_name)
SELECT DISTINCT company_name
FROM work_info_records;

-- 3. Evolve work_info_records to match the table design.
ALTER TABLE work_info_records
    ADD COLUMN company_id BIGINT NULL AFTER id,
    MODIFY COLUMN job_information VARCHAR(1024) NOT NULL DEFAULT '',
    ADD COLUMN job_url VARCHAR(512) NULL DEFAULT NULL AFTER job_type,
    ADD COLUMN source_channel TINYINT NOT NULL DEFAULT 0 AFTER job_url,
    ADD COLUMN source_channel_remark VARCHAR(100) NULL DEFAULT NULL AFTER source_channel,
    ADD COLUMN contact_name VARCHAR(50) NULL DEFAULT NULL AFTER source_channel_remark,
    ADD COLUMN contact_method VARCHAR(100) NULL DEFAULT NULL AFTER contact_name,
    ADD COLUMN promise_note VARCHAR(255) NULL DEFAULT NULL AFTER contact_method,
    ADD COLUMN next_follow_up_time DATETIME(3) NULL DEFAULT NULL AFTER send_resume_time,
    ADD COLUMN final_status TINYINT NOT NULL DEFAULT 0 AFTER send_resume_result,
    ADD COLUMN remark VARCHAR(512) NULL DEFAULT NULL AFTER final_result;

UPDATE work_info_records AS w
INNER JOIN companies AS c ON c.company_name = w.company_name
SET w.company_id = c.id
WHERE w.company_id IS NULL;

ALTER TABLE work_info_records
    MODIFY COLUMN company_id BIGINT NOT NULL,
    ADD KEY idx_company_id (company_id),
    ADD KEY idx_final_status_updated_at (final_status, updated_at),
    ADD KEY idx_next_follow_up_time (next_follow_up_time),
    ADD KEY idx_source_channel_created_at (source_channel, created_at),
    ADD CONSTRAINT fk_work_info_records_company_id FOREIGN KEY (company_id) REFERENCES companies (id),
    ADD CONSTRAINT chk_source_channel CHECK (source_channel IN (0, 1, 2, 3, 4, 5, 6, 7, 8)),
    ADD CONSTRAINT chk_final_status CHECK (final_status IN (0, 1, 2, 3, 4, 5, 6));

ALTER TABLE work_info_records
    DROP CHECK chk_job_type;

ALTER TABLE work_info_records
    ADD CONSTRAINT chk_job_type CHECK (job_type IN (1, 2, 3, 4, 5));

-- 4. Create recruitment progress timeline table.
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

-- +goose Down
DROP TABLE IF EXISTS recruitment_progress_records;

ALTER TABLE work_info_records
    DROP FOREIGN KEY fk_work_info_records_company_id;

ALTER TABLE work_info_records
    DROP CHECK chk_final_status;

ALTER TABLE work_info_records
    DROP CHECK chk_source_channel;

ALTER TABLE work_info_records
    DROP CHECK chk_job_type;

ALTER TABLE work_info_records
    ADD CONSTRAINT chk_job_type CHECK (job_type IN (1, 2, 3));

ALTER TABLE work_info_records
    DROP INDEX idx_source_channel_created_at,
    DROP INDEX idx_next_follow_up_time,
    DROP INDEX idx_final_status_updated_at,
    DROP INDEX idx_company_id;

ALTER TABLE work_info_records
    DROP COLUMN remark,
    DROP COLUMN final_status,
    DROP COLUMN next_follow_up_time,
    DROP COLUMN promise_note,
    DROP COLUMN contact_method,
    DROP COLUMN contact_name,
    DROP COLUMN source_channel_remark,
    DROP COLUMN source_channel,
    DROP COLUMN job_url,
    DROP COLUMN company_id,
    MODIFY COLUMN job_information VARCHAR(512) NOT NULL DEFAULT '';

DROP TABLE IF EXISTS companies;

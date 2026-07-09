-- +goose Up
CREATE TABLE IF NOT EXISTS work_info_records (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    job_name VARCHAR(100) NOT NULL,
    job_information VARCHAR(512) NOT NULL DEFAULT '',
    work_experience VARCHAR(25) NOT NULL DEFAULT '不限',
    company_name VARCHAR(50) NOT NULL,
    education_background TINYINT NOT NULL DEFAULT 0,
    workplace VARCHAR(150) NOT NULL DEFAULT '',
    job_type TINYINT NOT NULL DEFAULT 1,
    send_resume_time DATETIME(3) NULL DEFAULT NULL,
    send_resume_result TINYINT NOT NULL DEFAULT 0,
    final_result VARCHAR(255) NULL DEFAULT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    KEY idx_send_resume_result_created_at (send_resume_result, created_at),
    CONSTRAINT chk_education_background CHECK (
        education_background IN (0, 1, 2, 3, 4)
    ),
    CONSTRAINT chk_job_type CHECK (job_type IN (1, 2, 3)),
    CONSTRAINT chk_send_resume_result CHECK (
        send_resume_result IN (0, 1, 2, 3)
    )
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

-- +goose Down
DROP TABLE IF EXISTS work_info_records;

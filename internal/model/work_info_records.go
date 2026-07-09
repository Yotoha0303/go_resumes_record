package model

import "time"

type EducationBackground int8

const (
	EducationBackgroundUnlimited EducationBackground = iota
	EducationBackgroundJuniorCollege
	EducationBackgroundBachelor
	EducationBackgroundMaster
	EducationBackgroundDoctor
)

type JobType int8

const (
	JobTypeDirect JobType = iota + 1
	JobTypeOutsourcing
	JobTypeOther
)

type SendResumeResult int8

const (
	SendResumeResultNotSent SendResumeResult = iota
	SendResumeResultWaiting
	SendResumeResultSuccess
	SendResumeResultFailed
)

type WorkInfoRecord struct {
	ID                  int64               `gorm:"column:id;type:bigint;not null;autoIncrement;primaryKey" json:"id"`
	JobName             string              `gorm:"column:job_name;type:varchar(100);not null" json:"job_name"`
	JobInformation      string              `gorm:"column:job_information;type:varchar(512);not null;default:''" json:"job_information"`
	WorkExperience      string              `gorm:"column:work_experience;type:varchar(25);not null;default:'不限'" json:"work_experience"`
	CompanyName         string              `gorm:"column:company_name;type:varchar(50);not null" json:"company_name"`
	EducationBackground EducationBackground `gorm:"column:education_background;type:tinyint;not null;default:0" json:"education_background"`
	Workplace           string              `gorm:"column:workplace;type:varchar(150);not null;default:''" json:"workplace"`
	JobType             JobType             `gorm:"column:job_type;type:tinyint;not null;default:1" json:"job_type"`
	SendResumeTime      *time.Time          `gorm:"column:send_resume_time;type:datetime(3)" json:"send_resume_time,omitempty"`
	SendResumeResult    SendResumeResult    `gorm:"column:send_resume_result;type:tinyint;not null;default:0;index:idx_send_resume_result_created_at,priority:1" json:"send_resume_result"`
	FinalResult         *string             `gorm:"column:final_result;type:varchar(255)" json:"final_result,omitempty"`
	CreatedAt           time.Time           `gorm:"column:created_at;type:datetime(3);not null;autoCreateTime:milli;index:idx_send_resume_result_created_at,priority:2" json:"created_at"`
	UpdatedAt           time.Time           `gorm:"column:updated_at;type:datetime(3);not null;autoUpdateTime:milli" json:"updated_at"`
}

func (WorkInfoRecord) TableName() string {
	return "work_info_records"
}

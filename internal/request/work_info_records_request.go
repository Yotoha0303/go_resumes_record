package request

type CreateWorkInfoRecordRequest struct {
	JobName             string `json:"job_name" binding:"required"`
	CompanyName         string `json:"company_name" binding:"required"`
	EducationBackground int8   `json:"education_background" binding:"required"`
	Workplace           string `json:"work_place" binding:"required"`
}

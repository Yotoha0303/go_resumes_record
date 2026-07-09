package main

import (
	"go-resumes-record/internal/app"
	"log"
)

func main() {
	if err := app.Run(); err != nil {
		log.Fatalf("app start failed:%v", err)
	}
}

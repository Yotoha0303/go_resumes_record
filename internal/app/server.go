package app

import (
	"fmt"
	"net/http"
)

func NewHTTPServer(deps *Deps) *http.Server {
	port := deps.Config.Server.Port

	return &http.Server{
		Addr:    fmt.Sprintf(":%d", port),
		Handler: deps.HTTPHandler,
	}
}

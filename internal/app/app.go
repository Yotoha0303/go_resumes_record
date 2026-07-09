package app

import (
	"errors"
	"log/slog"
	"net/http"
	"os"
)

func Run() error {
	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
	deps, err := InitDeps()
	if err != nil {
		return err
	}

	server := NewHTTPServer(deps)

	logger.Info("server starting", "addr", server.Addr)
	if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		return err
	}

	return nil
}

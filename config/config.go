package config

import (
	"fmt"
	"os"

	"github.com/goccy/go-yaml"
	"github.com/joho/godotenv"
)

type Config struct {
	Server ServerConfig `yaml:"server"`
	MySQL  MySQLConfig  `yaml:"mysql"`
}

type ServerConfig struct {
	Port int `yaml:"port"`
}

type MySQLConfig struct {
	User     string `yaml:"user"`
	Host     string `yaml:"host"`
	Port     int    `yaml:"port"`
	Database string `yaml:"database"`
}

func (c *Config) ValidateConfig() error {

	return nil
}

func LoadEnv() {
	_ = godotenv.Load()
}

func LoadConfig(path string) (*Config, error) {

	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read config file %s failed: %w", path, err)
	}

	var cfg Config

	err = yaml.Unmarshal(data, &cfg)
	if err != nil {
		return nil, fmt.Errorf("parse config file %s failed: %w", path, err)
	}

	if err = cfg.ValidateConfig(); err != nil {
		return nil, err
	}

	return &cfg, nil
}

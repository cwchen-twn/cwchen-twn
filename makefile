CURRENT_BRANCH := $(shell git branch --show-current)
DATE := $(shell date -u +%Y%m%d)
BUILD_DIR := /tmp/bin

.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' $(MAKEFILE_LIST) | column -t -s ':' |  sed -e 's/^/ /'

##init: Initialize the project, including go modules and uv packages
.PHONY: init
init:
	@if [ ! -f go.mod ]; then go mod init github.com/cwc1222/rigelledger; else echo "Project exists, skipping go mod init"; fi
	@go mod tidy
	@go mod verify
	@go mod download

##updatedep: Update dependencies, including go modules and uv packages
.PHONY: updatedep
updatedep:
	go get -u ./...
	go mod tidy

##updatego: Update go version (e.g. $ make updatego version=1.24.6), remember to have $(go env GOPATH) in your PATH
.PHONY: updatego
updatego:
	@if [ -z "$(version)" ]; then \
		echo "Error: Please specify a version. Usage: make updatego version=1.24.6"; \
		exit 1; \
	fi
	go install golang.org/dl/go$(version)@latest
	go$(version) download
	@echo "Go $(version) downloaded successfully in $(shell go env GOPATH)/bin/go$(version). Use 'go$(version)' to run commands with this version."
	cp $(shell go env GOPATH)/bin/go$(version) $(shell go env GOPATH)/bin/go
	@echo "You should add '$(shell go env GOPATH)/bin' to your PATH before '/usr/local/go/bin'"
	go$(version) mod edit -go=$(version)
	go$(version) mod tidy
	go$(version) mod verify
	go$(version) mod download

##upgradeable: Check for upgradeable dependencies
.PHONY: upgradeable
upgradeable:
	@go run github.com/oligot/go-mod-upgrade@latest

##tidy: Tidy go modules and format code
.PHONY: tidy
tidy:
	go mod tidy -v
	go fmt ./...

##build: Build the application for development
.PHONY: build
build:
	@mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/cwc1222 .

##run: Build and run the application
.PHONY: run
run: build
	$(BUILD_DIR)/cwc1222

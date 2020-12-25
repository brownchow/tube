.PHONY: dev setup build install image test release clean

CGO_ENABLED=0
VERSION=$(shell git describe --abbrev=0 --tags)
COMMIT=$(shell git rev-parse --short HEAD)

all: dev

dev: build
	@./tube -v

setup:
	@go get github.com/GeertJohan/go.rice/rice

build: clean
	@command -v rice > /dev/null || make setup
	@go generate $(shell go list)/...
	@go build \
		-tags "netgo static_build" -installsuffix netgo \
		-ldflags "-w -X main.Version=$(VERSION) -X main.Commit=$(COMMIT)" \
		.

install: build
	@go install

image:
	@docker build -t prologic/tube .

test: install
	@go test

release:
	@./tools/release.sh

clean:
	@git clean -f -d -X

.PHONY: build test clean release install-bats help

.DEFAULT_GOAL := help

MARIADB_VERSION ?= 10.6
IMAGE_NAME := lib-mysqludf-aes256
IMAGE_TAG := $(IMAGE_NAME):$(MARIADB_VERSION)

build: ## Build plugin image for target MariaDB version
	docker build --build-arg MARIADB_VERSION=$(MARIADB_VERSION) -t $(IMAGE_TAG) .

test: ## Build and run e2e tests (all versions)
	bats test/e2e/

release: ## Create source tarball (VERSION=x.y.z)
	@if [ -z "$(VERSION)" ]; then echo "Usage: make release VERSION=x.y.z"; exit 1; fi
	@mkdir -p dist
	tar czf dist/lib_mysqludf_aes256-$(VERSION).tar.gz \
		--transform 's,^,lib_mysqludf_aes256-$(VERSION)/,' \
		--exclude='.git' \
		--exclude='dist' \
		--exclude='include' \
		--exclude='docs/superpowers' \
		src/ configure configure.ac Makefile.in Makefile.am \
		src/Makefile.in src/Makefile.am \
		scripts/ build/ m4/ autogen acconfig.h \
		docs/ COPYING Changes README.md LICENSE Dockerfile
	@echo "Created dist/lib_mysqludf_aes256-$(VERSION).tar.gz"

clean: ## Remove build artifacts and test containers
	@docker rmi $(IMAGE_TAG) 2>/dev/null || true
	rm -rf dist/

install-bats: ## Install BATS test framework
	@command -v bats >/dev/null 2>&1 && echo "bats is already installed" || { \
		git clone https://github.com/bats-core/bats-core.git /tmp/bats-core && \
		cd /tmp/bats-core && sudo ./install.sh /usr/local && \
		rm -rf /tmp/bats-core && \
		echo "bats installed successfully"; \
	}

help: ## Show this help
	@echo "lib_mysqludf_aes256 (MARIADB_VERSION=$(MARIADB_VERSION))"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*##' $(MAKEFILE_LIST) | sed 's/:.*## /\t/' | awk -F '\t' '{printf "  make %-14s %s\n", $$1, $$2}'
	@echo ""
	@echo "Multi-version: make test MARIADB_VERSION=11.4"

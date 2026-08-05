MODULES := $(shell find module* -maxdepth 2 -name Cargo.toml 2>/dev/null | sed 's#/Cargo.toml$$##')
MODULE ?= $(firstword $(MODULES))
CARGO_MANIFEST = $(MODULE)/Cargo.toml

.PHONY: rust-version format lint test run release all

ifndef MODULES
$(error No module Cargo.toml found under module* directories)
endif

rust-version:
	@echo "Rust command-line utility versions:"
	rustc --version 			#rust compiler
	cargo --version 			#rust package manager
	rustfmt --version			#rust code formatter
	rustup --version			#rust toolchain manager
	clippy-driver --version		#rust linter

define cargo_cmd
	@for m in $(MODULES); do \
		echo "=== $$m ==="; \
		cargo $(1) --manifest-path $$m/Cargo.toml || exit 1; \
	done
endef

format:
	$(call cargo_cmd,fmt --quiet)

lint:
	$(call cargo_cmd,clippy --quiet)

test:
	$(call cargo_cmd,test --quiet)

run:
	@echo "Use MODULE=<module-dir> to run one module. Available modules: $(MODULES)"
	cargo run --manifest-path $(CARGO_MANIFEST)

release:
	$(call cargo_cmd,build --release)

all: format lint test

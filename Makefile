.PHONY: build test clean format lint help

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the project using Xcode
	xcodebuild -scheme MacAppLocker -destination 'platform=macOS' build

test: ## Run tests using Xcode (required for SwiftData macros)
	xcodebuild -scheme MacAppLocker -destination 'platform=macOS' test

clean: ## Clean build artifacts
	xcodebuild -scheme MacAppLocker clean
	rm -rf .build

format: ## Format code with SwiftFormat
	swiftformat .

lint: ## Lint code with SwiftLint
	swiftlint lint

fix: ## Auto-fix linting issues
	swiftformat .
	swiftlint --fix

run: ## Build and run the app
	xcodebuild -scheme MacAppLocker -destination 'platform=macOS' build
	open .build/Build/Products/Debug/MacAppLocker.app

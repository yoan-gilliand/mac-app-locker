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

run: ## Build and run the app (use Xcode GUI instead)
	@echo "To run the app, use Xcode:"
	@echo "  open Package.swift"
	@echo "  Then press Cmd+R"

archive: ## Build .app bundle for distribution
	xcodebuild -scheme MacAppLocker -destination 'platform=macOS' -configuration Release clean build
	@echo ""
	@echo "✅ Build complete! App location:"
	@find ~/Library/Developer/Xcode/DerivedData -name "MacAppLocker.app" -path "*/Build/Products/Release/*" 2>/dev/null | head -1
	@echo ""
	@echo "To open the build folder:"
	@echo "  open ~/Library/Developer/Xcode/DerivedData/mac-app-locker*/Build/Products/Release/"

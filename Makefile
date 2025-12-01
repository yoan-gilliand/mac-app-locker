.PHONY: build test clean format lint archive run help

## Build the application
build:
	@echo "🔨 Building MacAppLocker..."
	xcodebuild -project MacAppLocker.xcodeproj -scheme MacAppLocker -destination 'platform=macOS' build

## Run all tests
test:
	@echo "🧪 Running tests..."
	xcodebuild -project MacAppLocker.xcodeproj -scheme MacAppLocker -destination 'platform=macOS' test

## Clean build artifacts
clean:
	@echo "🧹 Cleaning..."
	xcodebuild -project MacAppLocker.xcodeproj -scheme MacAppLocker clean
	@rm -rf ~/Library/Developer/Xcode/DerivedData/MacAppLocker-*
	@echo "✅ Clean complete"

## Format code with SwiftFormat
format:
	@echo "🎨 Formatting code..."
	@if command -v swiftformat >/dev/null 2>&1; then \
		swiftformat MacAppLocker/ MacAppLockerTests/ --swiftversion 5.9; \
	else \
		echo "❌ swiftformat not installed. Run: brew install swiftformat"; \
		exit 1; \
	fi
	@if command -v swiftlint >/dev/null 2>&1; then \
		echo "🛠️  Fixing lint issues..."; \
		swiftlint --fix --quiet; \
	fi

## Lint code with SwiftLint
lint:
	@echo "🔍 Linting code..."
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint lint --strict; \
	else \
		echo "❌ swiftlint not installed. Run: brew install swiftlint"; \
		exit 1; \
	fi

## Build release version
archive:
	@echo "📦 Building release version..."
	xcodebuild -project MacAppLocker.xcodeproj \
		-scheme MacAppLocker \
		-destination 'platform=macOS' \
		-configuration Release \
		clean build
	@echo ""
	@echo "✅ Build complete! App location:"
	@find ~/Library/Developer/Xcode/DerivedData -name "MacAppLocker.app" -path "*/Build/Products/Release/*" 2>/dev/null | head -1

## Open project in Xcode
run:
	@echo "🚀 Opening in Xcode..."
	open MacAppLocker.xcodeproj
	@echo "Press Cmd+R in Xcode to run the app"

## Show available commands
help:
	@echo "MacAppLocker - Available commands:"
	@echo ""
	@echo "  make build    - Build the application"
	@echo "  make test     - Run all tests"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make format   - Format code with SwiftFormat"
	@echo "  make lint     - Lint code with SwiftLint"
	@echo "  make archive  - Build release version"
	@echo "  make run      - Open in Xcode"
	@echo "  make help     - Show this help"
	@echo ""

.DEFAULT_GOAL := help

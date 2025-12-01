#
#******************************************************************************
# @file        Makefile
# @brief       File: Makefile
# @author      Yoan Gilliand
# @editor      Yoan Gilliand
# @date        01 Dec 2025
#******************************************************************************
# @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
#******************************************************************************
# @details
# Build configuration and automation scripts.
#******************************************************************************
#
.PHONY: build test clean format lint archive run help

build:
	@echo "🔨 Building MacAppLocker..."
	xcodebuild -project MacAppLocker.xcodeproj -scheme MacAppLocker -destination 'platform=macOS' build

test:
	@echo "🧪 Running tests..."
	xcodebuild -project MacAppLocker.xcodeproj -scheme MacAppLocker -destination 'platform=macOS' test

clean:
	@echo "🧹 Cleaning..."
	xcodebuild -project MacAppLocker.xcodeproj -scheme MacAppLocker clean
	@rm -rf ~/Library/Developer/Xcode/DerivedData/MacAppLocker-*
	@echo "✅ Clean complete"

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

lint:
	@echo "🔍 Linting code..."
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint lint --strict; \
	else \
		echo "❌ swiftlint not installed. Run: brew install swiftlint"; \
		exit 1; \
	fi

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

run:
	@echo "🚀 Opening in Xcode..."
	open MacAppLocker.xcodeproj
	@echo "Press Cmd+R in Xcode to run the app"

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

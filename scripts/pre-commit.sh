#
#******************************************************************************
# @file        pre-commit.sh
# @brief       File: pre-commit.sh
# @author      Yoan Gilliand
# @editor      Yoan Gilliand
# @date        01 Dec 2025
#******************************************************************************
# @copyright   Copyright (c) 2025 Yoan Gilliand. All rights reserved.
#******************************************************************************
# @details
# Git pre-commit hook for code quality checks.
#******************************************************************************
#
echo "Pre-commit checks..."

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

if [ -f "MacAppLocker.xcodeproj/project.pbxproj" ]; then
    PROJECT_ROOT="."
elif [ -f "../MacAppLocker.xcodeproj/project.pbxproj" ]; then
    PROJECT_ROOT=".."
    cd ..
else
    echo "Error: Not in MacAppLocker project root"
    exit 1
fi

SWIFT_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.swift$')

if [ -z "$SWIFT_FILES" ]; then
    echo "No Swift files to check"
    exit 0
fi

if command -v swiftformat >/dev/null 2>&1; then
    echo "Running SwiftFormat..."
    echo "$SWIFT_FILES" | xargs swiftformat --swiftversion 5.9
    echo "$SWIFT_FILES" | xargs git add
fi

if command -v swiftlint >/dev/null 2>&1; then
    echo "Running SwiftLint..."
    echo "$SWIFT_FILES" | xargs swiftlint --fix --quiet
    echo "$SWIFT_FILES" | xargs git add
    
    echo "$SWIFT_FILES" | xargs swiftlint lint --strict --quiet
    if [ $? -ne 0 ]; then
        echo "SwiftLint failed"
        exit 1
    fi
fi

echo "Pre-commit checks passed"
exit 0

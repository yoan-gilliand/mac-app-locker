#!/bin/sh

# Install pre-commit hook
echo "Installing pre-commit hook..."

HOOK_PATH=".git/hooks/pre-commit"

cat > "$HOOK_PATH" <<EOF
#!/bin/sh

# Check for SwiftLint
if which swiftlint >/dev/null; then
  echo "Running SwiftLint..."
  swiftlint lint --strict
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi

# Check for SwiftFormat
if which swiftformat >/dev/null; then
  echo "Running SwiftFormat..."
  swiftformat . --lint
else
  echo "warning: SwiftFormat not installed, download from https://github.com/nicklockwood/SwiftFormat"
fi
EOF

chmod +x "$HOOK_PATH"
echo "Pre-commit hook installed successfully!"

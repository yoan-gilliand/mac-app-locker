#!/bin/sh

# Install pre-commit hook
echo "Installing pre-commit hook..."

HOOK_PATH=".git/hooks/pre-commit"

cat > "$HOOK_PATH" <<EOF
#!/bin/sh

# Ensure we can find homebrew binaries
export PATH="\$PATH:/opt/homebrew/bin:/usr/local/bin"

# 1. Run SwiftFormat (Auto-fix)
if which swiftformat >/dev/null; then
  echo "Running SwiftFormat (Auto-fix)..."
  swiftformat .
else
  echo "warning: SwiftFormat not installed"
fi

# 2. Run SwiftLint (Auto-fix)
if which swiftlint >/dev/null; then
  echo "Running SwiftLint (Auto-fix)..."
  swiftlint --fix
else
  echo "warning: SwiftLint not installed"
fi

# 3. Re-add modified files to the commit
# This ensures that any changes made by the formatters are included in the snapshot
git add .

# 4. Final Strict Check (Optional - can be commented out if it blocks too much)
# if which swiftlint >/dev/null; then
#   echo "Running SwiftLint (Strict Check)..."
#   swiftlint lint --strict
# fi
EOF

chmod +x "$HOOK_PATH"
echo "Pre-commit hook installed successfully!"

#!/bin/bash
#
# install-hooks.sh - Installs Git hooks for Doom Emacs configuration security
#
# This script installs the pre-commit hook to check for personal information
# in staged files before committing. It ensures the hook is executable and
# installs any required dependencies.
#

set -e

# ANSI color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BLUE}${BOLD}=== Doom Emacs Configuration Git Hooks Installer ===${NC}"
echo -e "This script will install Git hooks to prevent committing personal information"

# Ensure we're in the repository root
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: This script must be run from the repository root directory.${NC}"
    echo "Current directory: $(pwd)"
    exit 1
fi

# Create hooks directory if it doesn't exist
if [ ! -d ".git/hooks" ]; then
    echo -e "${YELLOW}Creating .git/hooks directory...${NC}"
    mkdir -p .git/hooks
fi

# Check for dependencies
echo -e "${BLUE}Checking for required dependencies...${NC}"
MISSING_DEPS=0

# Check for grep with extended regex support
if ! grep --version >/dev/null 2>&1; then
    echo -e "${RED}Missing dependency: grep${NC}"
    MISSING_DEPS=1
fi

# Check for file command
if ! file --version >/dev/null 2>&1; then
    echo -e "${RED}Missing dependency: file${NC}"
    MISSING_DEPS=1
fi

if [ $MISSING_DEPS -eq 1 ]; then
    echo -e "${RED}Please install missing dependencies and try again.${NC}"
    echo -e "On Ubuntu/Debian: sudo apt-get install grep file"
    echo -e "On macOS: brew install grep file"
    exit 1
else
    echo -e "${GREEN}All dependencies are installed.${NC}"
fi

# Install pre-commit hook
echo -e "${BLUE}Installing pre-commit hook...${NC}"

# Check if pre-commit hook already exists
if [ -f ".git/hooks/pre-commit" ]; then
    echo -e "${YELLOW}Existing pre-commit hook found.${NC}"
    echo -e "${YELLOW}Creating backup at .git/hooks/pre-commit.backup${NC}"
    cp .git/hooks/pre-commit .git/hooks/pre-commit.backup
fi

# Copy the pre-commit hook
if [ -f "pre-commit" ]; then
    cp pre-commit .git/hooks/pre-commit
elif [ -f ".git/hooks/pre-commit.sample" ]; then
    # If our pre-commit file doesn't exist but the sample does, create from scratch
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
#
# Pre-commit hook to prevent committing files with personal information
# This hook checks staged files for:
#   1. Email addresses
#   2. API keys and tokens
#   3. Common password patterns
#   4. Reminds about keeping personal info out of version control
#
# To skip this hook temporarily: git commit --no-verify

set -e

# ANSI color codes for better readability
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Checking for personal information in staged files ===${NC}"

# Get list of staged files (excluding deleted files)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=d)

# Skip if no files are staged
if [ -z "$STAGED_FILES" ]; then
    echo -e "${GREEN}No files staged for commit. Skipping checks.${NC}"
    exit 0
fi

# Initialize flags
FOUND_EMAILS=0
FOUND_TOKENS=0
FOUND_PASSWORDS=0
EXIT_CODE=0

# Check each staged file
for FILE in $STAGED_FILES; do
    # Skip binary files and files that don't exist
    if [[ ! -f "$FILE" ]] || [[ "$(file -b --mime "$FILE" | grep -c '^text/')" -eq 0 ]]; then
        continue
    fi
    
    echo -e "${BLUE}Checking: ${NC}$FILE"
    
    # Get the staged content of the file
    FILE_CONTENT=$(git show ":$FILE")
    
    # 1. Check for email addresses
    EMAIL_PATTERN='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
    EMAILS=$(echo "$FILE_CONTENT" | grep -E -o "$EMAIL_PATTERN" | sort -u)
    
    if [ -n "$EMAILS" ]; then
        echo -e "${YELLOW}⚠️  Found potential email address(es) in $FILE:${NC}"
        # Skip known safe emails like example.com
        REAL_EMAILS=$(echo "$EMAILS" | grep -v "example\.com$" | grep -v "domain\.com$")
        if [ -n "$REAL_EMAILS" ]; then
            echo "$REAL_EMAILS" | sed 's/^/    /'
            FOUND_EMAILS=1
            EXIT_CODE=1
        else
            echo -e "    ${GREEN}(Only example.com addresses, these are fine)${NC}"
        fi
    fi
    
    # 2. Check for API keys and tokens
    # Common token patterns
    TOKEN_PATTERNS=(
        # GitHub tokens
        'ghp_[a-zA-Z0-9]{36}'
        'github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59}'
        # AWS keys
        'AKIA[0-9A-Z]{16}'
        # Generic API keys (long strings that look like secrets)
        'api[_-]?key[_-]?[=:][a-zA-Z0-9_\-]{16,}'
        'api[_-]?secret[_-]?[=:][a-zA-Z0-9_\-]{16,}'
        'access[_-]?token[_-]?[=:][a-zA-Z0-9_\-]{16,}'
        # Long hex strings that might be secrets
        '[a-f0-9]{32,}'
        # Base64 strings that might be secrets
        '[a-zA-Z0-9+/]{32,}={0,2}'
    )
    
    for PATTERN in "${TOKEN_PATTERNS[@]}"; do
        TOKENS=$(echo "$FILE_CONTENT" | grep -E -o "$PATTERN" | sort -u)
        if [ -n "$TOKENS" ]; then
            echo -e "${YELLOW}⚠️  Found potential API key/token in $FILE:${NC}"
            echo "$TOKENS" | sed 's/^/    /'
            FOUND_TOKENS=1
            EXIT_CODE=1
        fi
    done
    
    # 3. Check for password patterns
    PASSWORD_PATTERNS=(
        'password[=:][^a-z]*'
        'passwd[=:][^a-z]*'
        'pass[=:][^a-z]*'
        'pwd[=:][^a-z]*'
        'secret[=:][^a-z]*'
        'credential[=:][^a-z]*'
    )
    
    for PATTERN in "${PASSWORD_PATTERNS[@]}"; do
        PASSWORDS=$(echo "$FILE_CONTENT" | grep -i -E "$PATTERN" | sort -u)
        if [ -n "$PASSWORDS" ]; then
            echo -e "${YELLOW}⚠️  Found potential password in $FILE:${NC}"
            echo "$PASSWORDS" | sed 's/^/    /'
            FOUND_PASSWORDS=1
            EXIT_CODE=1
        fi
    done
done

# Summary and reminder
echo -e "\n${BLUE}=== Personal Information Check Summary ===${NC}"

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ No personal information detected in staged files.${NC}"
else
    echo -e "${RED}⛔ Potential personal information detected:${NC}"
    [ $FOUND_EMAILS -eq 1 ] && echo -e "  ${RED}• Email addresses${NC}"
    [ $FOUND_TOKENS -eq 1 ] && echo -e "  ${RED}• API keys/tokens${NC}"
    [ $FOUND_PASSWORDS -eq 1 ] && echo -e "  ${RED}• Passwords${NC}"
    
    echo -e "\n${YELLOW}=== REMINDER ===${NC}"
    echo -e "Personal information should NOT be committed to version control!"
    echo -e "Instead:"
    echo -e "  1. Use environment variables (export USER_FULL_NAME=\"Your Name\")"
    echo -e "  2. Store in config.local.el (which is git-ignored)"
    echo -e "  3. Use auth-source with ~/.authinfo.gpg for passwords"
    echo -e "\nTo commit anyway (if these are false positives), use: git commit --no-verify"
    
    exit $EXIT_CODE
fi

echo -e "${GREEN}Commit check passed!${NC}"
exit 0
EOF
else
    echo -e "${RED}Error: Could not find pre-commit hook template.${NC}"
    echo -e "Creating a new pre-commit hook from scratch..."
    
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
#
# Pre-commit hook to prevent committing files with personal information
# This hook checks staged files for:
#   1. Email addresses
#   2. API keys and tokens
#   3. Common password patterns
#   4. Reminds about keeping personal info out of version control
#
# To skip this hook temporarily: git commit --no-verify

set -e

# ANSI color codes for better readability
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Checking for personal information in staged files ===${NC}"

# Get list of staged files (excluding deleted files)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=d)

# Skip if no files are staged
if [ -z "$STAGED_FILES" ]; then
    echo -e "${GREEN}No files staged for commit. Skipping checks.${NC}"
    exit 0
fi

# Initialize flags
FOUND_EMAILS=0
FOUND_TOKENS=0
FOUND_PASSWORDS=0
EXIT_CODE=0

# Check each staged file
for FILE in $STAGED_FILES; do
    # Skip binary files and files that don't exist
    if [[ ! -f "$FILE" ]] || [[ "$(file -b --mime "$FILE" | grep -c '^text/')" -eq 0 ]]; then
        continue
    fi
    
    echo -e "${BLUE}Checking: ${NC}$FILE"
    
    # Get the staged content of the file
    FILE_CONTENT=$(git show ":$FILE")
    
    # 1. Check for email addresses
    EMAIL_PATTERN='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
    EMAILS=$(echo "$FILE_CONTENT" | grep -E -o "$EMAIL_PATTERN" | sort -u)
    
    if [ -n "$EMAILS" ]; then
        echo -e "${YELLOW}⚠️  Found potential email address(es) in $FILE:${NC}"
        # Skip known safe emails like example.com
        REAL_EMAILS=$(echo "$EMAILS" | grep -v "example\.com$" | grep -v "domain\.com$")
        if [ -n "$REAL_EMAILS" ]; then
            echo "$REAL_EMAILS" | sed 's/^/    /'
            FOUND_EMAILS=1
            EXIT_CODE=1
        else
            echo -e "    ${GREEN}(Only example.com addresses, these are fine)${NC}"
        fi
    fi
    
    # 2. Check for API keys and tokens
    # Common token patterns
    TOKEN_PATTERNS=(
        # GitHub tokens
        'ghp_[a-zA-Z0-9]{36}'
        'github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59}'
        # AWS keys
        'AKIA[0-9A-Z]{16}'
        # Generic API keys (long strings that look like secrets)
        'api[_-]?key[_-]?[=:][a-zA-Z0-9_\-]{16,}'
        'api[_-]?secret[_-]?[=:][a-zA-Z0-9_\-]{16,}'
        'access[_-]?token[_-]?[=:][a-zA-Z0-9_\-]{16,}'
        # Long hex strings that might be secrets
        '[a-f0-9]{32,}'
        # Base64 strings that might be secrets
        '[a-zA-Z0-9+/]{32,}={0,2}'
    )
    
    for PATTERN in "${TOKEN_PATTERNS[@]}"; do
        TOKENS=$(echo "$FILE_CONTENT" | grep -E -o "$PATTERN" | sort -u)
        if [ -n "$TOKENS" ]; then
            echo -e "${YELLOW}⚠️  Found potential API key/token in $FILE:${NC}"
            echo "$TOKENS" | sed 's/^/    /'
            FOUND_TOKENS=1
            EXIT_CODE=1
        fi
    done
    
    # 3. Check for password patterns
    PASSWORD_PATTERNS=(
        'password[=:][^a-z]*'
        'passwd[=:][^a-z]*'
        'pass[=:][^a-z]*'
        'pwd[=:][^a-z]*'
        'secret[=:][^a-z]*'
        'credential[=:][^a-z]*'
    )
    
    for PATTERN in "${PASSWORD_PATTERNS[@]}"; do
        PASSWORDS=$(echo "$FILE_CONTENT" | grep -i -E "$PATTERN" | sort -u)
        if [ -n "$PASSWORDS" ]; then
            echo -e "${YELLOW}⚠️  Found potential password in $FILE:${NC}"
            echo "$PASSWORDS" | sed 's/^/    /'
            FOUND_PASSWORDS=1
            EXIT_CODE=1
        fi
    done
done

# Summary and reminder
echo -e "\n${BLUE}=== Personal Information Check Summary ===${NC}"

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ No personal information detected in staged files.${NC}"
else
    echo -e "${RED}⛔ Potential personal information detected:${NC}"
    [ $FOUND_EMAILS -eq 1 ] && echo -e "  ${RED}• Email addresses${NC}"
    [ $FOUND_TOKENS -eq 1 ] && echo -e "  ${RED}• API keys/tokens${NC}"
    [ $FOUND_PASSWORDS -eq 1 ] && echo -e "  ${RED}• Passwords${NC}"
    
    echo -e "\n${YELLOW}=== REMINDER ===${NC}"
    echo -e "Personal information should NOT be committed to version control!"
    echo -e "Instead:"
    echo -e "  1. Use environment variables (export USER_FULL_NAME=\"Your Name\")"
    echo -e "  2. Store in config.local.el (which is git-ignored)"
    echo -e "  3. Use auth-source with ~/.authinfo.gpg for passwords"
    echo -e "\nTo commit anyway (if these are false positives), use: git commit --no-verify"
    
    exit $EXIT_CODE
fi

echo -e "${GREEN}Commit check passed!${NC}"
exit 0
EOF
fi

# Make the hook executable
chmod +x .git/hooks/pre-commit
echo -e "${GREEN}✅ Pre-commit hook installed and made executable.${NC}"

# Final instructions
echo -e "\n${BLUE}${BOLD}=== Installation Complete ===${NC}"
echo -e "${GREEN}The pre-commit hook has been successfully installed.${NC}"
echo -e "It will run automatically before each commit to check for personal information."
echo -e "\n${YELLOW}To skip the hook for a specific commit (use with caution):${NC}"
echo -e "  git commit --no-verify"
echo -e "\n${BLUE}To uninstall the hook:${NC}"
echo -e "  rm .git/hooks/pre-commit"

exit 0

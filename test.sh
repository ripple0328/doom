#!/bin/bash
#
# test.sh - Doom Emacs Configuration Test Runner
#
# This script provides a convenient interface to run the Dagger pipeline
# with different options for testing the Doom Emacs configuration.
#
# It supports:
# - Lint-only mode (fast)
# - Skip dependencies mode (medium)
# - Full test mode (slow, but comprehensive)
#
# Usage: ./test.sh [options]
#

# ANSI color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Default settings
TEST_MODE="full"
VERBOSE=false

# Record start time for execution timing
start_time=$(date +%s)

# Function to display usage information
show_help() {
  echo -e "${BOLD}Doom Emacs Configuration Test Runner${NC}"
  echo
  echo -e "${BLUE}Usage:${NC} $0 [options]"
  echo
  echo -e "${BLUE}Options:${NC}"
  echo "  -h, --help      Show this help message"
  echo "  -V, --validate  Run only configuration validation (fastest)"
  echo "  -l, --lint      Run only the lint stage (fast)"
  echo "  -s, --skip-deps Skip dependency installation (medium speed)"
  echo "  -f, --full      Run the full pipeline (default, slowest but most thorough)"
  echo "  -v, --verbose   Show verbose output"
  echo
  echo -e "${BLUE}Examples:${NC}"
  echo "  $0 --validate   # Quick configuration validation"
  echo "  $0 --lint       # Quick syntax check"
  echo "  $0 --skip-deps  # Skip rebuilding Emacs"
  echo "  $0 --full       # Full test including Emacs build"
  echo
  echo -e "${YELLOW}Note:${NC} The full test can take several minutes on first run as it builds Emacs 30.1 from source."
  echo "      Subsequent runs are faster due to Docker caching."
}

# Function to display elapsed time
show_elapsed_time() {
  local end_time=$(date +%s)
  local elapsed=$((end_time - start_time))
  local minutes=$((elapsed / 60))
  local seconds=$((elapsed % 60))
  
  echo -e "\n${BLUE}────────────────────────────────────────────────────${NC}"
  if [ $elapsed -lt 60 ]; then
    echo -e "${GREEN}✓ Test completed in ${BOLD}${elapsed} seconds${NC}"
  else
    echo -e "${GREEN}✓ Test completed in ${BOLD}${minutes}m ${seconds}s${NC}"
  fi
  echo -e "${BLUE}────────────────────────────────────────────────────${NC}"
}

# Function to run validation-only mode
run_validate_only() {
  echo -e "${BLUE}Running ${BOLD}validation-only${NC} mode (fastest)${NC}"
  echo -e "${YELLOW}This mode only validates configuration structure and syntax${NC}"
  echo
  
  VALIDATE_ONLY=true npm run pipeline
  return $?
}

# Function to run lint-only mode
run_lint_only() {
  echo -e "${BLUE}Running ${BOLD}lint-only${NC} mode (fast)${NC}"
  echo -e "${YELLOW}This mode checks configuration and runs checkdoc on Emacs Lisp${NC}"
  echo
  
  LINT_ONLY=true npm run pipeline
  return $?
}

# Function to run with skipped dependencies
run_skip_deps() {
  echo -e "${BLUE}Running ${BOLD}skip-deps${NC} mode (medium speed)${NC}"
  echo -e "${YELLOW}This mode skips rebuilding Emacs but runs all test stages${NC}"
  echo
  
  SKIP_DEPS=true npm run pipeline
  return $?
}

# Function to run full test
run_full_test() {
  echo -e "${BLUE}Running ${BOLD}full${NC} test mode (most thorough)${NC}"
  echo -e "${YELLOW}This mode builds Emacs 30.1 from source and runs all tests${NC}"
  echo
  
  npm run pipeline
  return $?
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      exit 0
      ;;
    -V|--validate)
      TEST_MODE="validate"
      shift
      ;;
    -l|--lint)
      TEST_MODE="lint"
      shift
      ;;
    -s|--skip-deps)
      TEST_MODE="skip-deps"
      shift
      ;;
    -f|--full)
      TEST_MODE="full"
      shift
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    *)
      echo -e "${RED}Error: Unknown option: $1${NC}"
      echo "Use -h or --help for usage information"
      exit 1
      ;;
  esac
done

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo -e "${RED}Error: Docker is not running or not accessible${NC}"
  echo "Please start Docker and try again"
  exit 1
fi

# Check if npm is installed
if ! command -v npm > /dev/null; then
  echo -e "${RED}Error: npm is not installed${NC}"
  echo "Please install Node.js and npm, then try again"
  exit 1
fi

# Run the appropriate test mode
echo -e "${BLUE}${BOLD}=== Doom Emacs Configuration Test ===${NC}"
echo

EXIT_CODE=0
case $TEST_MODE in
  "validate")
    run_validate_only
    EXIT_CODE=$?
    ;;
  "lint")
    run_lint_only
    EXIT_CODE=$?
    ;;
  "skip-deps")
    run_skip_deps
    EXIT_CODE=$?
    ;;
  "full")
    run_full_test
    EXIT_CODE=$?
    ;;
esac

# Show elapsed time
show_elapsed_time

# Exit with the same code as the test command
if [ $EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}${BOLD}All tests passed successfully!${NC}"
else
  echo -e "${RED}${BOLD}Tests failed with exit code $EXIT_CODE${NC}"
fi

exit $EXIT_CODE

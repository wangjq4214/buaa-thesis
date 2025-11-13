#!/bin/bash

# Update version script
# Read version from typst.toml and update version numbers in README and template files

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOML_PATH="${1:-$SCRIPT_DIR/../typst.toml}"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if typst.toml file exists
if [ ! -f "$TOML_PATH" ]; then
    echo -e "${RED}Error: Cannot find $TOML_PATH file${NC}"
    exit 1
fi

# Read version from typst.toml
VERSION=$(grep -oP 'version\s*=\s*"\K[^"]+' "$TOML_PATH")

if [ -z "$VERSION" ]; then
    echo -e "${RED}Error: Cannot extract version from $TOML_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}Read version from typst.toml: $VERSION${NC}"

# Change to parent directory to access files
cd "$SCRIPT_DIR/.."

# Define files to update
declare -a FILES=(
    "README.md"
    "README-zh.md"
    "template/thesis.typ"
)

UPDATE_COUNT=0
ERROR_COUNT=0

# Update each file
for FILE in "${FILES[@]}"; do
    if [ ! -f "$FILE" ]; then
        echo -e "${YELLOW}Warning: Cannot find file $FILE, skipping${NC}"
        ((ERROR_COUNT++))
        continue
    fi

    # Check if version pattern exists in file
    if grep -q '@preview/modern-buaa-thesis:[0-9]\+\.[0-9]\+\.[0-9]\+' "$FILE"; then
        # Perform replacement (using sed)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS version of sed
            sed -i '' "s/@preview\/modern-buaa-thesis:[0-9]\+\.[0-9]\+\.[0-9]\+/@preview\/modern-buaa-thesis:$VERSION/g" "$FILE"
        else
            # Linux version of sed
            sed -i "s/@preview\/modern-buaa-thesis:[0-9]\+\.[0-9]\+\.[0-9]\+/@preview\/modern-buaa-thesis:$VERSION/g" "$FILE"
        fi

        echo -e "${CYAN}✓ Updated $FILE${NC}"
        ((UPDATE_COUNT++))
    else
        echo -e "${YELLOW}Warning: Version pattern not found in $FILE, skipping${NC}"
        ((ERROR_COUNT++))
    fi
done

# Output summary
echo -e "\n${YELLOW}========================================${NC}"
echo -e "${GREEN}Update completed!${NC}"
echo -e "${GREEN}Successfully updated: $UPDATE_COUNT file(s)${NC}"
if [ $ERROR_COUNT -gt 0 ]; then
    echo -e "${YELLOW}Skipped/Failed: $ERROR_COUNT file(s)${NC}"
fi
echo -e "${CYAN}Current version: $VERSION${NC}"
echo -e "${YELLOW}========================================${NC}"

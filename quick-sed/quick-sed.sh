#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 [options] <search> <replace> <file>"
    echo "       $0 -s <search> <file>"
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -b, --backup        Make a backup of the original file before modification"
    echo "  -o, --output-result Output the final modified file"
    echo "  -c, --compare       Show the difference between the original and modified file"
    echo "  -s, --search        Search for occurrences of a string in a file"
    echo "Examples:"
    echo "  $0 hello bye test.txt          # Replace 'hello' with 'bye' in test.txt"
    echo "  $0 -b hello bye test.txt       # Replace with backup creation"
    echo "  $0 -c hello bye test.txt       # Show differences after replacement"
    echo "  $0 -b -c -o hello bye test.txt # Backup, compare, and output final file"
    echo "  $0 -s hello test.txt           # Search for 'hello' in test.txt"
    exit 0
}

# Initialize options
backup=false
output_result=false
compare=false
search_only=false

# Parse options
while [[ "$1" =~ ^- ]]; do
    case "$1" in
        -h|--help) usage ;;
        -b|--backup) backup=true ; shift ;;
        -o|--output-result) output_result=true ; shift ;;
        -c|--compare) compare=true ; shift ;;
        -s|--search) search_only=true ; shift ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

# If -s option is used, expect only two arguments: search term and file
if [ "$search_only" = true ]; then
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 -s <search> <file>"
        exit 1
    fi
    search=$1
    target_file=$2

    if [ ! -f "$target_file" ]; then
        echo "Error: File '$target_file' not found!"
        exit 1
    fi

    matches=$(grep -n "$search" "$target_file")
    if [ -z "$matches" ]; then
        echo "No occurrences of '$search' found in '$target_file'."
    else
        echo "Occurrences of '$search' found in '$target_file':"
        echo "$matches"
    fi
    exit 0
fi

# Check if exactly three arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 [options] <search> <replace> <file>"
    exit 1
fi

# Assign arguments to variables
search=$1
replace=$2
target_file=$3

# Check if the target file exists
if [ ! -f "$target_file" ]; then
    echo "Error: File '$target_file' not found!"
    exit 1
fi

# Create a temporary backup for comparison if -c option is enabled
if [ "$compare" = true ]; then
    temp_backup=$(mktemp)
    cp "$target_file" "$temp_backup"
fi

# Make a backup if the option is enabled
if [ "$backup" = true ]; then
    cp "$target_file" "$target_file.bak"
    echo "Backup created: $target_file.bak"
fi

# Check if search string exists in the file
matches=$(grep -n "$search" "$target_file")
if [ -z "$matches" ]; then
    echo "No occurrences of '$search' found in '$target_file'."
    [ "$compare" = true ] && rm -f "$temp_backup"
    exit 1
fi

# Count occurrences
match_count=$(echo "$matches" | wc -l)
if [ "$match_count" -gt 1 ]; then
    echo "Multiple occurrences of '$search' found in '$target_file':"
    echo "$matches"
    echo "Enter the line numbers to modify (comma-separated) or 'all' to replace all:"
    read -r choice
    if [ "$choice" == "all" ]; then
        sed -i "s/${search}/${replace}/g" "$target_file"
        echo "Replaced all occurrences of '$search' with '$replace' in '$target_file'."
    else
        IFS=',' read -ra lines <<< "$choice"
        for line in "${lines[@]}"; do
            sed -i "${line}s/${search}/${replace}/" "$target_file"
        done
        echo "Replaced occurrences in selected lines of '$target_file'."
    fi
else
    sed -i "s/${search}/${replace}/" "$target_file"
    echo "Replaced occurrence of '$search' with '$replace' in '$target_file'."
fi

# Show differences if compare option is enabled
if [ "$compare" = true ]; then
    echo "Differences between original and modified file:"
    diff "$temp_backup" "$target_file"
    rm -f "$temp_backup"
fi

# Output the final file if requested
if [ "$output_result" = true ]; then
    echo "Final file content of '$target_file':"
    cat "$target_file"
fi

#!/bin/bash

# Accepts a list of arguments which are paths to files. (it is reasonable to pipe a call to find or fd or something in)
# A new dir will be made based on the date, a descriptive name is prompted for (or can be specifiied with a flag), and
# all files will be placed into such a dir in this repo so that it can be publicly shared.
# A link to the public site will be provided at the end.

# First parse arg flags leaving the rest of the args for further processing as file names if appropriate.
# -n, --name: specify the name of the directory to be created. Still gonna be behind a date dir.
# -s, --stdin: read the CONTENT as one file from stdin, while assuming it is an html document. No subdirectory is used in this case 
# and the name will specify the name of the html file.
# -h, --help: print help message and exit.

args=()
name=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--name)
      name="$2"
      echo "Name was specified: $name"
      shift 2
      ;;
    -s|--stdin)
      echo "Reading from stdin"
      # read the stdin into a variable
      content=$(cat)

      ;;
    -h|--help)
      echo "Help message lol"
      exit 0
      ;;
    *)
      args+=("$1")
      shift
      ;;
  esac
done

# debug: show the args array contents in detail
for (( i=0; i<${#args[@]}; i++ )); do
  echo "args[$i]: ${args[$i]}"
done

# For now, we always require a name...
if [ -z "$name" ]; then
  echo "Please specify a name for this one."
  exit 1
fi

# Then check if the files exist and are readable.

if [ ${#args[@]} -eq 0 ]; then
  echo "No files were specified."
  if [ -z "$content" ]; then
    echo "... and no content was provided. Nothing to do."
    exit 1
  fi
  # stdin was not already used to read content, so, assume stdin is a list of files
  # Read lines from stdin in, so in this mode each line is an arg now.
  mapfile -t args
fi

for file in "${args[@]}"; do
  if [ ! -f "$file" ]; then
    echo "File does not exist: $file"
    exit 1
  fi
  if [ ! -r "$file" ]; then
    echo "File is not readable: $file"
    exit 1
  fi
done
 
# If they are, create the dir and replicate the structure of the files in there

date=$(date +%Y-%m-%d)
dir="$date/$name"

mkdir -p "${0%/*}/$dir"

# Store the current working directory (in case?)
ORIGINAL_DIR=$(pwd)

# Change to the script directory
pushd "${0%/\*}" > /dev/null || exit 2

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "Git is not in a clean state in this static-sharing repo. Please commit or stash your changes."
    # Restore the original working directory
    popd > /dev/null || exit 2
    exit 1
fi

# insert the files

# Restore the original working directory
popd > /dev/null || exit 2


# If they are not, print an error message and exit.

# Finally, print the link to the public site.


#!/usr/bin/env bash

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

for item in "${args[@]}"; do
  if [ -n "$content" ]; then
    echo "Content was provided, so no files are expected. We will ignore them!"
    break
  fi
  if [ ! -e "$item" ]; then
    echo "File/dir does not exist: $item"
    exit 1
  else
    # if dir show the files in it
    if [ -d "$item" ]; then
      echo "Files found in dir $item:"
      find $item
    fi
  fi
  if [ ! -r "$item" ]; then
    echo "File is not readable: $item"
    exit 1
  fi
done
 
# If they are, create the dir and replicate the structure of the files in there

date=$(date +%Y-%m-%d)
dir="$date/$name"

# confirm dir doesnt already exist or bail
if [ -d "${0%/*}/$dir" ]; then
  echo "Directory already exists: $dir, bailing."
  exit 1
fi

mkdir -p "${0%/*}/$dir"

# Store the current working directory (in case?)
ORIGINAL_DIR=$(pwd)

# Check for uncommitted changes
if ! git -C "${0%/*}" diff-index --quiet HEAD --; then
    echo "Git is not in a clean state in this static-sharing repo. Please commit or stash your changes."
    # Restore the original working directory
    exit 1
fi

# insert the files keeping the originating structure.
echo "COPYING:" cp -r "${args[@]}" "${0%/*}/$dir"
cp -r "${args[@]}" "${0%/*}/$dir"

FINDPROG=find
if $(uname -s | grep -q Darwin); then
  FINDPROG=gfind
fi

mapfile -t finalfiles < <($FINDPROG "${0%/*}/$dir" -type f -printf '%P')
urls=("${finalfiles[@]/#/https://unphased.github.io/static-sharing/$dir/}")

echo changes added for $dir
echo "urls: ${urls[*]}"


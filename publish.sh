#!/bin/bash

# Accepts a list of arguments which are paths to files. (it is reasonable to pipe a call to find or fd or something in)
# A new dir will be made based on the date, a descriptive name is prompted for (or can be specifiied with a flag), and
# all files will be placed into such a dir in this repo so that it can be publicly shared.
# A link to the public site will be provided at the end.

# First parse arg flags leaving the rest of the args for further processing as file names if appropriate.
# -n, --name: specify the name of the directory to be created. Still gonna be behind a date dir.
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

# For now require a name...
if [ -z "$name" ]; then
  echo "Please specify a name for the directory to be created."
  exit 1
fi

# Then check if the files exist and are readable.
# If they are, create the dir and copy the files over.
# If they are not, print an error message and exit.

# Finally, print the link to the public site.


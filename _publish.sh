#! /bin/bash

# clear
# rm -r *_cache *_files

# render
quarto render --no-clean

# track changes
git add .
git commit -m "$1"

# publish
git push

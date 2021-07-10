#!/bin/bash

# This script collects filtered_func_data_clean.nii.gz
# and rename the files after ica directories

# Usage
# 1. cd to the working directory where ica directories are saved.
# 2. run this script specifying ica directories

# 10 July 2021 K.Nemoto

#for dir in F_*.ica
for dir in "$@"
do
  orig=$(find $dir -name 'filtered_func_data_clean.nii.gz')
  dest=$(echo $orig | awk -F/ '{ print $1 }' | sed 's/.ica$/_fixed.nii.gz/')
  cp -v $orig ./$dest
done


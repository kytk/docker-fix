#!/bin/bash

if [ $# -lt 1 ] ; then
  echo "Error! No tag is specified!"
  echo "Usage: $0 tag"
  exit 1
fi

tag=$1

# build image
docker build -t kytk/docker-fix:${tag} .

# make archive
#docker save -o docker-fix.${tag}.tar docker-fix:${tag}
#pigz docker-fix.${tag}.tar


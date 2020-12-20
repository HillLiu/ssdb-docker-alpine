#!/usr/bin/env bash

DIR="$( cd "$(dirname "$0")" ; pwd -P )"
sourceImage=`${DIR}/support/sourceImage.sh`
targetImage=`${DIR}/support/targetImage.sh`
archiveFile=$DIR/archive.tar
VERSION=`${DIR}/support/VERSION.sh`

list(){
  docker images | head -10 
}

tag(){
  tag=$1
  if [ -z "$tag" ]; then
    if [ -z "$VERSION" ]; then
      tag=latest
    else
      tag=$VERSION
    fi
  fi
  echo "* <!-- Start to tag: ${tag}"
  echo $tag
  docker tag $sourceImage ${targetImage}:$tag
  list
  echo "* Finish tag -->"
}

push(){
  if [ -z "$VERSION" ]; then
    tag=latest
  else
    tag=$VERSION
  fi
  echo "* <!-- Start to push ${tag}"
  docker login
  docker push ${targetImage}:$tag
  echo "* Finish to push -->"
}

build(){
  if [ -z "$1" ]; then
    NO_CACHE=""
  else  
    NO_CACHE="--no-cache"
  fi  
  if [ -z "$VERSION" ]; then
    BUILD_ARG=""
    tag=latest
  else
    BUILD_ARG="--build-arg VERSION=${VERSION}"
    tag=$VERSION
  fi
  docker build ${BUILD_ARG}${NO_CACHE} -f ${DIR}/Dockerfile -t $sourceImage:$tag ${DIR}
  list
}

save() {
  echo save
  docker save $sourceImage > $archiveFile
}

restore() {
  echo restore
  docker save --output $archiveFile $sourceImage
}

case "$1" in
  save)
    save
    ;;
  restore)
    restore
    ;;
  p)
    push
    ;;
  t)
    tag $2 
    ;;
  nocache)  
    build --no-cache
    ;;
  auto)
    build $2
    tag
    ;;
  b)  
    build $2
    ;;
  l)
    list
    ;;
  *)
    echo "$0 [save|restore|p|t|nocache|auto|b|l]" 
    exit
esac

exit $?

#!/usr/bin/env bash
source /opt/lash/bin/init.sh
VARS=(VENDOR )
LOGFL=$(mktemp)
if [[ "$BASEIMAGE" == "" ]]
then
  BASEIMAGE="baseimage"
fi

fail() {
    echo "ERROR IN BUILD $@"
    kill -9 $$
}
log() {
  echo $@
}
export -f log

log "building base $VENDOR/baseimage "; echo
{
  if [[ "$SKIPBASE" == "" ]]
  then
    docker build -t $VENDOR/$BASEIMAGE .
  fi
} || {
  fail
}
origpath=$(realpath pwd)
for ctrdir in $(find Containers/ -maxdepth 1 -mindepth 1 -type d | grep -v _)
do
  buildpath="$(realpath $ctrdir)"
  ctrdir=$(cd $buildpath && echo "${PWD##*/}")
  cd $buildpath
  log "building $VENDOR/${PWD##*/}"; echo
  if [[ ! -f _BUILD_DISABLE ]]; then
    {
      unset BUILDARGS
      if [[ -f .buildargs ]]
      then
        for arg in $(cat .buildargs)
        do
          if [[ "${!arg}" == "" ]]
          then
            fail "missing $arg variable"
          else
            BUILDARGS="$BUILDARGS --build-arg=$arg='"${!arg}"'"
          fi
         done
       fi
       export JSON_STRING='{"'${PWD##*/}'":"Dockerfile"}'
       if [[ -f _JOBS.json ]]
       then
         export JSON_STRING=$(cat _JOBS.json)
       fi
       decodeJson
       for buildjob in $DECODE_KEYS
       do
         export buildjob BUILDARGS ctrdir buildpath origpath dst VENDOR
         log bats $dst/workflow/docker.bats
         bats $dst/workflow/docker.bats
       done

    } || {
      fail
    }
  fi
  cd ../../;
done


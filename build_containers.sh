#!/usr/bin/env bash
VARS=(VENDOR )

fail() {
    echo "ERROR IN BUILD $@"
    kill -9 $$
}
log() {
  echo $@
}


log "building base $VENDOR/baseimage "; echo
{
  if [[ "$SKIPBASE" == "" ]]
  then
    docker build -t $VENDOR/baseimage .
  fi
} || {
  fail
}
origpath=$(realpath pwd)
for ctrdir in $(find Containers/ -maxdepth 1 -mindepth 1 -type d | grep -v _)
do
  buildpath="$(realpath $ctrdir);"
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
         export buildjob BUILDARGS ctrdir buildpath origpath VENDOR ${!buildjob}
         bats workflow/docker.bats
       done

    } || {
      fail
    }
  fi
  cd ../../;
done


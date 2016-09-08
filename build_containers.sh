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
ctr_build_loop() {
    origpath=$(realpath $PWD)
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
           for buildjob in $(echo $DECODE_KEYS)
           do
             export buildjob VENDOR BUILDARGS
             cd $buildpath
             docker_add && docker_build && docker_clean
           done

        } || {
          fail
        }
      fi
      cd ../../;
    done

}
docker_add(){
  if [[ -f add.sh ]] && [[ "$FETCH_DISABLE" == "" ]]
  then
  {
    source add.sh
    ADD $EXTRA
   } || {
    fail
   }
  fi
}
docker_build(){
  log "buildjob ${!buildjob}"
  TS="docker build $BUILDARGS -t $VENDOR/$buildjob -f ${!buildjob} ."
  log $TS
  $TS
  return $?
}
docker_clean(){
  if [[ -f add.sh ]]; then bash add.sh clean; fi
}

export -f docker_add docker_build docker_clean

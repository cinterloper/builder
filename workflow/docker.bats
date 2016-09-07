#!/usr/bin/env bats
source build.sh

@test "correct variables passed" {
 result=0
 for var in ${VARS[@]}
 do
  if [  "$(eval echo \$"$var")" == "" ]
  then
    echo "failed to find $var" 1>&2 
    result=-1
  fi
 done
 [ "$result" -eq 0 ]

}

@test "build repo: $GH_REPO" {
  docker_add
  docker_build
  docker_clean
  if [ "$RELEASE" != "" ]
  then
    docker_release
  fi
}

#!/usr/bin/env bats
VARS=( GH_REPO GH_TOKEN GH_USER )

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
source build.sh

@test "build repo: $GH_REPO" {
  grab_it
  build_it
  if [ "$RELEASE" != "" ]
  then
    release_it
  fi
}



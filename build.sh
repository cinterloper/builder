export dst="/tmp/$(echo $GH_REPO | cut -d '/' -f 2)"
grab_it() {
  if [[ "$GH_BRANCH" != "" ]]
  then
    BRANCH="-b $GH_BRANCH"
  fi

  cd /tmp
  git clone $BRANCH https://$GH_USER:$GH_TOKEN@github.com/$GH_REPO
}

build_it() { #the publish destinations depend on the credentials in the enviornment
  cd $dst && bats workflow/build.bats
  cd $dst && bats workflow/publish.bats
}
release_it(){
  cd $dst && bats workflow/build.bats
  cd $dst && bats workflow/release.bats
}
docker_add(){
  if [[ -f add.sh ]]; then
  {
    source add.sh
    ADD $EXTRA
   } || {
    fail
   }
  fi
}
docker_build(){
  cd $origdir
  log "buildjob ${!buildjob}"
  TS="docker build $BUILDARGS -t $VENDOR/$buildjob -f ${!buildjob} ."
  log $TS
  eval $TS
}
docker_clean(){
  if [[ -f add.sh ]]; then bash add.sh clean; fi
}

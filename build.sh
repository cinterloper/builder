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
  cd $dst
  CTR_EXIT=0
  bats workflow/build.bats
  if [[ -d Containers ]] || [[ -f Dockerfile ]]
  then
    source /build_containers.sh
    ctr_build_loop
    CTR_EXIT=$?
  fi
  bats workflow/publish.bats
}
release_it(){
  cd $dst
  {
    bats workflow/build.bats
    bats workflow/release.bats
  } || {
    return -1
  }
}

export dst="/tmp/$(echo $GH_REPO | cut -d '/' -f 2)"
grab_it() {
  cd /tmp
  git clone https://$GH_USER:$GH_TOKEN@github.com/$GH_REPO
}

build_it() { #the publish destinations depend on the credentials in the enviornment
  cd $dst && bats workflow/build.bats
  cd $dst && bats workflow/publish.bats
}
release_it(){
  cd $dst && bats workflow/build.bats
  cd $dst && bats workflow/release.bats
}

export dst=$(mktemp -d)
grab_it() {
  git clone https://$GH_USR:$GH_TOKEN@github.com/$GH_REPO $dst
}

build_it() { #the publish destinations depend on the credentials in the enviornment
  cd $dst && bats workflow/build.bats
  cd $dst && bats workflow/publish.bats
}
release_it(){
  cd $dst && bats workflow/build.bats
  cd $dst && bats workflow/release.bats
}

#!/usr/bin/env bats
@test "publish to maven and github" {
  docker push cinterloper/builder
  result=$?
  [ "$result" -eq 0 ]
}


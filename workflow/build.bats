#!/usr/bin/env bats
@test "build builder base" {
  echo # docker build -t cinterloper/builder .
  result=$?
  [ "$result" -eq 0 ]
}


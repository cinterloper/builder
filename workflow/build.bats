#!/usr/bin/env bats
@test "build interlink base" {
  docker build -t cinterloper/builder .
  result=$?
  [ "$result" -eq 0 ]
}


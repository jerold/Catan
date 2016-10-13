#! /bin/bash


pushd $GOPATH/src/github.com/jerold/Catan/golib/server
go build -i
./server
popd

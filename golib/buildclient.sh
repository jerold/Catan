#! /bin/bash

set -e

pushd $GOPATH/src/github.com/jerold/Catan/golib
netgen --input=catannet/messages.ng --gendart=true
mkdir -p ../lib/src/catannet
mv catannet/catannet.dart ../lib/src/catannet/catannet.dart
popd

pushd $GOPATH/src/github.com/jerold/Catan/golib/client/bindings
gopherjs build -m
du -h bindings.js
mv bindings.js ../../../lib/src
popd

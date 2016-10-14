#! /bin/bash

set -e

pushd $GOPATH/src/github.com/jerold/Catan/golib
netgen --input=catannet/messages.ng --gendart=true
mv catannet/catannet.dart ../lib/src/catannet
popd

pushd $GOPATH/src/github.com/jerold/Catan/golib/client/bindings
gopherjs build -m
du -lah bindings.js
mv bindings.js ../../../lib/src
popd

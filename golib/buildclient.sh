#! /bin/bash

pushd $GOPATH/src/github.com/jerold/Catan/golib
netgen catannet/messages.ng
mv catannet/catannet.dart ../lib/src/catannet
popd

pushd $GOPATH/src/github.com/jerold/Catan/golib/client/bindings
gopherjs build -m
du -lah bindings.js
mv bindings.js* ../../../lib/src
popd

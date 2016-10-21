#!/bin/bash

./golib/install_tools.sh
./golib/buildclient.sh
./golib/buildserver.sh

# Get go deps
go get -u golang.org/x/net/websocket

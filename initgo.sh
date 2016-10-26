#!/bin/bash

# Get go deps
go get -u golang.org/x/net/websocket

./golib/install_tools.sh
./golib/buildclient.sh
./golib/buildserver.sh

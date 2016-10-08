package main

import (
	"fmt"
	"testing"
	"time"

	"github.com/jerold/Catan/golib/catannet"
	"golang.org/x/net/websocket"
)

func TestServer(t *testing.T) {
	go runServer()
	time.Sleep(time.Second)
	client, err := websocket.Dial("ws://127.0.0.1:4567/ws", "", "http://127.0.0.1")
	if err != nil {
		fmt.Printf("err: %s", err)
		t.FailNow()
	}
	np := catannet.NewPacket(&catannet.Heartbeat{})
	client.Write(np.Pack())
	result := make([]byte, 4098)
	client.Read(result)
	fmt.Printf("Sent heartbeat, waiting for response.\n")
	packetResult, _ := catannet.NextPacket(result)
	fmt.Printf("Message result: %v\n", packetResult)
}

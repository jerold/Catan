package main

import (
	"github.com/gopherjs/gopherjs/js"
	"github.com/gopherjs/websocket"
)

func newWebSocketJS(url string, onOpen func(*js.Object)) *webSocketJS {
	ws, err := websocket.New(url)
	if err != nil {
		print("Failed to create client: " + err.Error())
		return nil
	}
	ws.BinaryType = "arraybuffer"
	sockjs := &webSocketJS{
		WebSocket: ws,
		dataC:     make(chan *js.Object, 5),
	}
	sockjs.AddEventListener("message", false, sockjs.onMessage)
	sockjs.AddEventListener("open", false, onOpen)
	return sockjs
}

type webSocketJS struct {
	*websocket.WebSocket

	dataC chan *js.Object
}

func (ws *webSocketJS) onMessage(msg *js.Object) {
	go func() {
		ws.dataC <- msg
	}()
}

func (ws *webSocketJS) Read(p []byte) (n int, err error) {
	msg := <-ws.dataC

	receivedBytes := getFrameData(msg)
	n = copy(p, receivedBytes)
	return
}

func (ws *webSocketJS) Close() error {
	return nil
}

func (ws *webSocketJS) Write(p []byte) (n int, err error) {
	// []byte is converted to an Uint8Array by GopherJS, which fullfils the
	// ArrayBufferView definition.
	err = ws.Send(p)
	if err != nil {
		return 0, err
	}
	return len(p), nil
}

func getFrameData(obj *js.Object) []byte {
	// Check if it's an array buffer. If so, convert it to a Go byte slice.
	if constructor := obj.Get("data").Get("constructor"); constructor == js.Global.Get("ArrayBuffer") {
		uint8Array := js.Global.Get("Uint8Array").New(obj.Get("data"))
		return uint8Array.Interface().([]byte)
	}
	return []byte(obj.Get("data").String())
}

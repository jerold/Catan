package main

import (
	"github.com/gopherjs/gopherjs/js"
	"github.com/gopherjs/websocket"

	"github.com/jerold/Catan/golib/catannet"
	"github.com/jerold/Catan/golib/client"
)

func main() {
	js.Global.Set("catannet", map[string]interface{}{
		"NewClient": newClient,
	})
}

type ClientJS struct {
	*client.Client

	events *ClientEvents
}

func (c *ClientJS) Events() *js.Object {
	return js.MakeWrapper(c.events)
}

func (c *ClientJS) LoadGame(lg *js.Object) {
	c.Outgoing <- catannet.NewPacket(catannet.LoadGame{
		ID: int32(lg.Get("ID").Int()),
	})
}

type ClientEvents struct {
	onLoadGame LoadCallback
	onConnect  FieldlessCallback
}

type FieldlessCallback func()
type LoadCallback func(*catannet.LoadGameResponse)

func (ce *ClientEvents) OnLoadGame(cb LoadCallback) {
	ce.onLoadGame = cb
}

func (ce *ClientEvents) OnConnect(cb FieldlessCallback) {
	ce.onConnect = cb
}

func (c *ClientJS) Dial(url string) {
	go func() {
		if url == "" {
			url = "ws://127.0.0.1:4567/ws"
		}
		c.Conn = newWebSocketJS(url, func(o *js.Object) {
			if c.events.onConnect != nil {
				c.events.onConnect()
			}
		})
		go runClient(c)
	}()
}

func newClient() *js.Object {
	c := &ClientJS{
		Client: &client.Client{
			Conn:     nil,
			Outgoing: make(chan *catannet.Packet, 100),
			Incoming: make(chan *catannet.Packet, 100),
		},
		events: &ClientEvents{},
	}
	return js.MakeWrapper(c)
}

func runClient(c *ClientJS) {
	print("client net is now running.")
	go client.Sender(c.Client)
	go client.Reader(c.Client)

	for packet := range c.Incoming {
		switch packet.Frame.MsgType {
		case catannet.HeartbeatMsgType:
			print("heartbeat returned.")
		case catannet.SaveGameResponseMsgType:
			print("save game response returned.")
		case catannet.LoadGameResponseMsgType:
			print("load game response returned.")
			if c.events.onLoadGame != nil {
				c.events.onLoadGame(packet.NetMsg.(*catannet.LoadGameResponse))
			}
		}
	}
	print("runClient exiting.")
}

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

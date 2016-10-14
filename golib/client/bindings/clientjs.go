package main

import (
	"github.com/gopherjs/gopherjs/js"
	"github.com/jerold/Catan/golib/catannet"
	"github.com/jerold/Catan/golib/catannet/catannetjs"
	"github.com/jerold/Catan/golib/client"
)

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

type ClientJS struct {
	*client.Client

	events *ClientEvents
}

func (c *ClientJS) Events() *js.Object {
	return js.MakeWrapper(c.events)
}

func (c *ClientJS) LoadGame(jso *js.Object) {
	lg := catannetjs.LoadGameRequestFromJS(jso)
	c.Outgoing <- catannet.NewPacket(lg)
}

func (c *ClientJS) SaveGame(jso *js.Object) {
	sg := catannetjs.SaveGameRequestFromJS(jso)
	c.Outgoing <- catannet.NewPacket(sg)
}

type ClientEvents struct {
	onLoadGame LoadCallback
	onSaveGame SaveCallback
	onConnect  FieldlessCallback
}

type FieldlessCallback func()
type LoadCallback func(*catannet.LoadGameResponse)
type SaveCallback func(*catannet.SaveGameResponse)

func (ce *ClientEvents) OnSaveGame(cb SaveCallback) {
	ce.onSaveGame = cb
}

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

func runClient(c *ClientJS) {
	print("client net is now running.")
	go client.Sender(c.Client)
	go client.Reader(c.Client)

	for packet := range c.Incoming {
		switch packet.Frame.MsgType {
		case catannet.HeartbeatMsgType:
			print("heartbeat returned.")
		case catannet.SaveGameResponseMsgType:
			if c.events.onSaveGame != nil {
				c.events.onSaveGame(packet.NetMsg.(*catannet.SaveGameResponse))
			}
		case catannet.LoadGameResponseMsgType:
			if c.events.onLoadGame != nil {
				c.events.onLoadGame(packet.NetMsg.(*catannet.LoadGameResponse))
			}
		}
	}
	print("runClient exiting.")
}

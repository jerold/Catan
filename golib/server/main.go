package main

import (
	"net/http"

	"github.com/jerold/Catan/golib/catannet"

	"golang.org/x/net/websocket"
)

func main() {
	http.Handle("/stream", websocket.Handler(func(conn *websocket.Conn) {
		go runClient(createClient(conn))
	}))
}

func createClient(conn *websocket.Conn) Client {
	return Client{
		conn:     conn,
		outgoing: make(chan *catannet.Packet, 100),
		incoming: make(chan *catannet.Packet, 100),
	}
}

func runClient(c Client) {
	go sender(c)
	go reader(c)

	for packet := range c.incoming {
		switch packet.Frame.MsgType {
		case catannet.HeartbeatMsgType:
			c.outgoing <- packet // ECHO FOR SOME REASON
		case catannet.SaveGameMsgType:
			go func(sg *catannet.SaveGame) {
				id, err := SaveGame(sg)
				if err != nil {
					// TODO: HANDLE ERR HERE.
				}
				c.outgoing <- catannet.NewPacket(catannet.SaveGameResponseMsgType, catannet.SaveGameResponse{
					ID: int32(id),
				})
			}(packet.NetMsg.(*catannet.SaveGame))
		}

	}
}

func reader(c Client) {
	idx := 0
	buffer := make([]byte, 4096)
	for {
		n, err := c.conn.Read(buffer[idx:])
		if err != nil {
			// ded?
		} else if n == 0 {
			// ded?
		} else if n+idx == len(buffer) {
			// Expand buffer to hold the message!
			newbuff := make([]byte, len(buffer)*2)
			copy(newbuff, buffer)
			buffer = newbuff
			idx += n
			continue
		}

		p, ok := catannet.NextPacket(buffer)
		if !ok {
			// increment idx so that
			idx += n
			continue
		}
		c.incoming <- &p
		copy(buffer, buffer[n:])
		idx = 0
	}
}

func sender(c Client) {
	for {
		n, err := c.conn.Write((<-c.outgoing).Pack())
		if err != nil {
			// ded?
		} else if n == 0 {
			// ded?
		}
	}
}

type Client struct {
	conn     *websocket.Conn
	outgoing chan *catannet.Packet
	incoming chan *catannet.Packet
}

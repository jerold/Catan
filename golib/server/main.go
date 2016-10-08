package main

import (
	"fmt"
	"net/http"

	"github.com/jerold/Catan/golib/catannet"

	"golang.org/x/net/websocket"
)

func main() {
	runServer()
}

func runServer() {
	http.Handle("/ws", websocket.Handler(func(conn *websocket.Conn) {
		c := createClient(conn)
		runClient(c)
	}))
	err := http.ListenAndServe(":4567", nil)
	if err != nil {
		fmt.Printf("Error starting server: %s\n", err)
	}
}

func createClient(conn *websocket.Conn) Client {
	return Client{
		conn:     conn,
		outgoing: make(chan *catannet.Packet, 100),
		incoming: make(chan *catannet.Packet, 100),
	}
}

func runClient(c Client) {
	fmt.Printf("New Client: %v, %v\n", c.conn.RemoteAddr(), c.conn.LocalAddr())
	go sender(c)
	go reader(c)

	for packet := range c.incoming {
		switch tmsg := packet.NetMsg.(type) {
		case *catannet.Heartbeat:
			c.outgoing <- packet // ECHO FOR SOME REASON
		case *catannet.SaveGame:
			go func(sg *catannet.SaveGame) {
				resp, err := SaveGame(sg)
				if err != nil {
					// TODO: HANDLE ERR HERE.
				}
				c.outgoing <- catannet.NewPacket(resp)
			}(tmsg)
		case *catannet.LoadGame:
			go func(lg *catannet.LoadGame) {
				lgr, err := LoadGame(lg.ID)
				if err != nil {
					// TODO: HANDLE ERR HERE.
				}
				c.outgoing <- catannet.NewPacket(lgr)
			}(tmsg)
		}

	}
}

func reader(c Client) {
	idx := 0
	buffer := make([]byte, 4096)
	for {
		n, err := c.conn.Read(buffer[idx:])
		if err != nil {
			fmt.Printf("error reading: %s\n", err)
			panic("error reading")
			// ded?
		} else if n == 0 {
			fmt.Printf("0 length read!?\n")
			// ded?
			continue
		} else if n+idx >= len(buffer) {
			fmt.Printf("Expanding buffer to fit new message size, read: %d", n)
			// Expand buffer to hold the message!
			newbuff := make([]byte, len(buffer)*2)
			copy(newbuff, buffer)
			buffer = newbuff
			idx += n
			continue
		}

		p, ok := catannet.NextPacket(buffer)
		if !ok {
			fmt.Printf("server: nextpacket failed, no packet!?\n")
			// increment idx so that
			idx += n
			continue
		}
		fmt.Printf("Got a packet on server, %v\n", p)
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
		fmt.Printf("Wrote outgoing message.")
	}
}

type Client struct {
	conn     *websocket.Conn
	outgoing chan *catannet.Packet
	incoming chan *catannet.Packet
}

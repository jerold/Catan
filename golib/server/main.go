package main

import (
	"fmt"
	"net/http"
	"os"
	"os/signal"

	"github.com/jerold/Catan/golib/catannet"
	"github.com/jerold/Catan/golib/client"

	"golang.org/x/net/websocket"
)

func main() {
	runServer()
}

func runServer() {
	fmt.Printf("Starting server now.\n")
	http.Handle("/ws", websocket.Handler(func(conn *websocket.Conn) {
		c := createClient(conn)
		runClient(&c)
	}))

	go func() {
		err := http.ListenAndServe(":4567", nil)
		if err != nil {
			fmt.Printf("Error starting server: %s\n", err)
		}
	}()

	fmt.Printf("Started.")
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	<-c
}

type binaryWebsocket struct {
	socket *websocket.Conn
}

func (ws *binaryWebsocket) Read(p []byte) (n int, err error) {
	var inbuf []byte
	err = websocket.Message.Receive(ws.socket, &inbuf)
	if err != nil {
		return 0, err
	}
	copy(p, inbuf)
	return len(inbuf), err
}

func (ws *binaryWebsocket) Close() error {
	return ws.socket.Close()
}

func (ws *binaryWebsocket) Write(p []byte) (n int, err error) {
	err = websocket.Message.Send(ws.socket, p)
	return len(p), err
}

func createClient(conn *websocket.Conn) client.Client {
	fmt.Printf("New Connection: %s\n", conn.RemoteAddr().String())
	return client.Client{
		Name:     conn.RemoteAddr().String(),
		Conn:     &binaryWebsocket{socket: conn},
		Outgoing: make(chan *catannet.Packet, 100),
		Incoming: make(chan *catannet.Packet, 100),
	}
}

func runClient(c *client.Client) {
	go client.Sender(c)
	go client.Reader(c)

	for packet := range c.Incoming {
		if packet == nil {
			break
		}
		switch tmsg := packet.NetMsg.(type) {
		case *catannet.Heartbeat:
			fmt.Printf("Got heartbeat!\n")
			c.Outgoing <- packet // ECHO FOR SOME REASON
		case *catannet.SaveGameRequest:
			fmt.Printf("Got save game request!\n")
			go func(sg *catannet.SaveGameRequest) {
				resp, err := SaveGame(sg)
				if err != nil {
					// TODO: HANDLE ERR HERE.
				}
				c.Outgoing <- catannet.NewPacket(resp)
			}(tmsg)
		case *catannet.LoadGameRequest:
			fmt.Printf("Got loadgame request!\n")
			go func(lg *catannet.LoadGameRequest) {
				lgr, err := LoadGame(lg.ID)
				if err != nil {
					// TODO: HANDLE ERR HERE.
				}
				c.Outgoing <- catannet.NewPacket(lgr)
			}(tmsg)
		}

	}

	fmt.Printf("Incoming closed, shutting down client %s.\n", c.Name)
}

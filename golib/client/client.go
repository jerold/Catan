package client

import (
	"io"

	"github.com/jerold/Catan/golib/catannet"
)

func Reader(c *Client) {
	idx := 0
	buffer := make([]byte, 4096)
	for {
		n, err := c.Conn.Read(buffer[idx:])
		if err != nil {
			print("error reading from socket: ", err.Error())
			c.Incoming <- nil
			c.Outgoing <- nil
			return
			// ded?
		} else if n == 0 {
			print("Read 0 len from socket.")
			c.Incoming <- nil
			c.Outgoing <- nil
			// ded?
			return
		} else if n+idx >= len(buffer) {
			// Expand buffer to hold the message!
			newbuff := make([]byte, len(buffer)*2)
			copy(newbuff, buffer)
			buffer = newbuff
			idx += n
			continue
		}

		p, ok := catannet.NextPacket(buffer)
		if !ok {
			// increment idx by how much we wrote.
			idx += n
			// fmt.Printf("No Packet... Buffer: %v\n", buffer[:idx])
			continue
		}
		l := p.Len()
		//fmt.Printf("Got a packet on server, %v\n", p)
		c.Incoming <- &p
		copy(buffer, buffer[l:])
		idx = 0
	}
}

func Sender(c *Client) {
	for m := range c.Outgoing {
		if m == nil {
			return // Empty message means die
		}
		msg := m.Pack()
		// fmt.Printf("sending msg: %v\n", msg)
		n, err := c.Conn.Write(msg)
		if err != nil {
			print("Failure writing to socket: ", err.Error())
			c.Outgoing <- nil
			return
			// ded?
		} else if n == 0 {
			print("Wrote 0 bytes!?\n")
			c.Outgoing <- nil
			return
			// ded?
		}
		//fmt.Printf("Wrote outgoing message.")
	}
	close(c.Incoming)
	close(c.Outgoing)
}

type Client struct {
	ID       int32
	Name     string
	Conn     io.ReadWriteCloser
	Outgoing chan *catannet.Packet
	Incoming chan *catannet.Packet
}

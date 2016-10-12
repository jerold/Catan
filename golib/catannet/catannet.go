package catannet

import (
	"math"
)

// Make sure math import is always valid
var _ = math.Pi

var LittleEndian littleEndian

type littleEndian struct{}

func (littleEndian) Uint16(b []byte) uint16 {
	_ = b[1] // bounds check hint to compiler; see golang.org/issue/14808
	return uint16(b[0]) | uint16(b[1])<<8
}

func (littleEndian) PutUint16(b []byte, v uint16) {
	_ = b[1] // early bounds check to guarantee safety of writes below
	b[0] = byte(v)
	b[1] = byte(v >> 8)
}

func (littleEndian) Uint32(b []byte) uint32 {
	_ = b[3] // bounds check hint to compiler; see golang.org/issue/14808
	return uint32(b[0]) | uint32(b[1])<<8 | uint32(b[2])<<16 | uint32(b[3])<<24
}

func (littleEndian) PutUint32(b []byte, v uint32) {
	_ = b[3] // early bounds check to guarantee safety of writes below
	b[0] = byte(v)
	b[1] = byte(v >> 8)
	b[2] = byte(v >> 16)
	b[3] = byte(v >> 24)
}

func (littleEndian) Uint64(b []byte) uint64 {
	_ = b[7] // bounds check hint to compiler; see golang.org/issue/14808
	return uint64(b[0]) | uint64(b[1])<<8 | uint64(b[2])<<16 | uint64(b[3])<<24 |
		uint64(b[4])<<32 | uint64(b[5])<<40 | uint64(b[6])<<48 | uint64(b[7])<<56
}

func (littleEndian) PutUint64(b []byte, v uint64) {
	_ = b[7] // early bounds check to guarantee safety of writes below
	b[0] = byte(v)
	b[1] = byte(v >> 8)
	b[2] = byte(v >> 16)
	b[3] = byte(v >> 24)
	b[4] = byte(v >> 32)
	b[5] = byte(v >> 40)
	b[6] = byte(v >> 48)
	b[7] = byte(v >> 56)
}

type Net interface {
	Serialize([]byte)
	Len() int
	MsgType() MessageType
}

const FrameLen int = 6

func NewPacket(msg Net) *Packet {
	return &Packet{
		Frame: Frame{
			MsgType:       msg.MsgType(),
			ContentLength: uint16(msg.Len()),
		},
		NetMsg: msg,
	}
}

type Packet struct {
	Frame  Frame
	NetMsg Net
}

// Pack serializes the content into RawBytes.
func (p *Packet) Pack() []byte {
	buf := make([]byte, p.Len())
	LittleEndian.PutUint16(buf, uint16(p.Frame.MsgType))
	LittleEndian.PutUint16(buf[2:], p.Frame.Seq)
	LittleEndian.PutUint16(buf[4:], p.Frame.ContentLength)
	p.NetMsg.Serialize(buf[6:])
	return buf
}

// Len returns the total length of the message including the frame
func (p *Packet) Len() int {
	return int(p.Frame.ContentLength) + FrameLen
}

type Frame struct {
	MsgType       MessageType // byte 0-1, type
	Seq           uint16      // byte 2-3, order of message
	ContentLength uint16      // byte 4-5, content length
}

func ParseFrame(rawBytes []byte) (mf Frame, ok bool) {
	if len(rawBytes) < FrameLen {
		return
	}
	mf.MsgType = MessageType(LittleEndian.Uint16(rawBytes[0:2]))
	mf.Seq = LittleEndian.Uint16(rawBytes[2:4])
	mf.ContentLength = LittleEndian.Uint16(rawBytes[4:6])
	return mf, true
}

func NextPacket(rawBytes []byte) (packet Packet, ok bool) {
	packet.Frame, ok = ParseFrame(rawBytes)
	if !ok {
		return
	}

	ok = false
	if packet.Len() <= len(rawBytes) {
		packet.NetMsg = ParseNetMessage(packet, rawBytes[FrameLen:packet.Len()])
		if packet.NetMsg != nil {
			ok = true
		}
	}
	return
}

type MessageType uint16

const (
	UnknownMsgType MessageType = iota
	AckMsgType
	HeartbeatMsgType
	SaveGameMsgType
	SaveGameResponseMsgType
	LoadGameMsgType
	LoadGameResponseMsgType
	GameBoardMsgType
	PieceLocationMsgType
	CoordinateMsgType
	TileMsgType
	GamePieceMsgType
	PlayerMsgType
	DevelopmentCardMsgType
	ResourceMsgType
)

// ParseNetMessage accepts input of raw bytes from a NetMessage. Parses and returns a Net message.
func ParseNetMessage(packet Packet, content []byte) Net {
	switch packet.Frame.MsgType {
	case HeartbeatMsgType:
		msg := HeartbeatDeserialize(content)
		return &msg
	case SaveGameMsgType:
		msg := SaveGameDeserialize(content)
		return &msg
	case SaveGameResponseMsgType:
		msg := SaveGameResponseDeserialize(content)
		return &msg
	case LoadGameMsgType:
		msg := LoadGameDeserialize(content)
		return &msg
	case LoadGameResponseMsgType:
		msg := LoadGameResponseDeserialize(content)
		return &msg
	case GameBoardMsgType:
		msg := GameBoardDeserialize(content)
		return &msg
	case PieceLocationMsgType:
		msg := PieceLocationDeserialize(content)
		return &msg
	case CoordinateMsgType:
		msg := CoordinateDeserialize(content)
		return &msg
	case TileMsgType:
		msg := TileDeserialize(content)
		return &msg
	case GamePieceMsgType:
		msg := GamePieceDeserialize(content)
		return &msg
	case PlayerMsgType:
		msg := PlayerDeserialize(content)
		return &msg
	case DevelopmentCardMsgType:
		msg := DevelopmentCardDeserialize(content)
		return &msg
	case ResourceMsgType:
		msg := ResourceDeserialize(content)
		return &msg
	default:
		return nil
	}
}

type PieceType int

const(
	Settlement	 PieceType = 0
	City	 PieceType = 1
	Road	 PieceType = 2
)

type TileType int

const(
	WaterTile	 TileType = 0
	LandTile	 TileType = 1
)

type Commodity int

const(
	NoCommodity	 Commodity = 0
	Sheep	 Commodity = 1
	Brick	 Commodity = 2
	Wood	 Commodity = 3
	Stone	 Commodity = 4
	Wheat	 Commodity = 5
)

type Heartbeat struct {
	Time int64
	Latency int64
}

func (m Heartbeat) Serialize(buffer []byte) {
	idx := 0
	LittleEndian.PutUint64(buffer[idx:], uint64(m.Time))
	idx+=8
	LittleEndian.PutUint64(buffer[idx:], uint64(m.Latency))
	idx+=8

	_ = idx
}

func HeartbeatDeserialize(buffer []byte) (m Heartbeat) {
	idx := 0
	m.Time = int64(LittleEndian.Uint64(buffer[idx:]))
	idx+=8
	m.Latency = int64(LittleEndian.Uint64(buffer[idx:]))
	idx+=8

	_ = idx
	return m
}

func (m Heartbeat) Len() int {
	mylen := 0
	mylen += 8
	mylen += 8
	return mylen
}

func (m Heartbeat) MsgType() MessageType {
	return HeartbeatMsgType
}

type SaveGame struct {
	ID int32
	Board GameBoard
	Players []Player
}

func (m SaveGame) Serialize(buffer []byte) {
	idx := 0
	LittleEndian.PutUint32(buffer[idx:], uint32(m.ID))
	idx+=4
	m.Board.Serialize(buffer[idx:])
	idx+=m.Board.Len()
	LittleEndian.PutUint32(buffer[idx:], uint32(len(m.Players)))
	idx += 4
	for _, v2 := range m.Players {
		v2.Serialize(buffer[idx:])
		idx+=v2.Len()
	}

	_ = idx
}

func SaveGameDeserialize(buffer []byte) (m SaveGame) {
	idx := 0
	m.ID = int32(LittleEndian.Uint32(buffer[idx:]))
	idx+=4
	m.Board = GameBoardDeserialize(buffer[idx:])
	idx+=m.Board.Len()
	l2_1 := int(LittleEndian.Uint32(buffer[idx:]))
	idx += 4
	m.Players = make([]Player, l2_1)
	for i := 0; i < int(l2_1); i++ {
		m.Players[i] = PlayerDeserialize(buffer[idx:])
		idx+=m.Players[i].Len()
	}

	_ = idx
	return m
}

func (m SaveGame) Len() int {
	mylen := 0
	mylen += 4
	mylen += m.Board.Len()
	mylen += 4
	for _, v2 := range m.Players {
	_ = v2
		mylen += v2.Len()
	}

	return mylen
}

func (m SaveGame) MsgType() MessageType {
	return SaveGameMsgType
}

type SaveGameResponse struct {
	ID int32
}

func (m SaveGameResponse) Serialize(buffer []byte) {
	idx := 0
	LittleEndian.PutUint32(buffer[idx:], uint32(m.ID))
	idx+=4

	_ = idx
}

func SaveGameResponseDeserialize(buffer []byte) (m SaveGameResponse) {
	idx := 0
	m.ID = int32(LittleEndian.Uint32(buffer[idx:]))
	idx+=4

	_ = idx
	return m
}

func (m SaveGameResponse) Len() int {
	mylen := 0
	mylen += 4
	return mylen
}

func (m SaveGameResponse) MsgType() MessageType {
	return SaveGameResponseMsgType
}

type LoadGame struct {
	ID int32
}

func (m LoadGame) Serialize(buffer []byte) {
	idx := 0
	LittleEndian.PutUint32(buffer[idx:], uint32(m.ID))
	idx+=4

	_ = idx
}

func LoadGameDeserialize(buffer []byte) (m LoadGame) {
	idx := 0
	m.ID = int32(LittleEndian.Uint32(buffer[idx:]))
	idx+=4

	_ = idx
	return m
}

func (m LoadGame) Len() int {
	mylen := 0
	mylen += 4
	return mylen
}

func (m LoadGame) MsgType() MessageType {
	return LoadGameMsgType
}

type LoadGameResponse struct {
	ID int32
	Board GameBoard
	Players []Player
}

func (m LoadGameResponse) Serialize(buffer []byte) {
	idx := 0
	LittleEndian.PutUint32(buffer[idx:], uint32(m.ID))
	idx+=4
	m.Board.Serialize(buffer[idx:])
	idx+=m.Board.Len()
	LittleEndian.PutUint32(buffer[idx:], uint32(len(m.Players)))
	idx += 4
	for _, v2 := range m.Players {
		v2.Serialize(buffer[idx:])
		idx+=v2.Len()
	}

	_ = idx
}

func LoadGameResponseDeserialize(buffer []byte) (m LoadGameResponse) {
	idx := 0
	m.ID = int32(LittleEndian.Uint32(buffer[idx:]))
	idx+=4
	m.Board = GameBoardDeserialize(buffer[idx:])
	idx+=m.Board.Len()
	l2_1 := int(LittleEndian.Uint32(buffer[idx:]))
	idx += 4
	m.Players = make([]Player, l2_1)
	for i := 0; i < int(l2_1); i++ {
		m.Players[i] = PlayerDeserialize(buffer[idx:])
		idx+=m.Players[i].Len()
	}

	_ = idx
	return m
}

func (m LoadGameResponse) Len() int {
	mylen := 0
	mylen += 4
	mylen += m.Board.Len()
	mylen += 4
	for _, v2 := range m.Players {
	_ = v2
		mylen += v2.Len()
	}

	return mylen
}

func (m LoadGameResponse) MsgType() MessageType {
	return LoadGameResponseMsgType
}

type GameBoard struct {
	Pieces []PieceLocation
	Tiles []Tile
}

func (m GameBoard) Serialize(buffer []byte) {
	idx := 0
	LittleEndian.PutUint32(buffer[idx:], uint32(len(m.Pieces)))
	idx += 4
	for _, v2 := range m.Pieces {
		v2.Serialize(buffer[idx:])
		idx+=v2.Len()
	}
	LittleEndian.PutUint32(buffer[idx:], uint32(len(m.Tiles)))
	idx += 4
	for _, v2 := range m.Tiles {
		v2.Serialize(buffer[idx:])
		idx+=v2.Len()
	}

	_ = idx
}

func GameBoardDeserialize(buffer []byte) (m GameBoard) {
	idx := 0
	l0_1 := int(LittleEndian.Uint32(buffer[idx:]))
	idx += 4
	m.Pieces = make([]PieceLocation, l0_1)
	for i := 0; i < int(l0_1); i++ {
		m.Pieces[i] = PieceLocationDeserialize(buffer[idx:])
		idx+=m.Pieces[i].Len()
	}
	l1_1 := int(LittleEndian.Uint32(buffer[idx:]))
	idx += 4
	m.Tiles = make([]Tile, l1_1)
	for i := 0; i < int(l1_1); i++ {
		m.Tiles[i] = TileDeserialize(buffer[idx:])
		idx+=m.Tiles[i].Len()
	}

	_ = idx
	return m
}

func (m GameBoard) Len() int {
	mylen := 0
	mylen += 4
	for _, v2 := range m.Pieces {
	_ = v2
		mylen += v2.Len()
	}

	mylen += 4
	for _, v2 := range m.Tiles {
	_ = v2
		mylen += v2.Len()
	}

	return mylen
}

func (m GameBoard) MsgType() MessageType {
	return GameBoardMsgType
}

type PieceLocation struct {
	Piece GamePiece
	Location Coordinate
}

func (m PieceLocation) Serialize(buffer []byte) {
	idx := 0
	m.Piece.Serialize(buffer[idx:])
	idx+=m.Piece.Len()
	m.Location.Serialize(buffer[idx:])
	idx+=m.Location.Len()

	_ = idx
}

func PieceLocationDeserialize(buffer []byte) (m PieceLocation) {
	idx := 0
	m.Piece = GamePieceDeserialize(buffer[idx:])
	idx+=m.Piece.Len()
	m.Location = CoordinateDeserialize(buffer[idx:])
	idx+=m.Location.Len()

	_ = idx
	return m
}

func (m PieceLocation) Len() int {
	mylen := 0
	mylen += m.Piece.Len()
	mylen += m.Location.Len()
	return mylen
}

func (m PieceLocation) MsgType() MessageType {
	return PieceLocationMsgType
}

type Coordinate struct {
	X int32
	Y int32
}

func (m Coordinate) Serialize(buffer []byte) {
	idx := 0
	LittleEndian.PutUint32(buffer[idx:], uint32(m.X))
	idx+=4
	LittleEndian.PutUint32(buffer[idx:], uint32(m.Y))
	idx+=4

	_ = idx
}

func CoordinateDeserialize(buffer []byte) (m Coordinate) {
	idx := 0
	m.X = int32(LittleEndian.Uint32(buffer[idx:]))
	idx+=4
	m.Y = int32(LittleEndian.Uint32(buffer[idx:]))
	idx+=4

	_ = idx
	return m
}

func (m Coordinate) Len() int {
	mylen := 0
	mylen += 4
	mylen += 4
	return mylen
}

func (m Coordinate) MsgType() MessageType {
	return CoordinateMsgType
}

type Tile struct {
	Location Coordinate
	Type TileType
	Product Commodity
}

func (m Tile) Serialize(buffer []byte) {
	idx := 0
	m.Location.Serialize(buffer[idx:])
	idx+=m.Location.Len()
	LittleEndian.PutUint32(buffer[idx:], uint32(m.Type))
	idx+=4
	LittleEndian.PutUint32(buffer[idx:], uint32(m.Product))
	idx+=4

	_ = idx
}

func TileDeserialize(buffer []byte) (m Tile) {
	idx := 0
	m.Location = CoordinateDeserialize(buffer[idx:])
	idx+=m.Location.Len()
	m.Type = TileType(LittleEndian.Uint32(buffer[idx:]))
	idx+=4
	m.Product = Commodity(LittleEndian.Uint32(buffer[idx:]))
	idx+=4

	_ = idx
	return m
}

func (m Tile) Len() int {
	mylen := 0
	mylen += m.Location.Len()
	mylen += 4
	mylen += 4
	return mylen
}

func (m Tile) MsgType() MessageType {
	return TileMsgType
}

type GamePiece struct {
	Owner int32
	Type PieceType
}

func (m GamePiece) Serialize(buffer []byte) {
	idx := 0
	LittleEndian.PutUint32(buffer[idx:], uint32(m.Owner))
	idx+=4
	LittleEndian.PutUint32(buffer[idx:], uint32(m.Type))
	idx+=4

	_ = idx
}

func GamePieceDeserialize(buffer []byte) (m GamePiece) {
	idx := 0
	m.Owner = int32(LittleEndian.Uint32(buffer[idx:]))
	idx+=4
	m.Type = PieceType(LittleEndian.Uint32(buffer[idx:]))
	idx+=4

	_ = idx
	return m
}

func (m GamePiece) Len() int {
	mylen := 0
	mylen += 4
	mylen += 4
	return mylen
}

func (m GamePiece) MsgType() MessageType {
	return GamePieceMsgType
}

type Player struct {
	ID int32
	Name string
	Resources []Resource
	Cards []DevelopmentCard
	Pieces []GamePiece
}

func (m Player) Serialize(buffer []byte) {
	idx := 0
	LittleEndian.PutUint32(buffer[idx:], uint32(m.ID))
	idx+=4
	LittleEndian.PutUint32(buffer[idx:], uint32(len(m.Name)))
	idx += 4
	copy(buffer[idx:], []byte(m.Name))
	idx+=len(m.Name)
	LittleEndian.PutUint32(buffer[idx:], uint32(len(m.Resources)))
	idx += 4
	for _, v2 := range m.Resources {
		v2.Serialize(buffer[idx:])
		idx+=v2.Len()
	}
	LittleEndian.PutUint32(buffer[idx:], uint32(len(m.Cards)))
	idx += 4
	for _, v2 := range m.Cards {
		v2.Serialize(buffer[idx:])
		idx+=v2.Len()
	}
	LittleEndian.PutUint32(buffer[idx:], uint32(len(m.Pieces)))
	idx += 4
	for _, v2 := range m.Pieces {
		v2.Serialize(buffer[idx:])
		idx+=v2.Len()
	}

	_ = idx
}

func PlayerDeserialize(buffer []byte) (m Player) {
	idx := 0
	m.ID = int32(LittleEndian.Uint32(buffer[idx:]))
	idx+=4
	l1_1 := int(LittleEndian.Uint32(buffer[idx:]))
	idx += 4
	m.Name = string(buffer[idx:idx+l1_1])
	idx+=len(m.Name)
	l2_1 := int(LittleEndian.Uint32(buffer[idx:]))
	idx += 4
	m.Resources = make([]Resource, l2_1)
	for i := 0; i < int(l2_1); i++ {
		m.Resources[i] = ResourceDeserialize(buffer[idx:])
		idx+=m.Resources[i].Len()
	}
	l3_1 := int(LittleEndian.Uint32(buffer[idx:]))
	idx += 4
	m.Cards = make([]DevelopmentCard, l3_1)
	for i := 0; i < int(l3_1); i++ {
		m.Cards[i] = DevelopmentCardDeserialize(buffer[idx:])
		idx+=m.Cards[i].Len()
	}
	l4_1 := int(LittleEndian.Uint32(buffer[idx:]))
	idx += 4
	m.Pieces = make([]GamePiece, l4_1)
	for i := 0; i < int(l4_1); i++ {
		m.Pieces[i] = GamePieceDeserialize(buffer[idx:])
		idx+=m.Pieces[i].Len()
	}

	_ = idx
	return m
}

func (m Player) Len() int {
	mylen := 0
	mylen += 4
	mylen += 4 + len(m.Name)
	mylen += 4
	for _, v2 := range m.Resources {
	_ = v2
		mylen += v2.Len()
	}

	mylen += 4
	for _, v2 := range m.Cards {
	_ = v2
		mylen += v2.Len()
	}

	mylen += 4
	for _, v2 := range m.Pieces {
	_ = v2
		mylen += v2.Len()
	}

	return mylen
}

func (m Player) MsgType() MessageType {
	return PlayerMsgType
}

type DevelopmentCard struct {
	CardType int
}

func (m DevelopmentCard) Serialize(buffer []byte) {
	idx := 0
	
	_ = idx
}

func DevelopmentCardDeserialize(buffer []byte) (m DevelopmentCard) {
	idx := 0
	
	_ = idx
	return m
}

func (m DevelopmentCard) Len() int {
	mylen := 0
	
	return mylen
}

func (m DevelopmentCard) MsgType() MessageType {
	return DevelopmentCardMsgType
}

type Resource struct {
	Type Commodity
}

func (m Resource) Serialize(buffer []byte) {
	idx := 0
	LittleEndian.PutUint32(buffer[idx:], uint32(m.Type))
	idx+=4

	_ = idx
}

func ResourceDeserialize(buffer []byte) (m Resource) {
	idx := 0
	m.Type = Commodity(LittleEndian.Uint32(buffer[idx:]))
	idx+=4

	_ = idx
	return m
}

func (m Resource) Len() int {
	mylen := 0
	mylen += 4
	return mylen
}

func (m Resource) MsgType() MessageType {
	return ResourceMsgType
}


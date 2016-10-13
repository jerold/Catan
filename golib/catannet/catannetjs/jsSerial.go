package catannetjs

import (
	"github.com/gopherjs/gopherjs/js"
	"github.com/jerold/Catan/golib/catannet"
)

func HeartbeatFromJS(jso *js.Object) (m catannet.Heartbeat) {
	m.Time = int64(jso.Get("Time").Int64())
	m.Latency = int64(jso.Get("Latency").Int64())
	return m
}
func SaveGameRequestFromJS(jso *js.Object) (m catannet.SaveGameRequest) {
	m.ID = int32(jso.Get("ID").Int64())
	var subBoard = GameBoardFromJS(jso.Get("Board"))
	m.Board = &subBoard
	m.Players = make([]*catannet.Player, jso.Get("Players").Length())
	for i := 0; i < jso.Get("Players").Length(); i++ {
		var subi = PlayerFromJS(jso.Get("Players").Index(i))
		m.Players[i] = &subi
	}
	return m
}
func SaveGameResponseFromJS(jso *js.Object) (m catannet.SaveGameResponse) {
	m.ID = int32(jso.Get("ID").Int64())
	return m
}
func LoadGameRequestFromJS(jso *js.Object) (m catannet.LoadGameRequest) {
	m.ID = int32(jso.Get("ID").Int64())
	return m
}
func LoadGameResponseFromJS(jso *js.Object) (m catannet.LoadGameResponse) {
	m.ID = int32(jso.Get("ID").Int64())
	var subBoard = GameBoardFromJS(jso.Get("Board"))
	m.Board = &subBoard
	m.Players = make([]*catannet.Player, jso.Get("Players").Length())
	for i := 0; i < jso.Get("Players").Length(); i++ {
		var subi = PlayerFromJS(jso.Get("Players").Index(i))
		m.Players[i] = &subi
	}
	return m
}
func GameBoardFromJS(jso *js.Object) (m catannet.GameBoard) {
	m.Pieces = make([]*catannet.PieceLocation, jso.Get("Pieces").Length())
	for i := 0; i < jso.Get("Pieces").Length(); i++ {
		var subi = PieceLocationFromJS(jso.Get("Pieces").Index(i))
		m.Pieces[i] = &subi
	}
	m.Tiles = make([]*catannet.Tile, jso.Get("Tiles").Length())
	for i := 0; i < jso.Get("Tiles").Length(); i++ {
		var subi = TileFromJS(jso.Get("Tiles").Index(i))
		m.Tiles[i] = &subi
	}
	return m
}
func PieceLocationFromJS(jso *js.Object) (m catannet.PieceLocation) {
	var subPiece = GamePieceFromJS(jso.Get("Piece"))
	m.Piece = &subPiece
	var subLocation = CoordinateFromJS(jso.Get("Location"))
	m.Location = &subLocation
	return m
}
func CoordinateFromJS(jso *js.Object) (m catannet.Coordinate) {
	m.X = int32(jso.Get("X").Int64())
	m.Y = int32(jso.Get("Y").Int64())
	return m
}
func TileFromJS(jso *js.Object) (m catannet.Tile) {
	var subLocation = CoordinateFromJS(jso.Get("Location"))
	m.Location = &subLocation
	m.Type = catannet.TileType(jso.Get("Type").Int64())
	m.Product = catannet.Commodity(jso.Get("Product").Int64())
	return m
}
func GamePieceFromJS(jso *js.Object) (m catannet.GamePiece) {
	m.Owner = int32(jso.Get("Owner").Int64())
	m.Type = catannet.PieceType(jso.Get("Type").Int64())
	return m
}
func PlayerFromJS(jso *js.Object) (m catannet.Player) {
	m.ID = int32(jso.Get("ID").Int64())
	m.Name = jso.Get("Name").String()
	m.Resources = make([]*catannet.Resource, jso.Get("Resources").Length())
	for i := 0; i < jso.Get("Resources").Length(); i++ {
		var subi = ResourceFromJS(jso.Get("Resources").Index(i))
		m.Resources[i] = &subi
	}
	m.Cards = make([]*catannet.DevelopmentCard, jso.Get("Cards").Length())
	for i := 0; i < jso.Get("Cards").Length(); i++ {
		var subi = DevelopmentCardFromJS(jso.Get("Cards").Index(i))
		m.Cards[i] = &subi
	}
	m.Pieces = make([]*catannet.GamePiece, jso.Get("Pieces").Length())
	for i := 0; i < jso.Get("Pieces").Length(); i++ {
		var subi = GamePieceFromJS(jso.Get("Pieces").Index(i))
		m.Pieces[i] = &subi
	}
	return m
}
func DevelopmentCardFromJS(jso *js.Object) (m catannet.DevelopmentCard) {
	m.CardType = int32(jso.Get("CardType").Int64())
	return m
}
func ResourceFromJS(jso *js.Object) (m catannet.Resource) {
	m.Type = catannet.Commodity(jso.Get("Type").Int64())
	return m
}

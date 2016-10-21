package catannet

import (
	"strconv"
	"testing"
	"time"
)

func TestPerformance(t *testing.T) {
	b := GameBoard{
		Pieces: make([]*PieceLocation, 100),
		Tiles:  make([]*Tile, 50),
	}

	for i := 0; i < 100; i++ {
		b.Pieces[i].Location = &Coordinate{
			X: 1054,
			Y: 4538,
		}
		b.Pieces[i].Piece = &GamePiece{
			Owner: 1,
			Type:  Road,
		}
	}
	for i := 0; i < 50; i++ {
		b.Tiles[i].Location = &Coordinate{
			X: 5354,
			Y: 58459,
		}
		b.Tiles[i].Type = LandTile
		b.Tiles[i].Product = Stone
	}
	buff := make([]byte, b.Len())
	st := time.Now()
	b.Serialize(buff)
	print("Total Serialize: " + strconv.FormatInt(time.Now().Sub(st).Nanoseconds()/int64(time.Millisecond), 10))
	print("\n")
	st = time.Now()
	for i := 0; i < 10; i++ {
		b = GameBoardDeserialize(buff)
	}
	print("Total Deserial: " + strconv.FormatInt(time.Now().Sub(st).Nanoseconds()/int64(time.Millisecond), 10))
	print("\n")

}

package catan

type GamePiece struct {
	Owner int // Player Owner
	Type  PieceType
}

type PieceType int

const (
	Settlement PieceType = 0
	City       PieceType = 0
	Road       PieceType = 0
)

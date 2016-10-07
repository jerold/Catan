package catan

type Board struct {
	Pieces []PieceLocation
	Tiles  []Tile
}

type PieceLocation struct {
	Piece    GamePiece
	Location Coordinate
}

type Coordinate struct {
	X int
	Y int
}

// Water + nothing = water
// Water + commodity = port
// Land + nothing = desert
// Land + commodity = resource tile
type Tile struct {
	Location Coordinate // TODO: model location correctly.
	Type     TileType   // Land or Water
	Product  Commodity  // Commidity Type
}

type TileType int

const (
	WaterTile TileType = 0
	LandTile  TileType = 1
)

type Commodity int

const (
	NoCommodity Commodity = 0
	Sheep       Commodity = 1
	Brick       Commodity = 2
	Wood        Commodity = 3
	Stone       Commodity = 4
	Wheat       Commodity = 5
)

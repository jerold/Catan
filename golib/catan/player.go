package catan

type Player struct {
	ID        int
	Resources []Resource        // Resources in hand
	Cards     []DevelopmentCard //
	Pieces    []GamePiece       // Pieces in hand
}

type DevelopmentCard struct {
	// TODO: fill out development cards
}

type Resource struct {
	Type Commodity
}

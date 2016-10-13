package main

import (
	"io/ioutil"
	"strconv"
	"sync/atomic"

	"github.com/jerold/Catan/golib/catannet"
)

var lastID int32

func SaveGame(game *catannet.SaveGameRequest) (catannet.SaveGameResponse, error) {
	game.ID = atomic.AddInt32(&lastID, 1)
	data := make([]byte, game.Len())
	game.Serialize(data)
	// fmt.Printf("game board\n", game.Board.Pieces)
	// for _, p := range game.Board.Pieces {
	// 	fmt.Printf(" Piece: %d @ (%d,%d)\n", p.Piece.Type, p.Location.X, p.Location.Y)
	// }
	err := ioutil.WriteFile(saveFile(game.ID), data, 0655)
	return catannet.SaveGameResponse{
		ID: game.ID,
	}, err
}

func saveFile(id int32) string {
	return "storage/" + strconv.Itoa(int(id)) + ".save"
}

func LoadGame(id int32) (catannet.LoadGameResponse, error) {
	data, err := ioutil.ReadFile(saveFile(id))
	lgr := catannet.LoadGameResponse{
		ID:      id,
		Board:   &catannet.GameBoard{},
		Players: []*catannet.Player{},
	}
	if err != nil {
		return lgr, err
	}
	sgr := catannet.SaveGameRequestDeserialize(data)
	lgr.Board = sgr.Board
	lgr.Players = sgr.Players
	return lgr, nil
}

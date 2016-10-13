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

	err := ioutil.WriteFile(strconv.Itoa(int(game.ID))+".save", data, 0655)
	return catannet.SaveGameResponse{}, err
}

func LoadGame(id int32) (catannet.LoadGameResponse, error) {
	return catannet.LoadGameResponse{
		ID: id,
	}, nil
}

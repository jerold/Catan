package main

import "github.com/jerold/Catan/golib/catannet"

func SaveGame(game *catannet.SaveGame) (catannet.SaveGameResponse, error) {
	return catannet.SaveGameResponse{}, nil
}

func LoadGame(id int32) (catannet.LoadGameResponse, error) {
	return catannet.LoadGameResponse{}, nil
}

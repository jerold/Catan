package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"

	"github.com/jerold/Catan/golib/catannet"
	"github.com/jerold/Catan/golib/client"
)

type ServerState struct {
	sl       *ServerListeners
	lastID   int32
	gamerevs map[int32]int32
	gm       *sync.Mutex
}

// Listener subscriptions
// TODO: Turn this into a full live game instead of just a listener.
type ServerListeners struct {
	listeners map[int32][]*client.Client
	m         *sync.Mutex
}

func SaveGame(game *catannet.SaveGameRequest, ss *ServerState) (catannet.SaveGameResponse, error) {
	if game.ID.ID == 0 {
		game.ID.ID = atomic.AddInt32(&ss.lastID, 1)
	}
	if game.ID.Revision == 0 {
		ss.gm.Lock()
		if _, ok := ss.gamerevs[game.ID.ID]; !ok {
			ss.gm.Unlock()
			r := getSaveRev(game.ID)
			ss.gm.Lock()
			// If this is a new save, it will be -1
			ss.gamerevs[game.ID.ID] = r.Revision
		}
		ss.gamerevs[game.ID.ID]++
		game.ID.Revision = ss.gamerevs[game.ID.ID]
		ss.gm.Unlock()
	}
	data := make([]byte, game.Len())
	game.Serialize(data)
	err := ioutil.WriteFile(saveFile(game.ID), data, 0655)
	return catannet.SaveGameResponse{
		ID: game.ID,
	}, err
}

func saveFile(id catannet.GameID) string {
	return "storage/" + strconv.Itoa(int(id.ID)) + "." + strconv.Itoa(int(id.Revision)) + ".save"
}

func getSaveRev(id catannet.GameID) catannet.GameID {
	maxrev := -1
	err := filepath.Walk("storage/", func(path string, _ os.FileInfo, _ error) error {
		ext := filepath.Ext(path)
		if ext != "save" {
			return nil
		}
		name := filepath.Base(path)
		fnp := strings.Split(name, ".")
		rev, err := strconv.Atoi(fnp[1])
		if err != nil {
			return nil
		}
		if rev > maxrev {
			maxrev = rev
		}
		return nil
	})
	if err != nil {
		fmt.Printf("Failed to find revision: %s.\n", err)
		// Not sure what to do here
		return catannet.GameID{ID: -1, Revision: -1}
	}
	return catannet.GameID{ID: id.ID, Revision: int32(maxrev)}
}

func LoadGame(id catannet.GameID) (catannet.LoadGameResponse, error) {
	fn := saveFile(id)
	if id.Revision <= 0 {
		fn = saveFile(getSaveRev(id))
	}
	data, err := ioutil.ReadFile(fn)
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

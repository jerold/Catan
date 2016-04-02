// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class GameActions {
  Action<int> addTile = new Action<int>();
  Action<int> removeTile = new Action<int>();

  Action<Player> addPlayer = new Action<Player>();
  Action<Player> removePlayer = new Action<Player>();

  Action<bool> showNewGameModal = new Action<bool>();
  Action<String> changeGameState = new Action<String>();
  Action<String> changeEditState = new Action<String>();

  Action<Tile> changeActiveTile = new Action<Tile>();
  Action<int> changeActiveTileToken = new Action<int>();
  Action<TileType> changeActiveTileType = new Action<TileType>();

  Action<bool> setShowTileOverlay = new Action<bool>();
}

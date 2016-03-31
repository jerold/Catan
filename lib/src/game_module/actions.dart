// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class GameActions {
  Action<Coordinate> addTile = new Action<Coordinate>();
  Action<Coordinate> removeTile = new Action<Coordinate>();

  Action<Player> addPlayer = new Action<Player>();
  Action<Player> removePlayer = new Action<Player>();

  Action<bool> showNewGameModal = new Action<bool>();
  Action<String> changeGameState = new Action<String>();
  Action<String> changeEditState = new Action<String>();

  Action<Terrain> changeActiveTile = new Action<Terrain>();
  Action<int> changeActiveTileToken = new Action<int>();
  Action<TerrainType> changeActiveTileTerrainType = new Action<TerrainType>();

  Action<bool> setShowTileOverlay = new Action<bool>();
}

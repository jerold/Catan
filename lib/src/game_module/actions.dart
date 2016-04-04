// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class GameActions {
  w_flux.Action<int> addTile = new w_flux.Action<int>();
  w_flux.Action<int> removeTile = new w_flux.Action<int>();

  w_flux.Action<Player> addPlayer = new w_flux.Action<Player>();
  w_flux.Action<Player> removePlayer = new w_flux.Action<Player>();

  w_flux.Action<bool> showNewGameModal = new w_flux.Action<bool>();
  w_flux.Action<String> changeGameState = new w_flux.Action<String>();
  w_flux.Action<String> changeEditState = new w_flux.Action<String>();

  w_flux.Action<Tile> changeActiveTile = new w_flux.Action<Tile>();
  w_flux.Action<int> changeActiveTileRoll = new w_flux.Action<int>();
  w_flux.Action<TileType> changeActiveTileType = new w_flux.Action<TileType>();

  w_flux.Action<bool> setShowTileOverlay = new w_flux.Action<bool>();
}

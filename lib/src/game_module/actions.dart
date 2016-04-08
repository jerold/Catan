// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


class GameActions {
  w_flux.Action<int> addTile = new w_flux.Action<int>();
  w_flux.Action<int> removeTile = new w_flux.Action<int>();

  w_flux.Action<Player> addPlayer = new w_flux.Action<Player>();
  w_flux.Action<Player> removePlayer = new w_flux.Action<Player>();

  w_flux.Action<int> setActiveTileRoll = new w_flux.Action<int>();
  w_flux.Action<TileType> setActiveTileType = new w_flux.Action<TileType>();

  w_flux.Action<Tile> setActiveTile = new w_flux.Action<Tile>();
  w_flux.Action<int> setActivePlot = new w_flux.Action<int>();
  w_flux.Action<Player> setActivePlayer = new w_flux.Action<Player>();
  w_flux.Action<Point> setActivatePoint = new w_flux.Action<Point>();

  w_flux.Action<PlayerPieceType> buildOnActivePlot = new w_flux.Action<PlayerPieceType>();
  w_flux.Action moveThiefToActiveTile = new w_flux.Action();
  w_flux.Action<int> roll = new w_flux.Action<int>();

  w_flux.Action startNewGame = new w_flux.Action();

  // UI config actions

  w_flux.Action<EditState> setEditState = new w_flux.Action<EditState>();
  w_flux.Action<GameState> setGameState = new w_flux.Action<GameState>();

  w_flux.Action<DimmerType> showDimmer = new w_flux.Action<DimmerType>();
  w_flux.Action hideDimmer = new w_flux.Action();
}

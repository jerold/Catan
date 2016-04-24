// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


class GameActions {
  w_flux.Action<Point> setActivatePoint = new w_flux.Action<Point>();
  w_flux.Action<Player> setActivePlayer = new w_flux.Action<Player>();
  w_flux.Action<int> setActivePlotKey = new w_flux.Action<int>();
  w_flux.Action<int> setActiveTileKey = new w_flux.Action<int>();

  w_flux.Action startNewGame = new w_flux.Action();

  w_flux.Action<EditState> setEditState = new w_flux.Action<EditState>();
  w_flux.Action<GameState> setGameState = new w_flux.Action<GameState>();
  w_flux.Action<DimmerType> showDimmer = new w_flux.Action<DimmerType>();
  w_flux.Action hideDimmer = new w_flux.Action();
}

// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class GameActions {
  Action<Coordinate> addTile = new Action<Coordinate>();
  Action<Coordinate> changeTileType = new Action<Coordinate>();
  Action<Coordinate> removeTile = new Action<Coordinate>();

  Action<String> changeState = new Action<String>();
  Action<Terrain> changeActiveTile = new Action<Terrain>();
  Action<int> changeActiveTileHarvest = new Action<int>();
}

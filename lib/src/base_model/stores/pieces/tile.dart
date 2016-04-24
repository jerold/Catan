
// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


class Tile extends TilePiece {
  TileActions _actions = new TileActions();
  TileActions get actions => _actions;

  Terrain terrain = Terrain.Desert;
  int roll = 0;

  Resource get resource {
    switch(terrain) {
      case Terrain.Pasture:  return Resource.Sheep;
      case Terrain.Field:    return Resource.Wheat;
      case Terrain.Forest:   return Resource.Lumber;
      case Terrain.Hill:     return Resource.Brick;
      case Terrain.Mountain: return Resource.Ore;
      default:                return Resource.None;
    }
  }

  Tile(int key, {Terrain terrain, int roll}) : super(key) {
    this.terrain = terrain ?? this.terrain;
    this.roll = roll ?? this.roll;

    triggerOnAction(_actions.setRoll, _setRoll);
    triggerOnAction(_actions.setTerrain, _setTerrain);
  }

  _setRoll(int newRoll) => this.roll = roll ?? this.roll;

  _setTerrain(Terrain newTerrain) => this.terrain = newTerrain ?? this.terrain;
}

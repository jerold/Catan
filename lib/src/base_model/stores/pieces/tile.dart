
// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


class Tile extends TilePiece {
  TileActions _actions = new TileActions();
  TileActions get actions => _actions;

  Terrain terrain = Terrain.Desert;
  int roll = 0;

  Commodity get commodity {
    switch(terrain) {
      case Terrain.Pasture:  return Commodity.Sheep;
      case Terrain.Field:    return Commodity.Wheat;
      case Terrain.Forest:   return Commodity.Lumber;
      case Terrain.Hill:     return Commodity.Brick;
      case Terrain.Mountain: return Commodity.Ore;
      default:                return Commodity.None;
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

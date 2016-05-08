
// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


class Port extends TilePiece {
  Terrain terrain = Terrain.Desert;

  int facingIndex = 0;
  Direction get facing => DIRECTIONS[facingIndex];

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

  Port(int key, {Terrain terrain, int facingIndex}) : super(key) {
    this.terrain = terrain ?? this.terrain;
    this.facingIndex = facingIndex ?? this.facingIndex;
  }

  _rotate() => facingIndex = (facingIndex + 1) % DIRECTIONS.length;

  _setTerrain(Terrain newTerrain) => this.terrain = newTerrain ?? this.terrain;
}

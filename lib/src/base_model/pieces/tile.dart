
// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


enum Resource { None, Sheep, Wheat, Lumber, Brick, Ore }
List<Resource> get RESOURCES => Resource.values;

enum Terrain { Desert, Pasture, Field, Forest, Hill, Mountain }
List<Terrain> get TERRAINS => Terrain.values;


class Tile extends TilePiece {
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
  }
}


// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


enum ResourceType {
  None, Sheep, Wheat, Lumber, Brick, Ore,
}
List<ResourceType> get RESOURCE_TYPES => ResourceType.values;

enum TileType {
  Desert, Pasture, Field, Forest, Hill, Mountain,
}

List<TileType> get TILE_TYPES => TileType.values;

ResourceType yields(TileType type) {
  switch(type) {
    case TileType.Pasture:  return ResourceType.Sheep;
    case TileType.Field:    return ResourceType.Wheat;
    case TileType.Forest:   return ResourceType.Lumber;
    case TileType.Hill:     return ResourceType.Brick;
    case TileType.Mountain: return ResourceType.Ore;
    default:                return ResourceType.None;
  }
}


class Tile extends TilePiece {
  TileType type = TileType.Desert;
  int roll = 0;

  ResourceType get resource {
    switch(type) {
      case TileType.Pasture:  return ResourceType.Sheep;
      case TileType.Field:    return ResourceType.Wheat;
      case TileType.Forest:   return ResourceType.Lumber;
      case TileType.Hill:     return ResourceType.Brick;
      case TileType.Mountain: return ResourceType.Ore;
      default:                return ResourceType.None;
    }
  }

  Tile(int key, {TileType type, int roll}) : super(key) {
    this.type = type ?? this.type;
    this.roll = roll ?? this.roll;
  }
}

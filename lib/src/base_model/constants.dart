// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

List<int> defaultCoordinateKeys = [
  4139, 4038, 4141, 4042, 3839,
  3841, 4338, 4137, 4340, 4040,
  4036, 3837, 4342, 4143, 4044,
  3843, 3738, 3740, 3742
];

List<int> standardDealKeys = [
  3742, 3740, 3738, 3837, 4036, 4137, 4338, 4340, 4342, 4143,
  4044, 3843, 3841, 3839, 4038, 4139, 4141, 4042, 4040
];

List<TileType> defaultTiles = [
  TileType.Desert,
  TileType.Pasture, TileType.Pasture, TileType.Pasture, TileType.Pasture,
  TileType.Field, TileType.Field, TileType.Field, TileType.Field,
  TileType.Forest, TileType.Forest, TileType.Forest, TileType.Forest,
  TileType.Hill, TileType.Hill, TileType.Hill,
  TileType.Mountain, TileType.Mountain, TileType.Mountain,
];

List<int> defaultTokens = [
  2,
  3, 3,
  4, 4,
  5, 5,
  6, 6,
  8, 8,
  9, 9,
  10, 10,
  11, 11,
  12,
];

List<int> standardOrderTokens = [
  5, 2, 6, 3, 8, 10, 9, 12, 11, 4, 8,
  10, 9, 4, 5, 6, 3, 11,
];

List<int> chanceList = [1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1];

int chances(int roll) => roll >= 2 && roll <= 12 ? chanceList[roll - 2] : 0;

num probability(int roll) => chances(roll) / 36;

enum Direction {
  NorthEast, East, SouthEast, SouthWest, West, NorthWest,
}

enum CoordinateType {
  Plot,
  Tile,
}

String coordinateTypeString(CoordinateType type) => type == CoordinateType.Plot ? 'Plot' : 'Tile';

const String TileStringDesert = 'D';
const String TileStringPasture = 'P';
const String TileStringField = 'F';
const String TileStringForest = 'L';
const String TileStringHill = 'H';
const String TileStringMountain = 'M';

enum TileType {
  Desert, Pasture, Field, Forest, Hill, Mountain,
}
enum ResourceType {
  None, Sheep, Wheat, Lumber, Brick, Ore,
}

ResourceType yields(TileType type) {
  switch(type) {
    case TileType.Pasture:
      return ResourceType.Sheep;
    case TileType.Field:
      return ResourceType.Wheat;
    case TileType.Forest:
      return ResourceType.Lumber;
    case TileType.Hill:
      return ResourceType.Brick;
    case TileType.Mountain:
      return ResourceType.Ore;
    default:
      return ResourceType.None;
  }
}

String stringFromTileType(TileType type) {
  switch(type) {
    case TileType.Pasture:
      return TileStringPasture;
    case TileType.Field:
      return TileStringField;
    case TileType.Forest:
      return TileStringForest;
    case TileType.Hill:
      return TileStringHill;
    case TileType.Mountain:
      return TileStringMountain;
    default:
      return TileStringDesert;
  }
}

String stringFromResourceType(ResourceType type) {
  switch(type) {
    case ResourceType.Brick:
      return 'Brick';
    case ResourceType.Lumber:
      return 'Lumber';
    case ResourceType.Ore:
      return 'Ore';
    case ResourceType.Sheep:
      return 'Sheep';
    case ResourceType.Wheat:
      return 'Wheat';
    default:
      return 'Unknown';
  }
}

TileType tileTypeFromString(String typeString) {
  switch(typeString) {
    case TileStringPasture:
      return TileType.Pasture;
    case TileStringField:
      return TileType.Field;
    case TileStringForest:
      return TileType.Forest;
    case TileStringHill:
      return TileType.Hill;
    case TileStringMountain:
      return TileType.Mountain;
    default:
      return TileType.Desert;
  }
}

const String PlayerColorRed = 'red';
const String PlayerColorBlue = 'blue';
const String PlayerColorGrey = 'grey';
const String PlayerColorOrange = 'orange';
const String PlayerColorGreen = 'green';
const String PlayerColorBrown = 'brown';

List<String> PlayerColors = [
  PlayerColorRed, PlayerColorBlue, PlayerColorGrey,
  PlayerColorOrange, PlayerColorGreen, PlayerColorBrown,
];

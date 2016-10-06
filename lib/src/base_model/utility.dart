part of catan.base_model;

enum Commodity { Unknown, Sheep, Wheat, Lumber, Brick, Ore }
List<Commodity> get COMMODITIES => Commodity.values;
List<Commodity> get KNOWN_COMMODITIES => [
      Commodity.Sheep,
      Commodity.Wheat,
      Commodity.Lumber,
      Commodity.Brick,
      Commodity.Ore
    ];

enum Terrain { Desert, Pasture, Field, Forest, Hill, Mountain }
List<Terrain> get TERRAINS => Terrain.values;

enum PieceType { Edge, Plot, Tile }
const List<PieceType> PIECE_TYPES = PieceType.values;

enum GamePieceType { City, Port, Road, Settlement, Tile }
const List<GamePieceType> GAME_PIECE_TYPES = GamePieceType.values;

int MAX_ROADS = 15;
int MAX_SETTLEMENTS = 5;
int MAX_CITIES = 4;

int EXCEED_TO_ACTIVATE_THE_THIEF = 7;

final Map<GamePieceType, Map<Commodity, int>> RATES =
    new Map<GamePieceType, Map<Commodity, int>>()
      ..[GamePieceType.Road] = {
        Commodity.Lumber: 1,
        Commodity.Brick: 1,
      }
      ..[GamePieceType.Settlement] = {
        Commodity.Lumber: 1,
        Commodity.Brick: 1,
        Commodity.Wheat: 1,
        Commodity.Sheep: 1,
      }
      ..[GamePieceType.City] = {
        Commodity.Ore: 3,
        Commodity.Wheat: 2,
      };

List<int> defaultCoordinateKeys = [
  4139,
  4038,
  4141,
  4042,
  3839,
  3841,
  4338,
  4137,
  4340,
  4040,
  4036,
  3837,
  4342,
  4143,
  4044,
  3843,
  3738,
  3740,
  3742
];

List<int> standardDealKeys = [
  3742,
  3740,
  3738,
  3837,
  4036,
  4137,
  4338,
  4340,
  4342,
  4143,
  4044,
  3843,
  3841,
  3839,
  4038,
  4139,
  4141,
  4042,
  4040
];

List<int> standardPortKeys = [
  4034,
  4336,
  4439,
  4443,
  4145,
  3845,
  3543,
  3539,
  3736,
];

List<int> standardPortFacings = [
  -3,
  -4,
  -4,
  -5,
  -6,
  -6,
  -1,
  -2,
  -2,
];

List<Terrain> standardPortTerrains = [
  Terrain.Desert,
  Terrain.Pasture,
  Terrain.Desert,
  Terrain.Desert,
  Terrain.Hill,
  Terrain.Forest,
  Terrain.Desert,
  Terrain.Field,
  Terrain.Mountain,
];

List<Terrain> defaultTiles = [
  Terrain.Desert,
  Terrain.Pasture,
  Terrain.Pasture,
  Terrain.Pasture,
  Terrain.Pasture,
  Terrain.Field,
  Terrain.Field,
  Terrain.Field,
  Terrain.Field,
  Terrain.Forest,
  Terrain.Forest,
  Terrain.Forest,
  Terrain.Forest,
  Terrain.Hill,
  Terrain.Hill,
  Terrain.Hill,
  Terrain.Mountain,
  Terrain.Mountain,
  Terrain.Mountain,
];

List<int> defaultTokens = [
  2,
  3,
  3,
  4,
  4,
  5,
  5,
  6,
  6,
  8,
  8,
  9,
  9,
  10,
  10,
  11,
  11,
  12,
];

List<int> standardOrderTokens = [
  5,
  2,
  6,
  3,
  8,
  10,
  9,
  12,
  11,
  4,
  8,
  10,
  9,
  4,
  5,
  6,
  3,
  11,
];

List<int> chanceList = [1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1];

int chances(int roll) => roll >= 2 && roll <= 12 ? chanceList[roll - 2] : 0;

num probability(int roll) => chances(roll) / 36;

class CommodityPayload {
  final int count;
  final Commodity commodity;

  CommodityPayload(this.count, this.commodity);
}

class PurchasePayload {
  final int key;
  final GamePieceType piece;
  final Player player;

  PurchasePayload(this.key, this.piece, this.player);
}

String coordinateTypeString(CoordinateType type) =>
    type == CoordinateType.Plot ? 'Plot' : 'Tile';

const String TileStringDesert = 'D';
const String TileStringPasture = 'P';
const String TileStringField = 'F';
const String TileStringForest = 'L';
const String TileStringHill = 'H';
const String TileStringMountain = 'M';

String stringFromTerrain(Terrain type) {
  switch (type) {
    case Terrain.Pasture:
      return TileStringPasture;
    case Terrain.Field:
      return TileStringField;
    case Terrain.Forest:
      return TileStringForest;
    case Terrain.Hill:
      return TileStringHill;
    case Terrain.Mountain:
      return TileStringMountain;
    default:
      return TileStringDesert;
  }
}

String stringFromCommodity(Commodity type) {
  switch (type) {
    case Commodity.Brick:
      return 'Brick';
    case Commodity.Lumber:
      return 'Lumber';
    case Commodity.Ore:
      return 'Ore';
    case Commodity.Sheep:
      return 'Sheep';
    case Commodity.Wheat:
      return 'Wheat';
    default:
      return 'Unknown';
  }
}

Terrain tileTypeFromString(String typeString) {
  switch (typeString) {
    case TileStringPasture:
      return Terrain.Pasture;
    case TileStringField:
      return Terrain.Field;
    case TileStringForest:
      return Terrain.Forest;
    case TileStringHill:
      return Terrain.Hill;
    case TileStringMountain:
      return Terrain.Mountain;
    default:
      return Terrain.Desert;
  }
}

const String PlayerColorRed = 'red';
const String PlayerColorBlue = 'blue';
const String PlayerColorGrey = 'grey';
const String PlayerColorOrange = 'orange';
const String PlayerColorGreen = 'green';
const String PlayerColorBrown = 'brown';

List<String> PlayerColors = [
  PlayerColorRed,
  PlayerColorBlue,
  PlayerColorGrey,
  PlayerColorOrange,
  PlayerColorGreen,
  PlayerColorBrown,
];

// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


enum PlayerPieceType { Road, Settlement, City }
int MAX_ROADS = 15;
int MAX_SETTLEMENTS = 5;
int MAX_CITIES = 4;
const List<PlayerPieceType> PLAYER_PIECE_TYPES = PlayerPieceType.values;

class Player {
  int _colorIndex = 0;
  String get color => PlayerColors[_colorIndex];

  Map<PlayerPieceType, Map<int, Piece>> _buildings = new Map<PlayerPieceType, Map<int, Piece>>();

  Map<int, Piece> get roads => _buildings[PlayerPieceType.Road];
  Map<int, Piece> get settlements => _buildings[PlayerPieceType.Settlement];
  Map<int, Piece> get cities => _buildings[PlayerPieceType.City];

  Map<ResourceType, int> _resources = new Map<ResourceType, int>();
  Map<ResourceType, int> get resources => new Map<ResourceType, int>.from(_resources);

  Player(String color) {
    changeColor(color);

    RESOURCE_TYPES.forEach((type) {
      _resources[type] = 5;
    });

    PLAYER_PIECE_TYPES.forEach((type) {
      _buildings[type] = new Map<int, Piece>();
    });
  }

  void changeColor([String color]) {
    if (color != null) _colorIndex = PlayerColors.indexOf(color);
    else _colorIndex = (_colorIndex + 1) % PlayerColors.length;
  }

  // Resource Helpers

  void addResource(int count, ResourceType resource) {
    _resources[resource] = _resources[resource] + count;
  }

  bool hasResource(int count, ResourceType resource) => _resources[resource] >= count;

  int resourceCount(ResourceType resource) => _resources[resource];

  void removeResource(int count, ResourceType resource) {
    _resources[resource] = _resources[resource] - count;
  }

  // PlayerPiece Helpers

  void addPiece(int key, PlayerPieceType piece) {
    switch(piece) {
      case PlayerPieceType.Road:
        _buildings[piece][key] = new Road(key);
        break;
      case PlayerPieceType.Settlement:
        _buildings[piece][key] = new Settlement(key);
        break;
      case PlayerPieceType.City:
        _buildings[piece][key] = new City(key);
        break;
    }
  }

  Piece getPiece(int key, [PlayerPieceType piece]) {
    if (piece != null) return _buildings[piece][key];

    Piece foundPiece;
    _buildings.forEach((buildingType, buildingMap) {
      if (buildingMap.containsKey(key)) foundPiece = buildingMap[key];
    });
    return foundPiece;
  }

  void removePiece(int key, PlayerPieceType piece) {
    _buildings[piece].remove(key);
  }

  // TODO: Account for longest road & biggest army & VP cards
  int score() => settlements.length + cities.length * 2;

  int get handCount => resources.values.reduce((int prev, int next) => prev + next);
}

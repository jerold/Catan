// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


enum PlayerPieceType { Road, Settlement, City }
int MAX_ROADS = 15;
int MAX_SETTLEMENTS = 5;
int MAX_CITIES = 4;

class Player {
  int _colorIndex = 0;
  String get color => PlayerColors[_colorIndex];

  List<Road> roads = new List<Road>();
  List<Settlement> settlements = new List<Settlement>();
  List<City> cities = new List<City>();

  Map<ResourceType, int> resources = new Map<ResourceType, int>();

  Player(String color) {
    changeColor(color);
    RESOURCE_TYPES.forEach((type) {
      resources[type] = 0;
    });
  }

  void changeColor([String color]) {
    if (color != null) _colorIndex = PlayerColors.indexOf(color);
    else _colorIndex = (_colorIndex + 1) % PlayerColors.length;
  }

  void addResource(ResourceType type, int cnt) {
    resources[type] = resources[type] + cnt;
  }

  void removeResource(ResourceType type, int cnt) {
    resources[type] = resources[type] - cnt;
  }

  void give(ResourceType resource, int count) {
    resources[resource] = resources[resource] + count;
  }

  bool has(ResourceType resource, int count) => resources[resource] >= count;

  void take(ResourceType resource, int count) {
    resources[resource] = resources[resource] - count;
  }

  // TODO: Account for longest road & biggest army & VP cards
  int score() => settlements.length + cities.length * 2;

  int get handCount => resources.values.reduce((int prev, int next) => prev + next);
}

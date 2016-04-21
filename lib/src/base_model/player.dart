// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


class Player {
  int _colorIndex = 0;
  String get color => PlayerColors[_colorIndex];

  Map<Resource, int> _resources = new Map<Resource, int>();
  Map<Resource, int> get resources => new Map<Resource, int>.from(_resources);

  Player(String color) {
    changeColor(color);

    // start with no resources
    RESOURCES.forEach((resource) {
      _resources[resource] = 0;
    });

    // Add initial funds required to buy two settlements
    RATES[GamePieceType.Settlement].forEach((resource, count) {
      _resources[resource] = count * 2;
    });
  }

  void changeColor([String color]) {
    if (color != null) _colorIndex = PlayerColors.indexOf(color);
    else _colorIndex = (_colorIndex + 1) % PlayerColors.length;
  }

  // Resource Helpers

  void addResource(int count, Resource resource) {
    _resources[resource] = _resources[resource] + count;
  }

  bool hasResource(int count, Resource resource) => _resources[resource] >= count;

  int resourceCount(Resource resource) => _resources[resource];

  void removeResource(int count, Resource resource) {
    _resources[resource] = _resources[resource] - count;
  }

  int get handCount => resources.values.reduce((int prev, int next) => prev + next);
}

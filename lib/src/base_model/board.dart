// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


class Board {
  Map<int, Tile> tiles = new Map<int, Tile>();
  int thiefKey;
  List<Player> players = new List<Player>();

  Economy economy;

  // Tile Dependent Caches
  Set<int> _cachedExpansionTiles = new Set<int>();
  Set<int> _cachedPlots = new Set<int>();
  Map<ResourceType, List<Tile>> _cachedTilesWithResource = new Map<ResourceType, List<Tile>>();
  Map<ResourceType, int> _cachedResourceChances = new Map<ResourceType, int>();
  Map<int, int> _cachedPlotUtilities = new Map<int, int>();

  // Tile AND Building Dependent Caches
  Map<Player, Set<int>> _cachedHandyPlots = new Map<Player, Set<int>>();
  Map<Player, Set<int>> _cachedHandyEdges = new Map<Player, Set<int>>();
  Set<int> _cachedOpenPlots = new Set<int>();
  Set<int> _cachedBlockedPlots = new Set<int>();
  Statistic _plotUtilityStats = new Statistic(); // stats limited to open plots

  List<int> get expansionTiles => new List<int>.from(_cachedExpansionTiles);
  List<int> get plots => new List<int>.from(_cachedPlots);

  Board(List<int> keys, [List<TileType> types, List<int> rolls]) {
    types = types ?? new List<TileType>();
    rolls = rolls ?? new List<int>();

    economy = new Economy(this);

    Coordinate.clear();
    Edge.clear();

    tiles = new Map<int, Tile>();
    players = new List<Player>();

    addPlayer(new Player(PlayerColorRed));
    addPlayer(new Player(PlayerColorGrey));
    addPlayer(new Player(PlayerColorBlue));

    int typeIndex = 0;
    int rollIndex = 0;
    keys.forEach((key) {
      TileType type = typeIndex < types.length ? types[typeIndex] : null;
      int roll = rollIndex < rolls.length ? rolls[rollIndex] : null;;
      tiles[key] = new Tile(key, type: type, roll: roll);
      if (type == TileType.Desert) {
        if (roll == 0) rollIndex++;
        tiles[key].roll = 0;
        thiefKey = key;
      } else {
        rollIndex++;
      }
      typeIndex++;
    });
    _updateTileDependentCaches();
  }

  factory Board.standard() => new Board(
    standardDealKeys,
    new List<TileType>.from(defaultTiles)..shuffle(),
    standardOrderTokens
  );

  factory Board.empty() => new Board(standardDealKeys);

  // Change Map

  bool addTile(int key) {
    if (!tiles.containsKey(key)) {
      tiles[key] = new Tile(key);
      _updateTileDependentCaches();
      return true;
    }
    return false;
  }

  void changeTile(int key, {TileType newType, int newRoll}) {
    if (newType != null) tiles[key].type = newType;
    if (newRoll != null) tiles[key].roll = newRoll;
    _updateTileDependentCaches();
  }

  bool removeTile(int key) {
    if (tiles.containsKey(key)) {
      tiles.remove(key);
      _updateTileDependentCaches();
      return true;
    }
    return false;
  }

  // Change Players

  bool addPlayer(Player player) {
    if (!players.contains(player)) {
      players.add(player);
      return true;
    }
    return false;
  }

  bool removePlayer(Player player) {
    if (players.contains(player)) {
      players.remove(player);
      return true;
    }
    return false;
  }

  bool playerInGame(String playerColor) {
    bool playerFound = false;
    players.forEach((player) {
      if (player.color == playerColor) playerFound = true;
    });
    return playerFound;
  }

  // Utility Methods

  Statistic plotUtilityStats() => _plotUtilityStats;

  int utilityOfPlot(int key) => _cachedPlotUtilities[key];

  List<Tile> tilesWithResource(ResourceType type) => new List<Tile>.from(_cachedTilesWithResource[type]);

  int resourceChances(ResourceType type) => _cachedResourceChances[type];

  List<int> handyPlots(Player player) => new List<int>.from(_cachedHandyPlots[player]);

  List<int> handyEdges(Player player) => new List<int>.from(_cachedHandyEdges[player]);

  List<int> openPlots() => new List<int>.from(_cachedOpenPlots);

  List<int> blockedPlots() => new List<int>.from(_cachedBlockedPlots);

  _updateTileDependentCaches() {
    _cachedExpansionTiles.clear();
    _cachedPlots.clear();
    _cachedPlotUtilities.clear();
    _cachedTilesWithResource.clear();
    _cachedResourceChances.clear();

    // init empty tiles-with-resources maps
    RESOURCE_TYPES.forEach((type) {
      _cachedTilesWithResource[type] = new List<Tile>();
      _cachedResourceChances[type] = 0;
    });

    // update _cachedTilesWithResource, _cachedExpansionTiles, and _cachedPlots
    tiles.forEach((_, tile) {
      _cachedExpansionTiles.addAll(tile.neighbors(PieceType.Tile));
      _cachedPlots.addAll(tile.neighbors(PieceType.Plot));
      _cachedTilesWithResource[tile.resource].add(tile);
    });
    _cachedExpansionTiles.removeAll(tiles.keys);

    // update _cachedResourceChances
    RESOURCE_TYPES.forEach((type) {
      _cachedResourceChances[type] = _cachedTilesWithResource[type].fold(0, (sum, next) => sum + chances(next.roll));
    });

    // update _cachedPlotUtilities
    _cachedPlots.forEach((key) {
      Coordinate coord = Coordinate.fromKey(key);
      List<Tile> nTiles = new List<Tile>.from(coord.neighbors(ofType: CoordinateType.Tile)
        .values.where((tKey) {
          return tiles.containsKey(tKey);
        }).map((key) => tiles[key])
      );
      _cachedPlotUtilities[key] = nTiles.fold(0, (sum, tile) => sum + chances(tile.roll));
    });

    _updateBuildingDependentCaches();
  }

  _updateBuildingDependentCaches() {
    _plotUtilityStats.clear();
    _cachedBlockedPlots.clear();
    _cachedOpenPlots.clear();
    _cachedHandyEdges.clear();
    _cachedHandyPlots.clear();

    // update _cachedBlockedPlots
    players.forEach((player) {
      List<Building> buildings = new List<Building>();
      buildings.addAll(new List<Building>.from(player.settlements.values));
      buildings.addAll(new List<Building>.from(player.cities.values));
      buildings.forEach((building) {
        _cachedBlockedPlots.add(building.key);
        _cachedBlockedPlots.addAll(building.neighbors(PieceType.Plot));
      });
    });
    _cachedBlockedPlots = _cachedBlockedPlots.intersection(_cachedPlots);

    // update _cachedOpenPlots
    _cachedOpenPlots = new Set<int>.from(_cachedPlots);
    _cachedOpenPlots.removeAll(_cachedBlockedPlots);

    // update _plotUtilityStats
    _cachedOpenPlots.forEach((key) {
      _plotUtilityStats.add(_cachedPlotUtilities[key]);
    });

    // update _cachedHandyPlots AND _cachedHandyEdges
    players.forEach((player) {
      _cachedHandyPlots[player] = new Set<int>();
      _cachedHandyEdges[player] = new Set<int>();
      player.roads.forEach((rKey, road) {
        road.edge.ends().forEach((end) {
          _cachedHandyPlots[player].add(end.key);
          end.neighbors(ofType: CoordinateType.Plot).forEach((_, key) {
            if (plots.contains(key)) {
              _cachedHandyEdges[player].add(Edge.getKey(end.key, key));
            }
          });
        });
        _cachedHandyPlots[player].addAll(road.edge.ends().map((end) => end.key));
      });
      blockedPlots().forEach((key) => _cachedHandyPlots[player].remove(key));
    });
  }
}

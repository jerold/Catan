// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


class Board {
  Map<int, Tile> tiles = new Map<int, Tile>();
  Thief thief;
  List<Player> players = new List<Player>();

  Statistic _plotUtilityStats = new Statistic();
  Set<int> _cachedExpansionTiles = new Set<int>();
  Set<int> _cachedPlots = new Set<int>();
  Map<int, int> _cachedPlotUtilities = new Map<int, int>();
  Map<ResourceType, List<Tile>> _cachedTilesWithResource = new Map<ResourceType, List<Tile>>();
  Map<ResourceType, int> _cachedResourceChances = new Map<ResourceType, int>();

  List<int> get expansionTiles => new List<int>.from(_cachedExpansionTiles);
  List<int> get plots => new List<int>.from(_cachedPlots);

  Board(List<int> keys, [List<TileType> types, List<int> rolls]) {
    types = types ?? new List<TileType>();
    rolls = rolls ?? new List<int>();

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
        thief = new Thief(key);
      } else {
        rollIndex++;
      }
      typeIndex++;
    });
    _updateCache();
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
      _updateCache();
      return true;
    }
    return false;
  }

  void changeTile(int key, {TileType newType, int newRoll}) {
    if (newType != null) tiles[key].type = newType;
    if (newRoll != null) tiles[key].roll = newRoll;
    _updateCache();
  }

  bool removeTile(int key) {
    if (tiles.containsKey(key)) {
      tiles.remove(key);
      _updateCache();
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

  _updateCache() {
    _plotUtilityStats.clear();
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
      _plotUtilityStats.add(_cachedPlotUtilities[key]);
    });
  }
}

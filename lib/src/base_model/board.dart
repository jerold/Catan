// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


class Board {
  Map<PieceType, Map<int, Piece>> _pieces;

  Map<int, EdgePiece> get edges => _pieces[PieceType.Edge]; // roads
  Map<int, PlotPiece> get plots => _pieces[PieceType.Plot]; // buildings
  Map<int, TilePiece> get tiles => _pieces[PieceType.Tile]; // tiles and ports

  List<Player> players;

  int thiefKey;

  Economy economy;

  // Tile Dependent Caches
  Set<int> _cachedExpansionTiles = new Set<int>();
  Set<int> _cachedPlots = new Set<int>();
  Map<Resource, List<Tile>> _cachedTilesWithResource = new Map<Resource, List<Tile>>();
  Map<Resource, int> _cachedResourceChances = new Map<Resource, int>();
  Map<int, int> _cachedPlotUtilities = new Map<int, int>();

  // Tile AND Building Dependent Caches
  Map<Player, Set<int>> _cachedHandyPlots = new Map<Player, Set<int>>();
  Map<Player, Set<int>> _cachedHandyEdges = new Map<Player, Set<int>>();
  Set<int> _cachedOpenPlots = new Set<int>();
  Set<int> _cachedBlockedPlots = new Set<int>();
  Statistic _plotUtilityStats = new Statistic(); // stats limited to open plots

  List<int> get expansionTiles => new List<int>.from(_cachedExpansionTiles);
  // List<int> get plots => new List<int>.from(_cachedPlots);

  Board(List<int> keys, [List<Terrain> terrains, List<int> rolls]) {
    terrains = terrains ?? new List<Terrain>();
    rolls = rolls ?? new List<int>();

    economy = new Economy(this);

    Coordinate.clear();
    Edge.clear();

    _pieces = new Map<PieceType, Map<int, Piece>>();
    _pieces[PieceType.Edge] = new Map<int, EdgePiece>();
    _pieces[PieceType.Plot] = new Map<int, PlotPiece>();
    _pieces[PieceType.Tile] = new Map<int, TilePiece>();

    players = new List<Player>();

    addPlayer(new Player(PlayerColorRed));
    addPlayer(new Player(PlayerColorGrey));
    addPlayer(new Player(PlayerColorBlue));

    int terrainIndex = 0;
    int rollIndex = 0;
    keys.forEach((key) {
      Terrain terrain = terrainIndex < terrains.length ? terrains[terrainIndex] : null;
      int roll = rollIndex < rolls.length ? rolls[rollIndex] : null;;
      tiles[key] = new Tile(key, terrain: terrain, roll: roll);
      if (terrain == Terrain.Desert) {
        if (roll == 0) rollIndex++;
        (tiles[key] as Tile).roll = 0;
        thiefKey = key;
      } else {
        rollIndex++;
      }
      terrainIndex++;
    });
    _updateTileDependentCaches();
  }

  factory Board.standard() => new Board(
    standardDealKeys,
    new List<Terrain>.from(defaultTiles)..shuffle(),
    standardOrderTokens
  );

  factory Board.empty() => new Board(standardDealKeys);

  // Change Map

  void changeTile(int key, {Terrain terrain, int roll}) {
    if (terrain != null) (tiles[key] as Tile).terrain = terrain;
    if (roll != null) (tiles[key] as Tile).roll = roll;
    _updateTileDependentCaches();
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

  // Change Pieces

  addPiece(Piece piece) {
    _pieces[piece.type][piece.key] = piece;
    _updateTileDependentCaches();
  }

  removePiece(Piece piece) {
    _pieces[piece.type].remove(piece.key);
    _updateTileDependentCaches();
  }

  // Utility Methods

  Statistic plotUtilityStats() => _plotUtilityStats;

  int utilityOfPlot(int key) => _cachedPlotUtilities[key];

  List<Tile> tilesWithResource(Resource type) => new List<Tile>.from(_cachedTilesWithResource[type]);

  int resourceChances(Resource type) => _cachedResourceChances[type];

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
    RESOURCES.forEach((resource) {
      _cachedTilesWithResource[resource] = new List<Tile>();
      _cachedResourceChances[resource] = 0;
    });

    // update _cachedTilesWithResource, _cachedExpansionTiles, and _cachedPlots
    tiles.forEach((_, tile) {
      _cachedExpansionTiles.addAll(tile.neighbors(PieceType.Tile));
      _cachedPlots.addAll(tile.neighbors(PieceType.Plot));
      _cachedTilesWithResource[tile.resource].add(tile);
    });
    _cachedExpansionTiles.removeAll(tiles.keys);

    // update _cachedResourceChances
    RESOURCES.forEach((resource) {
      _cachedResourceChances[resource] = _cachedTilesWithResource[resource].fold(0, (sum, next) => sum + chances(next.roll));
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
    plots.forEach((pKey, plot) {
      _cachedBlockedPlots.add(pKey);
      _cachedBlockedPlots.addAll(plot.neighbors(PieceType.Plot));
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
    });
    edges.forEach((eKey, edge) {
      if (edge is Road) {
        Road road = edge;
        road.edge.ends().forEach((end) {
          _cachedHandyPlots[road.owner].add(end.key);
          end.neighbors(ofType: CoordinateType.Plot).forEach((_, key) {
            if (_cachedOpenPlots.contains(key)) {
              _cachedHandyEdges[road.owner].add(Edge.getKey(end.key, key));
            }
          });
        });
        _cachedHandyPlots[road.owner].addAll(road.edge.ends().map((end) => end.key));
      }
    });
    players.forEach((player) {
      blockedPlots().forEach((key) => _cachedHandyPlots[player].remove(key));
    });
  }
}

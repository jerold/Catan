// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


class Board extends w_flux.Store {
  BoardActions _actions = new BoardActions();
  BoardActions get actions => _actions;

  Map<PieceType, Map<int, Piece>> _pieces;

  Map<int, EdgePiece> get edges => _pieces[PieceType.Edge]; // roads, boats
  Map<int, PlotPiece> get plots => _pieces[PieceType.Plot]; // buildings
  Map<int, TilePiece> get tiles => _pieces[PieceType.Tile]; // tiles, thief, and ports

  int _activeKey;
  int get activeKey => _activeKey;

  Piece get activePiece {
    if (edges.containsKey(_activeKey)) return edges[_activeKey];
    if (plots.containsKey(_activeKey)) return plots[_activeKey];
    if (tiles.containsKey(_activeKey)) return tiles[_activeKey];
    return null;
  }

  List<Player> players;

  Player _activePlayer;
  Player get activePlayer => _activePlayer;

  Point _interactionPoint;
  Point get interactionPoint => _interactionPoint;

  int _thiefKey;
  int get thiefKey => _thiefKey;

  Economy economy;

  Rectangle _boundingRect = new Rectangle(0, 0, 0, 0);
  Rectangle get boundingRect => _boundingRect;

  // Tile Dependent Caches
  Set<int> _cachedExpansionTiles = new Set<int>();
  Set<int> _cachedPlots = new Set<int>();
  Map<Commodity, List<Tile>> _cachedTilesWithCommodity = new Map<Commodity, List<Tile>>();
  Map<Commodity, int> _cachedCommodityChances = new Map<Commodity, int>();
  Map<int, int> _cachedPlotUtilities = new Map<int, int>();

  // Tile AND Building Dependent Caches
  Map<Player, Set<int>> _cachedHandyPlots = new Map<Player, Set<int>>();
  Map<Player, Set<int>> _cachedHandyEdges = new Map<Player, Set<int>>();
  Set<int> _cachedOpenPlots = new Set<int>();
  Set<int> _cachedBlockedPlots = new Set<int>();
  Statistic _plotUtilityStats = new Statistic(); // stats limited to open plots
  Map<Player, Map<Commodity, int>> _cachedCommoditiesExposed = new Map<Player, Map<Commodity, int>>();

  List<int> get expansionTiles => new List<int>.from(_cachedExpansionTiles);

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

    int terrainIndex = 0;
    int rollIndex = 0;
    keys.forEach((key) {
      Terrain terrain = terrainIndex < terrains.length ? terrains[terrainIndex] : null;
      int roll = rollIndex < rolls.length ? rolls[rollIndex] : null;;
      tiles[key] = new Tile(key, terrain: terrain, roll: roll);
      if (terrain == Terrain.Desert) {
        if (roll == 0) rollIndex++;
        (tiles[key] as Tile).roll = 0;
        _thiefKey = key;
      } else {
        rollIndex++;
      }
      terrainIndex++;
    });

    triggerOnAction(_actions.addPiece, _addPiece);
    triggerOnAction(_actions.removePiece, _removePiece);
    triggerOnAction(_actions.addPlayer, _addPlayer);
    triggerOnAction(_actions.removePlayer, _removePlayer);

    triggerOnAction(_actions.setActiveKey, _setActiveKey);
    triggerOnAction(_actions.setActivePlayer, _setActivePlayer);

    triggerOnAction(_actions.setActiveTileRoll, _setActiveTileRoll);
    triggerOnAction(_actions.setActiveTileTerrain, _setActiveTileTerrain);

    triggerOnAction(_actions.purchase, _purchase);
    triggerOnAction(_actions.harvest, _harvest);
    triggerOnAction(_actions.moveThief, _moveThief);
    triggerOnAction(_actions.roll, _roll);

    _updateTileDependentCaches();
  }

  factory Board.standard() => new Board(
    standardDealKeys,
    new List<Terrain>.from(defaultTiles)..shuffle(),
    standardOrderTokens
  );

  factory Board.empty() => new Board(standardDealKeys);

  // Change Players

  _addPlayer(Player player) => players.add(player);

  _removePlayer(Player player) {
    players.remove(player);
    _removeAllPlayerPieces(player);
  }

  // Change Pieces

  _addPiece(Piece piece) {
    _pieces[piece.type][piece.key] = piece;
    _updateTileDependentCaches();
  }

  _removePiece(Piece piece, [bool updateCache = true]) {
    _pieces[piece.type].remove(piece.key);
    if (updateCache) _updateTileDependentCaches();
  }

  // Active Key

  _setActiveKey(int key) => _activeKey = key;

  _setActivePlayer(Player player) => _activePlayer = player;

  _setActiveTileRoll(int roll) {
    if (activePiece is Tile) (activePiece as Tile)._setRoll(roll);
    _updateTileDependentCaches();
  }

  _setActiveTileTerrain(Terrain terrain) {
    if (activePiece is Tile) (activePiece as Tile)._setTerrain(terrain);
    _updateTileDependentCaches();
  }

  // Board Actions

  _purchase(PurchasePayload payload) {
    if (economy.canBuy(payload.piece, payload.player)) {
      economy.doBuy(payload.piece, payload.key, payload.player);
    } else {
      print('WARNING!!! Player ${payload.player.color} can not afford a ${payload.piece}');
    }
  }

  _harvest(Building building) => economy.doInitialHarvest(building);

  _moveThief(int newKey) {
    _thiefKey = newKey ?? _thiefKey;
    _updateBuildingDependentCaches();
  }

  _roll(int roll) => economy.doRoll(roll);

  // Utility Methods

  _removeAllPlayerPieces(Player player) {
    List<Piece> toRemove = new List<Piece>();
    PIECE_TYPES.forEach((pieceType) {
      _pieces[pieceType].forEach((pKey, piece) {
        if (piece is Owned && piece.owner == player) toRemove.add((piece as Piece));
      });
    });
    if (toRemove.length > 0) {
      toRemove.forEach((piece) {
        _removePiece(piece, false);
      });
      _updateTileDependentCaches();
    }
  }

  bool playerInGame(String playerColor) {
    bool playerFound = false;
    players.forEach((player) {
      if (player.color == playerColor) playerFound = true;
    });
    return playerFound;
  }

  bool thiefCalls() => players.any((player) => player.handCount > EXCEED_TO_ACTIVATE_THE_THIEF);

  Statistic plotUtilityStats() => _plotUtilityStats;

  int utilityOfPlot(int key) => _cachedPlotUtilities[key];

  List<Tile> tilesWithCommodity(Commodity type) => new List<Tile>.from(_cachedTilesWithCommodity[type]);

  int commodityChances(Commodity type) => _cachedCommodityChances[type];

  List<int> handyPlots(Player player) => new List<int>.from(_cachedHandyPlots[player]);

  List<int> handyEdges(Player player) => new List<int>.from(_cachedHandyEdges[player]);

  List<int> openPlots() => new List<int>.from(_cachedOpenPlots);

  List<int> blockedPlots() => new List<int>.from(_cachedBlockedPlots);

  int exposedCommodities(Commodity commodity, {Player player}) {
    if (player != null) {
      return _cachedCommoditiesExposed[player][commodity];
    } else {
      int total = 0;
      players.forEach((player) {
        if (_cachedCommoditiesExposed.containsKey(player)
            && _cachedCommoditiesExposed[player].containsKey(commodity)) {
          total = total + _cachedCommoditiesExposed[player][commodity];
        }
      });
      return total;
    }
  }

  int inPlayCommodities(Commodity commodity, {Player player}) {
    if (player != null) {
      return player.commodities[commodity];
    } else {
      int total = 0;
      players.forEach((player) => total = total + player.commodities[commodity]);
      return total;
    }
  }

  _updateTileDependentCaches() {
    _cachedExpansionTiles.clear();
    _cachedPlots.clear();
    _cachedPlotUtilities.clear();
    _cachedTilesWithCommodity.clear();
    _cachedCommodityChances.clear();

    // init empty tiles-with-commodities maps
    COMMODITIES.forEach((commodity) {
      _cachedTilesWithCommodity[commodity] = new List<Tile>();
      _cachedCommodityChances[commodity] = 0;
    });

    // update _boundingRect, _cachedTilesWithCommodity, _cachedExpansionTiles, and _cachedPlots
    Point minP = Coordinate._getPoint(INITIAL_H, INITIAL_V);
    Point maxP = Coordinate._getPoint(INITIAL_H, INITIAL_V);
    tiles.forEach((_, tile) {
      Point tPoint = tile.coordinate.point;
      if (tPoint.x < minP.x) minP = new Point(tPoint.x, minP.y);
      if (tPoint.y < minP.y) minP = new Point(minP.x, tPoint.y);
      if (tPoint.x > maxP.x) maxP = new Point(tPoint.x, maxP.y);
      if (tPoint.y > maxP.y) maxP = new Point(maxP.x, tPoint.y);

      _cachedExpansionTiles.addAll(tile.neighbors(PieceType.Tile));
      _cachedPlots.addAll(tile.neighbors(PieceType.Plot));
      _cachedTilesWithCommodity[tile.commodity].add(tile);
    });
    minP = new Point(minP.x - (2.5 * SPACING_X), minP.y - (3 * SPACING_Y)); // account for expansion tiles
    maxP = new Point(maxP.x + (2.5 * SPACING_X), maxP.y + (3 * SPACING_Y)); // account for expansion tiles
    _boundingRect = new Rectangle.fromPoints(minP, maxP);
    _cachedExpansionTiles.removeAll(tiles.keys);

    // update _cachedCommodityChances
    COMMODITIES.forEach((commodity) {
      _cachedCommodityChances[commodity] = _cachedTilesWithCommodity[commodity].fold(0, (sum, next) => sum + chances(next.roll));
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
    _cachedCommoditiesExposed.clear();

    // buildings block their plot and their neighboring plots
    plots.forEach((pKey, plot) {
      _cachedBlockedPlots.add(pKey);
      _cachedBlockedPlots.addAll(plot.neighbors(PieceType.Plot));
    });
    _cachedBlockedPlots = _cachedBlockedPlots.intersection(_cachedPlots);

    // plots surrounding tiles and not blocked by buildings
    _cachedOpenPlots = new Set<int>.from(_cachedPlots);
    _cachedOpenPlots.removeAll(_cachedBlockedPlots);

    // max min avg stats on open plot utility
    _cachedOpenPlots.forEach((key) {
      _plotUtilityStats.add(_cachedPlotUtilities[key]);
    });

    // each player has different handy plots and edges adjacent to their buildings and roads
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

    // commodity is exposed if harvestable by a building
    players.forEach((player) {
      _cachedCommoditiesExposed[player] = new Map<Commodity, int>();
      COMMODITIES.forEach((commodity) {
        _cachedCommoditiesExposed[player][commodity] = 0;
      });
    });
    plots.forEach((_, plot) {
      if (plot is Building) {
        Building building = plot;
        building.neighbors(PieceType.Tile).forEach((tKey) {
          if (tiles.containsKey(tKey) && tiles[tKey] is Tile) {
            Tile tile = tiles[tKey] as Tile;
            if (tile.key != thiefKey) {
              int prevValue = _cachedCommoditiesExposed[building.owner][tile.commodity];
              _cachedCommoditiesExposed[building.owner][tile.commodity] = prevValue + building.production;
            }
          }
        });
      }
    });
  }
}

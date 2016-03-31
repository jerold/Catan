// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

// Primary Helper States
const String EditingState = 'Editing';
const String PlayingState = 'Playing';

// Editing Sub States
const String BoardSetupState = 'Board Setup';
const String PlayerSetupState = 'Player Setup';
const String PieceSetupState = 'Piece Setup';

enum Modals {
  None, NewGame,
}

class GameStore extends Store {
  GameActions _actions;
  GameEvents _events;

  Map<int, int> _cachedPlotUtilities = new Map<int, int>();
  Map<ResourceType, List<Terrain>> _cachedTilesWithResource = new Map<ResourceType, List<Terrain>>();
  Map<ResourceType, int> _cachedResourceChances = new Map<ResourceType, int>();

  Board gameBoard = new Board();

  String gameState = EditingState;
  String editState = BoardSetupState;
  Modals visibleModal = Modals.None;

  int _activePlayerIndex = 0;
  Player get activePlayer => gameBoard.players[_activePlayerIndex % gameBoard.players.length];

  Terrain activeTerrain;
  bool showTileOverlay = false;

  GameStore(this._actions, this._events) {
    _actions
      ..addTile.listen(_handleAddTile)
      ..removeTile.listen(_handleRemoveTile)
      ..addPlayer.listen(_handleAddPlayer)
      ..removePlayer.listen(_handleRemovePlayer)
      ..showNewGameModal.listen(_handleShowNewGameModal)
      ..changeEditState.listen(_handleChangeEditState)
      ..changeGameState.listen(_handleChangeGameState)
      ..changeActiveTile.listen(_handleChangeActiveTile)
      ..changeActiveTileToken.listen(_handleChangeActiveTileToken)
      ..changeActiveTileTerrainType.listen(_handleChangeActiveTileTerrainType)
      ..setShowTileOverlay.listen(_handleSetShowTileOverlay);
    this.listen(_pushBoardToURI);

    String mapParam = Uri.base.queryParameters['map'];
    List<String> tileStrings = _splitMapParam(mapParam);
    if (tileStrings.length > 0) _pullBoardFromURI(tileStrings);
    else _newBoard();

    _updateCachedValues();
  }

  List<String> _splitMapParam(String mapParam) {
    List<String> tileStrings = new List<String>();
    if (mapParam != null) {
      for (int i = 0; i + 7 <= mapParam.length; i += 7) {
        tileStrings.add(mapParam.substring(i, i + 7));
      }
    }
    return tileStrings;
  }

  _pullBoardFromURI(List<String> tileStrings) {
    gameBoard.removeTile(new Coordinate.initial());
    tileStrings.forEach((tileString) {
      if (tileString.length == 7) {
        int key = int.parse(tileString.substring(0, 4));
        int token = int.parse(tileString.substring(4, 6));
        TerrainType type = terrainTypeFromString(tileString.substring(6));
        Terrain terrain = new Terrain(new Coordinate.fromKey(key));
        terrain.changeType(type);
        terrain.token = token;
        gameBoard.map[key] = terrain;
      }
    });
    trigger();
  }

  _newBoard() {
    if (standardDealKeys.length != 19) print('WARNING!!! Incorrect Default Coordinate Count ${defaultCoordinateKeys.length}');
    if (defaultTiles.length != 19) print('WARNING!!! Incorrect Default Tile Count ${defaultTiles.length}');
    if (defaultTokens.length != 18) print('WARNING!!! Incorrect Default Tile Count ${defaultTokens.length}');

    List<TerrainType> types = new List<TerrainType>.from(defaultTiles)..shuffle();
    List<int> tokens = new List<int>.from(standardOrderTokens);

    standardDealKeys.forEach((key) {
      Coordinate coordinate = new Coordinate.fromKey(key);
      Terrain terrain = new Terrain(coordinate);
      gameBoard.map[key] = terrain;

      terrain.changeType(types.first);
      if (types.first != TerrainType.Desert) {
        terrain.changeToken(tokens.first);
        tokens.removeAt(0);
      }
      types.removeAt(0);
    });
  }

  _pushBoardToURI(_) {
    List<String> mapParam = new List<String>();
    gameBoard.map.values.forEach((terrain) {
      mapParam.add('${terrain.coordinate.toKey().toString().padLeft(4, "0")}${terrain.token.toString().padLeft(2, "0")}${stringFromTerrainType(terrain.type)}');
    });
    Uri current = Uri.base;
    Map<String, String> params = new Map<String, String>.from(current.queryParameters);
    params['map'] = mapParam.join('');
    current = current.replace(queryParameters: params);
    window.history.pushState('', '', current.toString());
  }

  // Handle Player Actions

  _handleAddPlayer(Player player) {
    if (gameBoard.addPlayer(player)) trigger();
  }

  _handleRemovePlayer(Player player) {
    if (gameBoard.removePlayer(player)) trigger();
  }

  // Handle Tile Actions

  _handleAddTile(Coordinate coord) {
    if (gameBoard.addTile(coord)) {
      _updateCachedValues();
      trigger();
    }
  }

  _handleRemoveTile(Coordinate coord) {
    if (gameBoard.removeTile(coord)) {
      _updateCachedValues();
      trigger();
    }
  }

  _handleChangeActiveTileToken(int newToken) {
    if (activeTerrain != null) {
      activeTerrain.changeToken(newToken);
      _updateCachedValues();
      trigger();
    }
  }

  _handleChangeActiveTileTerrainType(TerrainType newType) {
    if (activeTerrain != null) {
      activeTerrain.changeType(newType);
      _updateCachedValues();
      trigger();
    }
  }

  _handleSetShowTileOverlay(bool show) {
    showTileOverlay = show;
    trigger();
  }

  // Handle Modal Actions

  _handleShowNewGameModal(bool show) {
    context
      .callMethod(r'$', ['.modal'])
      .callMethod(r'modal', ['show']);
    // visibleModal = show ? Modals.NewGame : Modals.None;
    // trigger();
  }

  // Handle State Actions

  _handleChangeEditState(String newState) {
    editState = newState;
    trigger();
  }

  _handleChangeGameState(String newState) {
    gameState = newState;
    trigger();
  }

  // Handle Active Change Actions

  _handleChangeActiveTile(Terrain newActiveTile) {
    activeTerrain = newActiveTile;
    trigger();
  }

  // Utility Methods

  _updateCachedValues() {
    _cachedPlotUtilities.clear();
    _cachedTilesWithResource.clear();
    _cachedResourceChances.clear();

    List<Terrain> tiles = gameBoard.tiles();
    List<int> plotKeys = gameBoard.plots();

    // init empty maps
    ResourceType.values.forEach((type) {
      _cachedTilesWithResource[type] = new List<Terrain>();
      _cachedResourceChances[type] = 0;
    });

    // update _cachedTilesWithResource
    tiles.forEach((tile) {
      _cachedTilesWithResource[yields(tile.type)].add(tile);
    });

    // update _cachedResourceChances
    ResourceType.values.forEach((type) {
      _cachedResourceChances[type] = _cachedTilesWithResource[type].fold(0, (sum, nextTile) => sum + chances(nextTile.token));
    });

    // update _cachedPlotUtilities
    plotKeys.forEach((plotKey) {
      Coordinate plotCoord = new Coordinate.fromKey(plotKey);
      Set<Coordinate> tileNeighbors = new Set<Coordinate>()
        ..addAll(plotCoord.neighbors().where((coord) {
          return coord.type == CoordinateType.Tile && gameBoard.map.containsKey(coord.toKey());
        }));
      List<Terrain> tiles = new List<Terrain>.from(tileNeighbors.map((coord) => gameBoard.map[coord.toKey()]));
      _cachedPlotUtilities[plotKey] = tiles.fold(0, (sum, tile) => sum + chances(tile.token));
    });
  }

  bool playerInGame(String playerColor) {
    bool playerFound = false;
    gameBoard.players.forEach((player) {
      if (player.color == playerColor) playerFound = true;
    });
    return playerFound;
  }

  Map<int, int> plotUtilities() => new Map<int, int>.from(_cachedPlotUtilities);

  int plotUtility(Coordinate plotCoordinate) => _cachedPlotUtilities[plotCoordinate.toKey()];

  List<Terrain> tilesWithResource(ResourceType type) => _cachedTilesWithResource[type];

  Map<ResourceType, int> resourceChances() => new Map<ResourceType, int>.from(_cachedResourceChances);
}

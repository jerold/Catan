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
  Map<ResourceType, List<Tile>> _cachedTilesWithResource = new Map<ResourceType, List<Tile>>();
  Map<ResourceType, int> _cachedResourceChances = new Map<ResourceType, int>();

  Board gameBoard = new Board();

  Rectangle viewport = new Rectangle(0, 0, 0, 0);

  String gameState = EditingState;
  String editState = BoardSetupState;
  Modals visibleModal = Modals.None;

  int _activePlayerIndex = 0;
  Player get activePlayer => gameBoard.players[_activePlayerIndex % gameBoard.players.length];

  Tile activeTile;
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
      ..changeActiveTileType.listen(_handleChangeActiveTileType)
      ..setShowTileOverlay.listen(_handleSetShowTileOverlay);
    this.listen(_pushBoardToURI);

    String mapParam = Uri.base.queryParameters['map'];
    List<String> tileStrings = _splitMapParam(mapParam);
    if (tileStrings.length > 0) _pullBoardFromURI(tileStrings);
    else _newBoard();

    _updateCachedValues();
    _updateViewport();
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
    gameBoard.removeTile(INITIAL_KEY);
    tileStrings.forEach((tileString) {
      if (tileString.length == 7) {
        int key = int.parse(tileString.substring(0, 4));
        int token = int.parse(tileString.substring(4, 6));
        TileType type = tileTypeFromString(tileString.substring(6));
        Tile tile = new Tile(key);
        tile.changeType(type);
        tile.token = token;
        gameBoard.map[key] = tile;
      }
    });
    trigger();
  }

  _newBoard() {
    if (standardDealKeys.length != 19) print('WARNING!!! Incorrect Default Coordinate Count ${defaultCoordinateKeys.length}');
    if (defaultTiles.length != 19) print('WARNING!!! Incorrect Default Tile Count ${defaultTiles.length}');
    if (defaultTokens.length != 18) print('WARNING!!! Incorrect Default Tile Count ${defaultTokens.length}');

    List<TileType> types = new List<TileType>.from(defaultTiles)..shuffle();
    List<int> tokens = new List<int>.from(standardOrderTokens);

    standardDealKeys.forEach((key) {
      Tile tile = new Tile(key);
      gameBoard.map[key] = tile;

      tile.changeType(types.first);
      if (types.first != TileType.Desert) {
        tile.changeToken(tokens.first);
        tokens.removeAt(0);
      }
      types.removeAt(0);
    });
  }

  _pushBoardToURI(_) {
    List<String> mapParam = new List<String>();
    gameBoard.map.values.forEach((tile) {
      mapParam.add('${tile.coordinate.key.toString().padLeft(4, "0")}${tile.token.toString().padLeft(2, "0")}${stringFromTileType(tile.type)}');
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

  _handleAddTile(int key) {
    if (gameBoard.addTile(key)) {
      _updateCachedValues();
      _updateViewport();
      trigger();
    }
  }

  _handleRemoveTile(int key) {
    if (gameBoard.removeTile(key)) {
      _updateCachedValues();
      _updateViewport();
      trigger();
    }
  }

  _handleChangeActiveTileToken(int newToken) {
    if (activeTile != null) {
      activeTile.changeToken(newToken);
      _updateCachedValues();
      trigger();
    }
  }

  _handleChangeActiveTileType(TileType newType) {
    if (activeTile != null) {
      activeTile.changeType(newType);
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

  _handleChangeActiveTile(Tile newActiveTile) {
    activeTile = newActiveTile;
    trigger();
  }

  // Utility Methods

  _updateViewport() {
    double maxManDist = 0.0;
    gameBoard.tiles().forEach((tile) {
      double posX = tile.coordinate.point.x.toDouble().abs();
      double posY = tile.coordinate.point.y.toDouble().abs();
      if (posX > maxManDist) maxManDist = posX;
      if (posY > maxManDist) maxManDist = posY;
    });
    viewport = new Rectangle(
      -1 * maxManDist - (SPACING_X * 3),
      -1 * maxManDist - (SPACING_Y * 3),
      2 * maxManDist + (SPACING_X * 6),
      2 * maxManDist + (SPACING_Y * 6));
  }

  _updateCachedValues() {
    _cachedPlotUtilities.clear();
    _cachedTilesWithResource.clear();
    _cachedResourceChances.clear();

    List<Tile> tiles = gameBoard.tiles();
    List<int> plotKeys = gameBoard.plots();

    // init empty maps
    ResourceType.values.forEach((type) {
      _cachedTilesWithResource[type] = new List<Tile>();
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
      Coordinate plotCoord = Coordinate.fromKey(plotKey);
      Set<Coordinate> tileNeighbors = new Set<Coordinate>()
        ..addAll(plotCoord.neighbors().where((coord) {
          return coord.type == CoordinateType.Tile && gameBoard.map.containsKey(coord.key);
        }));
      List<Tile> tiles = new List<Tile>.from(tileNeighbors.map((coord) => gameBoard.map[coord.key]));
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

  int plotUtility(Coordinate plotCoordinate) => _cachedPlotUtilities[plotCoordinate.key];

  List<Tile> tilesWithResource(ResourceType type) => _cachedTilesWithResource[type];

  Map<ResourceType, int> resourceChances() => new Map<ResourceType, int>.from(_cachedResourceChances);
}

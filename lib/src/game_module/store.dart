// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

const String BoardSetupState = 'Board Setup';
const String TokenSetupState = 'Token Setup';
const String PlayerSetupState = 'Player Setup';
const String PlayingState = 'Playing';

class GameStore extends Store {
  GameActions _actions;
  GameEvents _events;

  Board gameBoard = new Board();

  String gameState = TokenSetupState;

  Terrain activeTerrain;

  GameStore(this._actions, this._events) {
    _actions
      ..addTile.listen(_handleAddTile)
      ..changeTileType.listen(_handleChangeTileType)
      ..removeTile.listen(_handleRemoveTile)
      ..changeState.listen(_handleChangeState)
      ..changeActiveTile.listen(_handleChangeActiveTile)
      ..changeActiveTileToken.listen(_handleChangeActiveTileToken);
    this.listen(_pushBoardToURI);

    String mapParam = Uri.base.queryParameters['map'];
    List<String> tileStrings = _splitMapParam(mapParam);
    if (tileStrings.length > 0) _pullBoardFromURI(tileStrings);
    else _newBoard();
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
    if (defaultCoordinateKeys.length != 19) print('WARNING!!! Incorrect Default Coordinate Count ${defaultCoordinateKeys.length}');
    if (defaultTiles.length != 19) print('WARNING!!! Incorrect Default Tile Count ${defaultTiles.length}');
    if (defaultTokens.length != 18) print('WARNING!!! Incorrect Default Tile Count ${defaultTokens.length}');

    List<TerrainType> types = new List<TerrainType>.from(defaultTiles)..shuffle();
    List<int> tokens = new List<int>.from(defaultTokens)..shuffle();

    defaultCoordinateKeys.forEach((key) {
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
    Html.window.history.pushState('', '', current.toString());
  }

  // Handle Tile Actions

  _handleAddTile(Coordinate coord) {
    if (gameBoard.addTile(coord)) trigger();
  }

  _handleChangeTileType(Coordinate coord) {
    Terrain tile = gameBoard.map[coord.toKey()];
    if (tile != null) {
      tile.changeType();
      trigger();
    }
  }

  _handleChangeActiveTileToken(int newToken) {
    if (activeTerrain != null) {
      activeTerrain.token = newToken;
      print("New Token ${newToken} ${chances(newToken)} ${probability(newToken)}");
      trigger();
    }
  }

  _handleRemoveTile(Coordinate coord) {
    if (gameBoard.removeTile(coord)) trigger();
  }

  // Handle State Actions

  _handleChangeState(String newState) {
    gameState = newState;
    activeTerrain = null;
    trigger();
  }

  _handleChangeActiveTile(Terrain newActiveTile) {
    activeTerrain = newActiveTile;
    trigger();
  }

  // Utility Methods

  Map<int, int> plotUtilities() {
    Map<int, int> utilityMap = new Map<int, int>();
    gameBoard.openPlots().forEach((plotKey) {
      utilityMap[plotKey] = plotUtility(new Coordinate.fromKey(plotKey));
    });
    return utilityMap;
  }

  int plotUtility(Coordinate plotCoordinate) {
    Set<Coordinate> tileNeighbors = new Set<Coordinate>()
      ..addAll(plotCoordinate.neighbors().where((coord) {
        return coord.type == CoordinateType.Tile && gameBoard.map.containsKey(coord.toKey());
      }));
    List<Terrain> tiles = new List<Terrain>.from(tileNeighbors.map((coord) => gameBoard.map[coord.toKey()]));
    return tiles.fold(0, (sum, tile) => sum + chances(tile.token));
  }

  List<Terrain> tilesWithResource(ResourceType type) {
    return new List<Terrain>.from(gameBoard.map.values.where((terrain) => terrain.resource == type));
  }

  Map<ResourceType, int> resourceChances() {
    Map<ResourceType, int> chanceMap = new Map<ResourceType, num>();
    ResourceType.values.forEach((type) {
      List<Terrain> tiles = tilesWithResource(type);
      chanceMap[type] = tiles.fold(0.0, (sum, next) => sum + chances(next.token));
    });
    return chanceMap;
  }
}

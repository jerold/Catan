// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

const String BoardSetupState = 'Board Setup';
const String FrequencySetupState = 'Frequency Setup';
const String PlayerSetupState = 'Player Setup';
const String PlayingState = 'Playing';

class GameStore extends Store {
  GameActions _actions;
  GameEvents _events;

  Board gameBoard = new Board();

  String gameState = BoardSetupState;

  Terrain activeTerrain;

  GameStore(this._actions, this._events) {
    _actions
      ..addTile.listen(_handleAddTile)
      ..changeTileType.listen(_handleChangeTileType)
      ..removeTile.listen(_handleRemoveTile)
      ..changeState.listen(_handleChangeState)
      ..changeActiveTile.listen(_handleChangeActiveTile)
      ..changeActiveTileHarvest.listen(_handleChangeActiveTileHarvest);
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
        int harvest = int.parse(tileString.substring(4, 6));
        TerrainType type = terrainTypeFromString(tileString.substring(6));
        Terrain terrain = new Terrain(new Coordinate.fromKey(key));
        terrain.changeType(type);
        terrain.harvest = harvest;
        gameBoard.map[key] = terrain;
      }
    });
    trigger();
  }

  _newBoard() {
    Coordinate coord = new Coordinate.initial();
    Terrain terrain = new Terrain(coord);
    gameBoard.map[coord.toKey()] = terrain;
  }

  _pushBoardToURI(_) {
    List<String> mapParam = new List<String>();
    gameBoard.map.values.forEach((terrain) {
      mapParam.add('${terrain.coordinate.toKey().toString().padLeft(4, "0")}${terrain.harvest.toString().padLeft(2, "0")}${stringFromTerrainType(terrain.type)}');
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

  _handleChangeActiveTileHarvest(int newHarvest) {
    if (activeTerrain != null) {
      activeTerrain.harvest = newHarvest;
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
}

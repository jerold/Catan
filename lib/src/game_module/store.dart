part of catan.game_module;

// Primary Helper States
const String EditingState = 'Editing';
const String PlayingState = 'Playing';

// Editing Sub States
const String BoardSetupState = 'Board Setup';
const String PlayerSetupState = 'Player Setup';
const String PieceSetupState = 'Piece Setup';

const String SELECTOR_CONTENT = '#helper-content';
const String SELECTOR_DIMMER = '#helper-dimmer';

enum DimmerType {
  ConfirmNewGame,
  TileOptions,
  EdgeOptions,
  GetRobbed,
  PickTileRoll,
  PickTileTerrain,
  PlotOptions,
  WaterOptions,
  PortOptions,
  Roll,
  Trade,
  None,
}
enum GameState { Editing, Playing }
enum EditState { BoardSetup, PlayerSetup, PieceSetup }
enum PlayState { Roll, Trade, Build }

class GameStore extends w_flux.Store {
  GameActions _actions;

  Board _board;
  Board get board => _board;

  // Interaction Point

  Point _interactionPoint = new Point(0, 0);
  Point get interactionPoint => _interactionPoint;

  // UI Properties

  GameState gameState = GameState.Editing;
  EditState editState = EditState.BoardSetup;

  bool _dimmerVisible = false;
  bool get dimmerVisible => _dimmerVisible;

  DimmerType _currentDimmer = DimmerType.None;
  DimmerType get currentDimmer => _currentDimmer;

  cnet.DartClient netclient;
  cnet.GameID gid;

  GameStore(this._actions) {
    netclient = new cnet.DartClient(""); // default connects to localhost
    netclient.events.listen(_handleNetEvent);
    gid = new cnet.GameID(ID: 0);

    String mapParam = Uri.base.queryParameters['map'];
    List<String> tileStrings = _splitMapParam(mapParam);
    String gidParam = Uri.base.queryParameters['gid'];
    if (tileStrings.length > 0) {
      _startNewGameFromURI(tileStrings);
    } else if (gidParam != null && gidParam.length > 0) {
      _startGameFromID(gidParam);
      _startNewGame();
    } else {
      _startNewGame();
    }

    triggerOnAction(_actions.setInteractionPoint, _setInteractionPoint);

    triggerOnAction(_actions.startNewGame, _startNewGame);

    triggerOnAction(_actions.setEditState, _setEditState);
    triggerOnAction(_actions.setGameState, _setGameState);
    triggerOnAction(_actions.showDimmer, _showDimmer);
    triggerOnAction(_actions.hideDimmer, _hideDimmer);

    _board.listen(_pushBoardToURI);
  }

  _saveGame() {
    var players = new List<cnet.Player>(0);
    var pieces = new List<cnet.PieceLocation>();
    this.board.edges.forEach((k, edge) {
      //   if (edge is Boat) {
      //       return;
      //   }
      Road r = edge;
      // TODO: get coords from r.ends() ?
      pieces.add(new cnet.PieceLocation(
          // TODO: get a real player ID
          Piece: new cnet.GamePiece(Owner: r.owner._colorIndex, Type: cnet.PieceType.Road),
          Location: new cnet.Coordinate(X: 0, Y: 0)));
    });
    this.board.plots.forEach((k, plot) {
      int t = cnet.PieceType.Settlement;
      if (plot is City) {
        t = cnet.PieceType.City;
      }
      // TODO: get coords from r.ends() ?
      pieces.add(new cnet.PieceLocation(
          // TODO: get a real player ID
          Piece: new cnet.GamePiece(Owner: 0, Type: t),
          Location: new cnet.Coordinate(X: 0, Y: 0)));
    });
    var tiles = new List<cnet.Tile>();
    this.board.tiles.forEach((k, v) {
      tiles.add(new cnet.Tile(
          // TODO: get real coords
          Location: new cnet.Coordinate(X: 0, Y: 0),
          // TODO: make sure these are all land tiles?
          Type: cnet.TileType.LandTile,
          // TODO: get product
          Product: 0));
    });
    var gb = new cnet.GameBoard(Pieces: pieces, Tiles: tiles);
    cnet.SaveGameRequest r = new cnet.SaveGameRequest(ID: gid, Board: gb, Players: players);
    netclient.SaveGame(r);
  }

  _handleNetEvent(cnet.NetEvent event) {
    switch (event.type) {
      case cnet.EventType.Connected:
        print("connected to server.");
        break;
      case cnet.EventType.Disconnected:
        break;
      case cnet.EventType.SaveGame:
        cnet.SaveGameResponse sgr = event.state;
        print("game saved: " + sgr.ID.ID.toString() + " Revision: " + sgr.ID.Revision.toString());
        if (sgr.ID.Revision == 0) {
          netclient.SubscribeGame(new cnet.ListenSubscribe(ID: sgr.ID.ID));
          // sub on first save only.
        }
        break;
      case cnet.EventType.LoadGame:
        cnet.LoadGameResponse lgr = event.state;
        print("game loaded: ID: " + lgr.ID.ID.toString() + " Revision: " + lgr.ID.Revision.toString());
        gid = lgr.ID;
        // TODO: load the board
        // sub after we load a game.
        break;
      case cnet.EventType.ListenEvent:
        cnet.ListenEvent li = event.state;
        print("notification of board change for board: " +
            li.ID.ID.toString() +
            " Revision: " +
            li.ID.Revision.toString());
        break;
    }
  }

  _startNewGame([_]) {
    gameState = GameState.Editing;
    editState = EditState.BoardSetup;

    _board = new Board.standard();
    _pushBoardToURI();
  }

  _startGameFromID(String gidStr) {
    int id = int.parse(gidStr);
    gid.ID = id;
    netclient.SubscribeGame(new cnet.ListenSubscribe(ID: id));
    netclient.LoadGame(new cnet.LoadGameRequest(ID: gid));
  }

  _startNewGameFromURI(List<String> tileStrings) {
    List<int> keys = new List<int>();
    List<Terrain> types = new List<Terrain>();
    List<int> rolls = new List<int>();
    tileStrings.forEach((tileString) {
      if (tileString.length == 7) {
        keys.add(int.parse(tileString.substring(0, 4)));
        types.add(tileTypeFromString(tileString.substring(6)));
        rolls.add(int.parse(tileString.substring(4, 6)));
      }
    });

    _board = new Board(keys, types, rolls);
  }

  _pushBoardToURI([_]) {
    List<String> mapParam = new List<String>();
    board.tiles.values.forEach((tile) {
      if (tile is Tile) {
        mapParam.add(
            '${tile.key.toString().padLeft(4, "0")}${tile.roll.toString().padLeft(2, "0")}${stringFromTerrain(tile.terrain)}');
      }
      if (tile is Port) {
        mapParam
            .add('${tile.key.toString().padLeft(4, "0")}-${tile.facingIndex + 1}${stringFromTerrain(tile.terrain)}');
      }
    });
    Uri current = Uri.base;
    Map<String, String> params = new Map<String, String>.from(current.queryParameters);
    params['map'] = mapParam.join('');
    current = current.replace(queryParameters: params);
    window.history.pushState('', '', current.toString());

    _saveGame();
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

  // Handle Set Interaction Point

  _setInteractionPoint(Point newPoint) => _interactionPoint = newPoint;

  // Handle UI State Actions

  _setEditState(EditState newState) => editState = newState;

  _setGameState(GameState newState) => gameState = newState;

  // Handle UI Dimmer Actions

  _showDimmer(DimmerType newDimmer) {
    _currentDimmer = newDimmer;
    _dimmerVisible = true;
  }

  _hideDimmer(_) {
    _currentDimmer = DimmerType.None;
    _dimmerVisible = false;
  }
}

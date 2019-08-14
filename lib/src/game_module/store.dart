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

  cnet.Client netclient;

  GameStore(this._actions) {
    String mapParam = Uri.base.queryParameters['map'];
    List<String> tileStrings = _splitMapParam(mapParam);
    if (tileStrings.length > 0)
      _startNewGameFromURI(tileStrings);
    else
      _startNewGame();

    triggerOnAction(_actions.setInteractionPoint, _setInteractionPoint);

    triggerOnAction(_actions.startNewGame, _startNewGame);

    triggerOnAction(_actions.setEditState, _setEditState);
    triggerOnAction(_actions.setGameState, _setGameState);
    triggerOnAction(_actions.showDimmer, _showDimmer);
    triggerOnAction(_actions.hideDimmer, _hideDimmer);

    _board.listen(_pushBoardToURI);

    netclient = cnet.NewClient();
    var netevents = netclient.Events();
    netevents.OnConnect(allowInterop((){
        print("connected!");

        // Subscribe to game ID 1
        cnet.ListenSubscribe subr = new cnet.ListenSubscribe(ID: 1);
        netclient.SubscribeGame(subr);

        // Example of creating a game and saving it.
        var players = new List<cnet.Player>(0);
        var pieces = new List<cnet.PieceLocation>(10);
        var tiles = new List<cnet.Tile>(10);
        var tokens = new List<cnet.Token>(10);
        for (var i = 0; i < 10; i++) {
            pieces[i] = new cnet.PieceLocation(
                Piece: new cnet.GamePiece(Owner: i%2, Type: cnet.PieceType.Road),
                Location: new cnet.Coordinate(X:i, Y:i%5)
            );
        }
        for (var i = 0; i < 10; i++) {
            cnet.Coordinate coord = new cnet.Coordinate(X: i, Y: i%3);
            int roll = (i % 9) + 2; // can roll 2-6,8-12
            if (roll >= 7) roll + 1;
            tiles[i] = new cnet.Tile(Location: coord, Type: cnet.TileType.LandTile, Product: i%6);
            tokens[i] = new cnet.Token(Location: coord, Roll: roll);
        }
        var gb = new cnet.GameBoard(Pieces: pieces, Tiles: tiles, Tokens: tokens, Thief: new cnet.Coordinate(X: 0, Y: 0));
        var gid = new cnet.GameID(ID: 1);
        cnet.SaveGameRequest r = new cnet.SaveGameRequest(ID: gid, Board: gb, Players: players);
        netclient.SaveGame(r);
    } ));
    netevents.OnListenEvent(allowInterop((cnet.ListenEvent li){
        print("notification of board change for board: " + li.ID.ID.toString() + " Revision: " + li.ID.Revision.toString());
    }));
    netevents.OnSaveGame(allowInterop((cnet.SaveGameResponse sgr) {
        print("game saved: " + sgr.ID.toString());
        cnet.LoadGameRequest r = new cnet.LoadGameRequest(ID: sgr.ID);
        netclient.LoadGame(r);
    }));
    netevents.OnLoadGame(allowInterop((cnet.LoadGameResponse lgr) {
        print("game loaded.");
        print(lgr);
    }));
    netclient.Dial(""); //defaults to localhost
  }

  _startNewGame([_]) {
    gameState = GameState.Editing;
    editState = EditState.BoardSetup;

    _board = new Board.standard();
    _pushBoardToURI();
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
        mapParam.add(
            '${tile.key.toString().padLeft(4, "0")}-${tile.facingIndex + 1}${stringFromTerrain(tile.terrain)}');
      }
    });
    Uri current = Uri.base;
    Map<String, String> params =
        new Map<String, String>.from(current.queryParameters);
    params['map'] = mapParam.join('');
    current = current.replace(queryParameters: params);
    window.history.pushState('', '', current.toString());
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

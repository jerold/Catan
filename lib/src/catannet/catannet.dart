@JS('catannet')
library catannet;

import "package:js/js.dart";

class PieceType {
static const int Settlement = 0;
static const int City = 1;
static const int Road = 2;
}

class TileType {
static const int WaterTile = 0;
static const int LandTile = 1;
}

class Commodity {
static const int NoCommodity = 0;
static const int Sheep = 1;
static const int Brick = 2;
static const int Wood = 3;
static const int Stone = 4;
static const int Wheat = 5;
}

@JS()
class Heartbeat {
external factory Heartbeat({int Time,int Latency});

external int get Time;
external void set Time(int val);

external int get Latency;
external void set Latency(int val);
}

@JS()
class SaveGame {
external factory SaveGame({int ID,GameBoard Board,List<Player> Players});

external int get ID;
external void set ID(int val);

external GameBoard get Board;
external void set Board(GameBoard val);

external List<Player> get Players;
external void set Players(List<Player> val);
}

@JS()
class SaveGameResponse {
external factory SaveGameResponse({int ID});

external int get ID;
external void set ID(int val);
}

@JS()
class LoadGame {
external factory LoadGame({int ID});

external int get ID;
external void set ID(int val);
}

@JS()
class LoadGameResponse {
external factory LoadGameResponse({int ID,GameBoard Board,List<Player> Players});

external int get ID;
external void set ID(int val);

external GameBoard get Board;
external void set Board(GameBoard val);

external List<Player> get Players;
external void set Players(List<Player> val);
}

@JS()
class GameBoard {
external factory GameBoard({List<PieceLocation> Pieces,List<Tile> Tiles});

external List<PieceLocation> get Pieces;
external void set Pieces(List<PieceLocation> val);

external List<Tile> get Tiles;
external void set Tiles(List<Tile> val);
}

@JS()
class PieceLocation {
external factory PieceLocation({GamePiece Piece,Coordinate Location});

external GamePiece get Piece;
external void set Piece(GamePiece val);

external Coordinate get Location;
external void set Location(Coordinate val);
}

@JS()
class Coordinate {
external factory Coordinate({int X,int Y});

external int get X;
external void set X(int val);

external int get Y;
external void set Y(int val);
}

@JS()
class Tile {
external factory Tile({Coordinate Location,int Type,int Product});

external Coordinate get Location;
external void set Location(Coordinate val);

external int get Type;
external void set Type(int val);

external int get Product;
external void set Product(int val);
}

@JS()
class GamePiece {
external factory GamePiece({int Owner,int Type});

external int get Owner;
external void set Owner(int val);

external int get Type;
external void set Type(int val);
}

@JS()
class Player {
external factory Player({int ID,String Name,List<Resource> Resources,List<DevelopmentCard> Cards,List<GamePiece> Pieces});

external int get ID;
external void set ID(int val);

external String get Name;
external void set Name(String val);

external List<Resource> get Resources;
external void set Resources(List<Resource> val);

external List<DevelopmentCard> get Cards;
external void set Cards(List<DevelopmentCard> val);

external List<GamePiece> get Pieces;
external void set Pieces(List<GamePiece> val);
}

@JS()
class DevelopmentCard {
external factory DevelopmentCard({int CardType});

external int get CardType;
external void set CardType(int val);
}

@JS()
class Resource {
external factory Resource({int Type});

external int get Type;
external void set Type(int val);
}


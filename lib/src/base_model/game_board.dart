part of catan.base_model;

class BoardStore {
  cnet.GameBoard _board;

  List<cnet.PieceLocation> _pieces = new List<cnet.PieceLocation>();
  List<cnet.Tile> _tiles = new List<cnet.Tile>();
  List<cnet.Token> _tokens = new List<cnet.Token>();
  cnet.Coordinate _thief;

  // List<cnet.PieceLocation> get Pieces => _pieces;
  // void set Pieces(List<cnet.PieceLocation> val);
  //
  // List<cnet.Tile> get Tiles => _tiles;
  // void set Tiles(List<cnet.Tile> val) {
  // }
  //
  // List<cnet.Token> get Tokens => _tokens;
  // void set Tokens(List<cnet.Token> val){
  // }
  //
  // cnet.Coordinate get Thief => _thief;
  // void set Thief(cnet.Coordinate val){
  // }

  GameBoard() {

  }
}

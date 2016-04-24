// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


abstract class Owned {
  Player get owner;
}

class Piece extends w_flux.Store {
  final int _key;

  int get key => _key;

  PieceType _type;
  PieceType get type => _type;

  Map<PieceType, Set<int>> _neighborCache;

  Piece(this._key, this._type) {
    _updateCache();
  }

  factory Piece.ofType(GamePieceType type, int key, {Player owner}) {
    switch(type) {
      case GamePieceType.City:
        if (owner != null) return new City(key, owner);
        break;
      case GamePieceType.Road:
        if (owner != null) return new Road(key, owner);
        break;
      case GamePieceType.Settlement:
        if (owner != null) return new Settlement(key, owner);
        break;
      case GamePieceType.Tile:
        return new Tile(key);
      default:
        print("WARNING!!! Could not construct a Piece.ofType ${type} at ${key} for ${owner}");
        return null;
    }
  }

  void _updateCache() {
    _neighborCache = new Map<PieceType, Set<int>>();
    _neighborCache[PieceType.Edge] = new Set<int>();
    _neighborCache[PieceType.Plot] = new Set<int>();
    _neighborCache[PieceType.Tile] = new Set<int>();
  }

  List<int> neighbors(PieceType type) => new List<int>.from(_neighborCache[type]);
}

/// edge piece keys map to an edge existing between two adjacent plots
class EdgePiece extends Piece {
  Edge get edge => Edge.fromKey(key);

  EdgePiece(int key) : super(key, PieceType.Edge) {
    if (!Edge.validKey(key)) {
      print("WARNING!!! ${this.runtimeType} can only exist between two adjacent Plot coordinates");
    }
  }

  void _updateCache() {
    super._updateCache();
    // List of Edge keys from set of edges between ends and end neighboring plots.
    edge.ends().forEach((eCoord) {
      eCoord.neighbors(ofType: CoordinateType.Plot).forEach((_, nKey) {
        _neighborCache[PieceType.Edge].add(Edge.getKey(eCoord.key, nKey));
      });
    });
    _neighborCache[PieceType.Edge].remove(key);

    // List of Plot coordinate keys from set of ends and ends' neighboring plots.
    edge.ends().forEach((eCoord) {
      eCoord.neighbors(ofType: CoordinateType.Plot).forEach((_, nKey) {
        _neighborCache[PieceType.Plot].add(nKey);
      });
    });

    // List of Tile coordinate keys from set of ends' neighboring tiles.
    edge.ends().forEach((eCoord) {
      eCoord.neighbors(ofType: CoordinateType.Tile).forEach((_, nKey) {
        _neighborCache[PieceType.Tile].add(nKey);
      });
    });
  }

  String toString() => "${this.runtimeType}${Edge.validKey(key) ? '' : '!!!'} ${edge}";
}

/// tile and plot pieces are both node pieces as their key maps to a coordinate
class NodePiece extends Piece {
  Coordinate get coordinate => Coordinate.fromKey(key);
  CoordinateType _legalType;

  NodePiece(int key, this._legalType, PieceType type) : super(key, type) {
    if (!Coordinate.validKey(key) || coordinate.type != _legalType) {
      print("WARNING!!! ${this.runtimeType} can not be placed on a ${coordinate.type}");
    }
  }

  String toString() => "${this.runtimeType}${Coordinate.validKey(key) ? '' : '!!!'} ${coordinate}";
}


class TilePiece extends NodePiece {
  TilePiece(int key) : super(key, CoordinateType.Tile, PieceType.Tile);

  void _updateCache() {
    super._updateCache();
    // List of Edge keys from set of edges between coordinate and coordinate's
    // neighboring plots.
    coordinate.neighbors(ofType: CoordinateType.Plot).forEach((_, nKey) {
      Coordinate.fromKey(nKey).neighbors(ofType: CoordinateType.Plot).forEach((_, nnKey) {
        _neighborCache[PieceType.Edge].add(Edge.getKey(nKey, nnKey));
      });
    });

    // List of Plot coordinate keys from coordinate's neighboring plots.
    coordinate.neighbors(ofType: CoordinateType.Plot).forEach((_, nKey) {
      _neighborCache[PieceType.Plot].add(nKey);
    });

    // List of Tile coordinate keys from coordinate's neighboring tiles.
    coordinate.neighbors(ofType: CoordinateType.Plot).forEach((_, nKey) {
      Coordinate.fromKey(nKey).neighbors(ofType: CoordinateType.Tile).forEach((_, nnKey) {
        _neighborCache[PieceType.Tile].add(nnKey);
      });
    });
    _neighborCache[PieceType.Tile].remove(key);
  }
}


class PlotPiece extends NodePiece {
  PlotPiece(int key) : super(key, CoordinateType.Plot, PieceType.Plot);

  void _updateCache() {
    super._updateCache();
    // List of Edge keys from set of edges between coordinate and coordinate's
    // neighboring plots.
    coordinate.neighbors(ofType: CoordinateType.Plot).forEach((_, nKey) {
      _neighborCache[PieceType.Edge].add(Edge.getKey(key, nKey));
    });

    // List of Plot coordinate keys from coordinate's neighboring plots.
    coordinate.neighbors(ofType: CoordinateType.Plot).forEach((_, nKey) {
      _neighborCache[PieceType.Plot].add(nKey);
    });

    // List of Tile coordinate keys from coordinate's neighboring tiles.
    coordinate.neighbors(ofType: CoordinateType.Tile).forEach((_, nKey) {
      _neighborCache[PieceType.Tile].add(nKey);
    });
  }
}

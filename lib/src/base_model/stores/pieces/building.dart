part of catan.base_model;

class Building extends PlotPiece implements Owned {
  final int production;

  Player _owner;
  Player get owner => _owner;

  Building(int key, this.production, this._owner) : super(key);

  String toString() => "${super.toString()}:${production}";
}

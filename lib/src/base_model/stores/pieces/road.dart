part of catan.base_model;

class Road extends EdgePiece implements Owned {
  Player _owner;
  Player get owner => _owner;

  Road(int key, this._owner) : super(key);
}

// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

class Road extends EdgePiece implements Owned {
  Player _owner;
  Player get owner => _owner;
  
  Road(int key, this._owner) : super(key);
}

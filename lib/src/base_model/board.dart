// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

// remaining building plots

// open island expansion tiles

// The Thief

// The Players -> their buildings

// The Tile

// The Ships


// translation of tile coordinates to draw coordinates

// calculations on resource probability

class Board {
  Map<int, Tile> map = new Map<int, Tile>(); // Where key is generated from Tile's coordinate
  List<Player> players = new List<Player>();
  Thief thief;

  // Change Map

  bool addTile(int coordKey) {
    if (expansionTiles().contains(coordKey)) {
      map[coordKey] = new Tile(coordKey);
      return true;
    }
    return false;
  }

  bool removeTile(int coordKey) {
    if (map.containsKey(coordKey)) {
      map.remove(coordKey);
      return true;
    }
    return false;
  }

  // Change Players

  bool addPlayer(Player player) {
    if (!players.contains(player)) {
      players.add(player);
      return true;
    }
    return false;
  }

  bool removePlayer(Player player) {
    if (players.contains(player)) {
      players.remove(player);
      return true;
    }
    return false;
  }

  // Convenience Methods

  List<Tile> tiles() => new List<Tile>()..addAll(map.values);

  List<int> plots() {
    Set<int> plotSet = new Set<int>();
    tiles().forEach((tile) {
      plotSet.addAll(tile.coordinate.neighbors().map((coord) => coord.key));
    });
    return new List<int>.from(plotSet);
  }

  // tile coordinates directly surrounding actual tiles.
  Set<int> expansionTiles() {
    Set<int> tiles = new Set<int>();
    map.values.forEach((tile) {
      tiles.addAll(tile.expansionTiles());
    });
    map.values.forEach((tile) {
      tiles.remove(tile.coordinate.key);
    });
    return tiles;
  }

  Set<int> blockedPlots() {
    Set<int> plots = new Set<int>();
    players.forEach((player) {
      player.buildings.forEach((building) {
        plots.addAll(building.blockedPlots());
      });
    });
    return plots;
  }

  Set<int> openPlots() {
    Set<int> plots = new Set<int>();
    map.values.forEach((tile) {
      plots.addAll(tile.coordinate.neighbors().map((coord) => coord.key));
    });
    plots.removeAll(blockedPlots());
    return plots;
  }

  void describe() {
    print("Tiles:");
    print(map.values);

    print("Buildings:");
    print(players.expand((player) => player.buildings));

    print("ExpansionTiles:");
    print(expansionTiles());

    print("OpenPlots:");
    print(openPlots());
  }
}

// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

// remaining building plots

// open island expansion tiles

// The Thief

// The Players -> their buildings

// The Terrain

// The Ships


// translation of tile coordinates to draw coordinates

// calculations on resource probability

class Board {
  Map<int, Terrain> map = new Map<int, Terrain>(); // Where key is generated from Terrain plot's coordinate
  List<Player> players = new List<Player>();
  Thief thief;

  // Change Map

  bool addTile(Coordinate coordinate) {
    int coordKey = coordinate.toKey();
    if (expansionTiles().contains(coordKey)) {
      map[coordKey] = new Terrain(coordinate);
      return true;
    }
    return false;
  }

  bool removeTile(Coordinate coordinate) {
    int coordKey = coordinate.toKey();
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

  // tile coordinates surrounding those tiles occupied with terrain.
  Set<int> expansionTiles() {
    Set<int> tiles = new Set<int>();
    map.values.forEach((terrain) {
      tiles.addAll(terrain.expansionTiles());
    });
    map.values.forEach((terrain) {
      tiles.remove(terrain.coordinate.toKey());
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
    map.values.forEach((terrain) {
      plots.addAll(terrain.coordinate.neighbors().map((coord) => coord.toKey()));
    });
    plots.removeAll(blockedPlots());
    return plots;
  }

  void describe() {
    print("Terrain");
    print(map.values);

    print("Buildings");
    print(players.expand((player) => player.buildings));

    print("ExpansionTiles:");
    print(expansionTiles());

    print("OpenPlots:");
    print(openPlots());
  }
}

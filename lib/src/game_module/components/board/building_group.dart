// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var BuildingGroup = react.registerComponent(() => new _BuildingGroup());
class _BuildingGroup extends w_flux.FluxComponent<GameActions, GameStore> {

  @override
  List<w_flux.Store> redrawOn() {
    if (store is GameStore) return [store.boardStore];
    else return [];
  }

  render() {
    List children = new List();
    store.boardStore.board.players.forEach((player) {
      player.settlements.forEach((sKey, settlement) {
        Coordinate coord = Coordinate.fromKey(settlement.key);
        Point center = scaledPoint(coord, store.boardStore.viewport);
        children.add(react.circle({
          'cx': center.x,
          'cy': center.y,
          'r': COORD_SPACING / 5,
          'fill': player.color,
          'stroke': 'white',
          'strokeWidth': 2,
          'pointerEvents': 'none',
        }));
      });

      player.cities.forEach((cKey, city) {
        Coordinate coord = Coordinate.fromKey(city.key);
        Point center = scaledPoint(coord, store.boardStore.viewport);
        children.add(react.circle({
          'cx': center.x,
          'cy': center.y,
          'r': COORD_SPACING / 3,
          'fill': player.color,
          'stroke': 'white',
          'strokeWidth': 2,
          'pointerEvents': 'none',
        }));
        children.add(react.circle({
          'cx': center.x,
          'cy': center.y,
          'r': COORD_SPACING / 5,
          'fill': player.color,
          'stroke': 'white',
          'strokeWidth': 2,
          'pointerEvents': 'none',
        }));
      });
    });
    return react.g({}, children);
  }
}

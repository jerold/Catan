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

    store.boardStore.board.plots.forEach((pKey, plot) {
      if (plot is Building) {
        Building building = plot as Building;
        Coordinate coord = Coordinate.fromKey(building.key);
        Point center = scaledPoint(coord, store.boardStore.viewport);
        if (building.production > 1) {
          children.add(react.circle({
            'cx': center.x,
            'cy': center.y,
            'r': COORD_SPACING / 3,
            'fill': building.owner.color,
            'stroke': 'white',
            'strokeWidth': 2,
            'pointerEvents': 'none',
          }));
        }
        if (building.production > 0) {
          children.add(react.circle({
            'cx': center.x,
            'cy': center.y,
            'r': COORD_SPACING / 5,
            'fill': building.owner.color,
            'stroke': 'white',
            'strokeWidth': 2,
            'pointerEvents': 'none',
          }));
        }
      }
    });
    return react.g({}, children);
  }
}

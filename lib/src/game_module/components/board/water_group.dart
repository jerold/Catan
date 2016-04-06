// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


const String WATER_COLOR = 'rgba(38, 169, 224, 0.2)';


var WaterGroup = react.registerComponent(() => new _WaterGroup());
class _WaterGroup extends w_flux.FluxComponent<GameActions, GameStore> {

  @override
  List<w_flux.Store> redrawOn() {
    if (store is GameStore) return [store.boardStore];
    else return [];
  }

  render() {
    List children = new List();
    store.boardStore.board.expansionTiles.forEach((key) {
      Coordinate coord = Coordinate.fromKey(key);
      Point center = scaledPoint(coord, store.boardStore.viewport);
      List<Point> hexPoints = ringOfPoints(center: center, radius: COORD_SPACING, count: 6);
      children.add(react.polygon({
        'points': new List<String>.from(hexPoints.map((hex) => '${hex.x},${hex.y}')).join(' '),
        'fill': WATER_COLOR,
        'onMouseDown': (_) => actions.addTile(key),
      }));
    });
    return react.g({}, children);
  }
}

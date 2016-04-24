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
        'onMouseDown': (react.SyntheticMouseEvent e) => _handleMouseDown(e, key),
        'onTouchStart': (react.SyntheticTouchEvent e) => _handleTouchStart(e, key),
      }));
    });
    return react.g({}, children);
  }

  _handleMouseDown(react.SyntheticMouseEvent e, int key) {
    Point client = new Point(e.clientX, e.clientY);
    interactionBegan(e.shiftKey, client, key);
  }

  _handleTouchStart(react.SyntheticTouchEvent e, int key) {
    e.preventDefault();
    // React dart does not fully convert the touches JsObject to a List<Touch>...
    Point client = new Point(e.touches[0]['clientX'], e.touches[0]['clientY']);
    interactionBegan(e.shiftKey, client, key);
  }

  interactionBegan(bool shiftKey, Point client, int key) {
    if (shiftKey) {
      actions.addTile(key);
    } else {
      actions.setActiveTileKey(key);
      actions.setActivatePoint(client);
      actions.showDimmer(DimmerType.WaterOptions);
    }
  }
}

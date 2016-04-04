// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var TileGroup = react.registerComponent(() => new _TileGroup());
class _TileGroup extends w_flux.FluxComponent<GameActions, GameStore> {
  Tile get tile => props['tile'];

  render() {
    Point center = scaledPoint(tile.coordinate, store.viewport);

    List children = new List();
    List<Point> hexPoints = ringOfPoints(center: center, radius: COORD_SPACING, count: 6);
    children.add(react.polygon({
      'points': new List<String>.from(hexPoints.map((hex) => '${hex.x},${hex.y}')).join(' '),
      'fill': tileTypeToColor(tile.type),
      'stroke': 'white',
      'strokeWidth': '2',
      'onMouseDown': _handleMouseDown,
      // 'onClick': onClickCallback,
      // 'onMouseDown': onMouseDownCallback,
      // 'onMouseMove': onMouseMoveCallback,
      // 'onMouseUp': onMouseUpCallback,
    }));

    // List<Point> pipPoints = ringOfPoints(center: center, radius: radius * 2 / 3, count: pipCount);
    List<Point> points = pipPoints(center: center, radius: COORD_SPACING * 0.5, count: chances(tile.roll));
    points.forEach((point) {
      children.add(react.circle({
        'cx': point.x,
        'cy': point.y,
        'r': 2,
        'fill': activeColor,
      }));
    });

    children.add(react.text({
      'textAnchor': 'middle',
      'x': center.x,
      'y': center.y,
      'dy': '.3em',
      'fill': activeColor,
      'style': {
        'pointerEvents': 'none',
        'fontSize': 20,
        // 'fontWeight': 'bold',
        'fontFamily': '"Century Gothic", CenturyGothic, AppleGothic, sans-serif',
      }
    }, '${tile.type != TileType.Desert ? tile.roll.toString() : ""}'));
    return react.g({}, children);
  }

  _handleMouseDown(react.SyntheticMouseEvent e) {
    if (e.shiftKey) actions.removeTile(tile.key);
  }
}

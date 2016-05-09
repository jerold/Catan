// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var TileGroup = react.registerComponent(() => new _TileGroup());
class _TileGroup extends w_flux.FluxComponent<GameActions, Board> {
  Board get board => store;

  Tile get tile => props['tile'];

  render() {
    Point center = scaledPoint(tile.coordinate);

    List children = new List();
    List<Point> hexPoints = ringOfPoints(center: center, radius: COORD_SPACING, count: 6);
    children.add(react.polygon({
      'points': new List<String>.from(hexPoints.map((hex) => '${hex.x},${hex.y}')).join(' '),
      'fill': tileTypeToColor(tile.terrain),
      'stroke': 'white',
      'strokeWidth': '2',
      'onMouseDown': _handleMouseDown,
      'onTouchStart': _handleTouchStart,
    }));

    if (board.thiefKey == tile.key) {
      children.add(react.circle({
        'cx': center.x,
        'cy': center.y,
        'r': COORD_SPACING / 5,
        'fill': activeColor,
        'style': {'pointerEvents': 'none'},
      }));
    } else {
      List<Point> points = pipPoints(center: center, radius: COORD_SPACING * 0.5, count: chances(tile.roll));
      if (tile.terrain != Terrain.Desert) points.forEach((point) {
        children.add(react.circle({
          'cx': point.x,
          'cy': point.y,
          'r': 2,
          'fill': activeColor,
          'style': {'pointerEvents': 'none'},
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
          'fontFamily': '"Century Gothic", CenturyGothic, AppleGothic, sans-serif',
        }
      }, '${tile.terrain != Terrain.Desert ? tile.roll.toString() : ""}'));
    }
    return react.g({}, children);
  }

  _handleMouseDown(react.SyntheticMouseEvent e) {
    Point client = new Point(e.clientX, e.clientY);
    interactionBegan(e.shiftKey, client);
  }

  _handleTouchStart(react.SyntheticTouchEvent e) {
    e.preventDefault();
    // React dart does not fully convert the touches JsObject to a List<Touch>...
    Point client = new Point(e.touches[0]['clientX'], e.touches[0]['clientY']);
    interactionBegan(e.shiftKey, client);
  }

  interactionBegan(bool shiftKey, Point client) {
    if (shiftKey) {
      board.actions.removePiece(tile);
    } else {
      board.actions.setActiveKey(tile.key);
      actions.setInteractionPoint(client);
      actions.showDimmer(DimmerType.TileOptions);
    }
  }
}

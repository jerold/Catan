// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var PortGroup = react.registerComponent(() => new _PortGroup());
class _PortGroup extends w_flux.FluxComponent<GameActions, Board> {
  Board get board => store;

  Port get port => props['port'];

  List<Point> _portPoints(Point center, List<Point> hexPoints) {
    switch(port.facing) {
      case Direction.East:
        return new List<Point>()..add(center)..add(hexPoints[0])..add(hexPoints[1]);
      case Direction.SouthEast:
        return new List<Point>()..add(center)..add(hexPoints[1])..add(hexPoints[2]);
      case Direction.SouthWest:
        return new List<Point>()..add(center)..add(hexPoints[2])..add(hexPoints[3]);
      case Direction.West:
        return new List<Point>()..add(center)..add(hexPoints[3])..add(hexPoints[4]);
      case Direction.NorthWest:
        return new List<Point>()..add(center)..add(hexPoints[4])..add(hexPoints[5]);
      case Direction.NorthEast:
        return new List<Point>()..add(center)..add(hexPoints[5])..add(hexPoints[0]);
    }
  }

  render() {
    Point center = scaledPoint(port.coordinate);

    List children = new List();
    List<Point> hexPoints = ringOfPoints(center: center, radius: COORD_SPACING * 5 / 6, count: 6);
    List<Point> portPoints = _portPoints(center, ringOfPoints(center: center, radius: COORD_SPACING * 5 / 6, count: 6));
    children.add(react.polygon({
      'points': new List<String>.from(hexPoints.map((p) => '${p.x},${p.y}')).join(' '),
      'onMouseDown': _handleMouseDown,
      'onTouchStart': _handleTouchStart,
      'opacity': '0',
    }));
    children.add(react.polygon({
      'points': new List<String>.from(portPoints.map((p) => '${p.x},${p.y}')).join(' '),
      'fill': port.terrain == Terrain.Desert ? 'white' : tileTypeToColor(port.terrain),
      'stroke': 'white',
      'strokeWidth': '2',
      'style': {'pointerEvents': 'none'},
    }));

    // children.add(react.text({
    //   'textAnchor': 'middle',
    //   'x': center.x,
    //   'y': center.y,
    //   'dy': '.3em',
    //   'fill': activeColor,
    //   'style': {
    //     'pointerEvents': 'none',
    //     'fontSize': 20,
    //     'fontFamily': '"Century Gothic", CenturyGothic, AppleGothic, sans-serif',
    //   }
    // }, port.terrain == Terrain.Desert ? '3:1' : '2:1'));
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
      board.actions.removePiece(port);
    } else {
      board.actions.setActiveKey(port.key);
      actions.setInteractionPoint(client);
      actions.showDimmer(DimmerType.PortOptions);
    }
  }
}

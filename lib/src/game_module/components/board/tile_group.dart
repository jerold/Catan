// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var TileGroup = react.registerComponent(() => new _TileGroup());
class _TileGroup extends w_flux.FluxComponent<GameActions, GameStore> {
  Tile get tile => props['tile'];

  @override
  List<w_flux.Store> redrawOn() {
    if (store is GameStore) return [store.boardStore];
    else return [];
  }

  render() {
    Point center = scaledPoint(tile.coordinate, store.boardStore.viewport);

    List children = new List();
    List<Point> hexPoints = ringOfPoints(center: center, radius: COORD_SPACING, count: 6);
    children.add(react.polygon({
      'points': new List<String>.from(hexPoints.map((hex) => '${hex.x},${hex.y}')).join(' '),
      'fill': tileTypeToColor(tile.type),
      'stroke': 'white',
      'strokeWidth': '2',
      'onMouseDown': _handleMouseDown,
      'onTouchStart': _handleTouchStart,
    }));

    if (store.boardStore.board.thiefTileKey == tile.key) {
      children.add(react.circle({
        'cx': center.x,
        'cy': center.y,
        'r': COORD_SPACING / 5,
        'fill': activeColor,
        'pointerEvents': 'none',
      }));
    } else {
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
          'fontFamily': '"Century Gothic", CenturyGothic, AppleGothic, sans-serif',
        }
      }, '${tile.type != TileType.Desert ? tile.roll.toString() : ""}'));
    }
    return react.g({}, children);
  }

  _handleMouseDown(react.SyntheticMouseEvent e) {
    Point client = new Point(e.clientX, e.clientY);
    interactionBegan(e.shiftKey, client);
  }

  _handleTouchStart(react.SyntheticTouchEvent e) {
    var firstTouch = e.touches.first;
    Point client = new Point(firstTouch.clientX, firstTouch.clientY);
    interactionBegan(e.shiftKey, client);
  }

  interactionBegan(bool shiftKey, Point client) {
    if (shiftKey) {
      actions.removeTile(tile.key);
    } else {
      actions.setActiveTileKey(tile.key);
      actions.setActivatePoint(client);
      actions.showDimmer(DimmerType.TileOptions);
    }
  }
}

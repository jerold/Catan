// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


const num PLOT_RADIUS = COORD_SPACING * 1 / 3;

String utilityGradient(num val, num average, num max) {
  num delta = max - average != 0 ? (val - average) / (max - average) : 0;
  return 'rgb(100, ${(255 * delta).toInt()}, ${(255 - (255 * delta)).toInt()})';
}


var PlotGroup = react.registerComponent(() => new _PlotGroup());
class _PlotGroup extends w_flux.FluxComponent<GameActions, GameStore> {

  @override
  List<w_flux.Store> redrawOn() {
    if (store is GameStore) return [store.boardStore];
    else return [];
  }

  render() {
    Statistic utilityStats = store.boardStore.board.plotUtilityStats();
    num utilityRange = utilityStats.getMax() - utilityStats.getMin();

    List children = new List();
    store.boardStore.board.plots.forEach((key) {
      Coordinate coord = Coordinate.fromKey(key);
      int utility = store.boardStore.board.utilityOfPlot(key);
      Point center = scaledPoint(coord, store.boardStore.viewport);

      children.add(react.circle({
        'cx': center.x,
        'cy': center.y,
        'r': PLOT_RADIUS,
        'fill': 'white',
        'stroke': 'rgba(0, 0, 0, 0.1)',
        'strokeWidth': '1',
        'onMouseDown': (react.SyntheticMouseEvent e) => _handleMouseDown(e, key),
        'onTouchStart': (react.SyntheticTouchEvent e) => _handleTouchStart(e, key),
      }));

      num opacity = utilityRange > 0 ? (utility - utilityStats.getMin()) / utilityRange : 0.0;
      List<Point> hexPoints = ringOfPoints(center: center, radius: (PLOT_RADIUS * 2 / 3) * opacity, count: 6);
      children.add(react.polygon({
        'points': new List<String>.from(hexPoints.map((hex) => '${hex.x},${hex.y}')).join(' '),
        'fill': utilityGradient(utility, utilityStats.getAvg(), utilityStats.getMax()),
        'opacity': opacity,
        'stroke': activeColor,
        'strokeWidth': utility == utilityStats.getMax() ? '3' : '0',
        'style': {
          'pointerEvents': 'none',
        }
      }));
    });

    return react.g({}, children);
  }

  _handleMouseDown(react.SyntheticMouseEvent e, int key) {
    print('PLOT _handleMouseDown ${new Point(e.clientX, e.clientY)} ${key}');
    // actions.configureControlPalette(new ControlPaletteConfig());
  }

  _handleTouchStart(react.SyntheticTouchEvent e, int key) {
    print('PLOT _handleTouchStart ${e.touches} ${key}');
    // actions.configureControlPalette(new ControlPaletteConfig());
  }
}

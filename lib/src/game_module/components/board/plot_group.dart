// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


const num PLOT_RADIUS = COORD_SPACING * 1 / 3;

String utilityGradient(num val, num average, num max) {
  num delta = max - average != 0 ? (val - average) / (max - average) : 0;
  return 'rgb(100, ${(255 * delta).toInt()}, ${(255 - (255 * delta)).toInt()})';
}


var PlotGroup = react.registerComponent(() => new _PlotGroup());
class _PlotGroup extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    Statistic utilityStats = store.gameBoard.plotUtilityStats();

    List children = new List();
    store.gameBoard.plots.forEach((key) {
      Coordinate coord = Coordinate.fromKey(key);
      int utility = store.gameBoard.utilityOfPlot(key);
      Point center = scaledPoint(coord, store.viewport);

      children.add(react.circle({
        'cx': center.x,
        'cy': center.y,
        'r': PLOT_RADIUS,
        'fill': 'white',
        'stroke': 'rgba(0, 0, 0, 0.1)',
        'strokeWidth': '1',
      }));

      num opacity = (utility - utilityStats.getMin()) / (utilityStats.getMax() - utilityStats.getMin());
      List<Point> hexPoints = ringOfPoints(center: center, radius: (PLOT_RADIUS * 2 / 3) * opacity, count: 6);
      children.add(react.polygon({
        'points': new List<String>.from(hexPoints.map((hex) => '${hex.x},${hex.y}')).join(' '),
        'fill': utilityGradient(utility, utilityStats.getAvg(), utilityStats.getMax()),
        'opacity': opacity,
        'stroke': activeColor,
        'strokeWidth': utility == utilityStats.getMax() ? '3' : '0',
      }));
    });
    return react.g({}, children);
  }
}

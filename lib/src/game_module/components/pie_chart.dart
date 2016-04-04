// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

typedef void PieChartArcClickCallback(int index);

var PieChart = react.registerComponent(() => new _PieChart());
class _PieChart extends react.Component {
  PieChartArcClickCallback get callback => props['callback'];
  List<num> get data => props['data'];
  List<String> get strokes => props['strokes'];

  render() {
    List arcs = new List();
    int count = 0;
    num cumulative = 0.0;
    data.forEach((datum) {
      arcs.add(PieChartArc({
        'percentage': datum,
        'cumulative': cumulative,
        'callback': callback,
        'index': count,
        'stroke': strokes[count],
      }));
      count = count + 1;
      cumulative = cumulative + datum;
    });
    return react.svg({
      'className': 'pie-chart',
      'viewBox': '0 0 32 32',
      'width': '100%',
      'height': '100%',
    }, arcs);
  }
}

var PieChartArc = react.registerComponent(() => new _PieChartArc());
class _PieChartArc extends react.Component {
  PieChartArcClickCallback get callback => props['callback'];
  num get percentage => props['percentage'];
  num get cumulative => props['cumulative'];
  int get index => props['index'];
  String get stroke => props['stroke'];

  render() {
    return react.circle({
      'className': 'pie-chart-arc',
      'r': 16,
      'cx': 16,
      'cy': 16,
      'onClick': (_) => callback(index),
      'style': {
        'stroke': stroke,
        'strokeDasharray': '${percentage} 100',
        'strokeDashoffset': '${-1 * cumulative}',
      }
    });
  }
}

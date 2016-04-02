// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

typedef void ComponentCallback(React.SyntheticMouseEvent e);
var RoundGameButton = React.registerComponent(() => new _RoundGameButton());
class _RoundGameButton extends React.Component {
  String get text => props['text'] ?? '';
  int get pipCount => props['pipCount'] ?? 0;
  String get fill => props['fill'] ?? 'darkGray';
  num get radius => props['radius'] ?? distance_between_coords / 1.5;
  Point get center => props['center'] ?? new Point(0, 0);
  bool get selected => props['selected'] ?? false;

  ComponentCallback get onClickCallback => props['onClick'];
  ComponentCallback get onMouseDownCallback => props['onMouseDown'];
  ComponentCallback get onMouseMoveCallback => props['onMouseMove'];
  ComponentCallback get onMouseUpCallback => props['onMouseUp'];

  render() {
    String stroke = selected ? activeColor : 'none';
    int strokeWidth = selected ? 2 : 0;

    List children = new List();
    children.add(React.circle({
      'cx': center.x,
      'cy': center.y,
      'r': radius,
      'fill': fill,
      'stroke': stroke,
      'strokeWidth': strokeWidth,
      'onClick': onClickCallback,
      'onMouseDown': onMouseDownCallback,
      'onMouseMove': onMouseMoveCallback,
      'onMouseUp': onMouseUpCallback,
    }));

    List<Point> pipPoints = ringOfPoints(center: center, radius: radius * 2 / 3, count: pipCount);
    pipPoints.forEach((point) {
      children.add(React.circle({
        'cx': point.x,
        'cy': point.y,
        'r': 2,
        'fill': activeColor,
      }));
    });

    children.add(React.text({
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
    }, text));
    return React.g({}, children);
  }
}

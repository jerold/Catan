part of catan.game_module;

final int BAR_HEIGHT = 8;
final int BAR_WIDTH = 24;
final int BAR_SPACING = 3;

var BarChart = react.registerComponent(() => new _BarChart());

class _BarChart extends react.Component {
  List<num> get data => props['data'];
  List<String> get fills => props['fills'];

  render() {
    List bars = new List();
    int maxI = 0;
    data.forEach((datum) => maxI = max(maxI, datum));
    int height = (BAR_HEIGHT + BAR_SPACING) * maxI - BAR_SPACING;
    int width = (BAR_WIDTH + BAR_SPACING) * data.length - BAR_SPACING;

    int dataIndex = 0;
    data.forEach((datum) {
      for (int i = 0; i < datum; i++) {
        if (i > maxI) maxI = i;
        bars.add(react.rect({
          'x': (BAR_WIDTH + BAR_SPACING) * dataIndex,
          'y': (BAR_HEIGHT + BAR_SPACING) * i,
          'height': BAR_HEIGHT,
          'width': BAR_WIDTH,
          'style': {'fill': fills[dataIndex]}
        }));
      }
      dataIndex++;
    });

    return react.svg({
      'className': 'bar-chart',
      // 'viewBox': '0 0 32 32',
      'width': width,
      'height': height,
    }, react.g({}, bars));
  }
}

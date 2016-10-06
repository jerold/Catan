part of catan.game_module;

var HistoryList = react.registerComponent(() => new _HistoryList());

class _HistoryList extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    List<int> data = [1, 2, 3, 0, 1];
    List<String> fills = new List<String>.from([
      Terrain.Field,
      Terrain.Pasture,
      Terrain.Forest,
      Terrain.Hill,
      Terrain.Mountain
    ].map((terrain) => tileTypeToColor(terrain)));

    List historyItems = new List();
    [PlayerColorRed, PlayerColorBlue, PlayerColorGrey].forEach((color) {
      historyItems.add(react.div({
        'className': 'ui grid'
      }, [
        react.div({
          'className': 'two wide column'
        }, [
          react.div({
            'className': 'ui statistics'
          }, [
            react.div({
              'className': '${color} statistic'
            }, [
              react.div({'className': 'value'}, '4'),
              react.div({'className': 'label'}, 'Score'),
            ]),
          ]),
        ]),
        react.div({
          'className': 'fourteen wide column'
        }, [
          react.div({
            'className': 'item'
          }, [
            react.div({
              'className': 'content'
            }, [
              react.div({'className': 'header'}, 'Turn summary'),
              react.div({'className': 'meta'}, 'Player ${color}'),
              react.div(
                  {'className': 'description'}, 'Summarize the players turn.'),
              react.div({
                'className': 'extra'
              }, [
                react
                    .div({'className': 'ui label'}, 'delete turn from history'),
              ]),
              BarChart({
                'data': data,
                'fills': fills,
              }),
            ]),
          ]),
        ]),
      ]));
    });

    return react.div({
      'className': 'ui left aligned basic segment'
    }, [
      react.div({'className': 'ui divided items'}, historyItems),
    ]);
  }
}

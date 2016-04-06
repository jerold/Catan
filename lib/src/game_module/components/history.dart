// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var History = react.registerComponent(() => new _History());
class _History extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    var topItem = react.div({'className': 'ui center aligned inverted segment'}, [
      react.div({'className': 'ui three column very relaxed grid'}, [
        react.div({'className': 'column'}, [
          react.h4({'className': 'header'}, 'Roll'),
        ]),
        react.div({'className': 'ui vertical divider'}, [
          react.i({'className': 'inverted chevron right icon'}),
        ]),
        react.div({'className': 'column'}, [
          react.h4({'className': 'header'}, 'Trade'),
        ]),
        react.div({'className': 'ui vertical divider'}, [
          react.i({'className': 'inverted chevron right icon'}),
        ]),
        react.div({'className': 'column'}, [
          react.h4({'className': 'header'}, 'Build'),
        ]),
      ]),
    ]);

    List historyItems = new List();
    [PlayerColorRed, PlayerColorBlue, PlayerColorGrey].forEach((color) {
      historyItems.add(react.div({'className': 'ui grid'}, [
        react.div({'className': 'two wide column'}, [
          react.div({'className': 'ui statistics'}, [
            react.div({'className': '${color} statistic'}, [
              react.div({'className': 'value'}, '4'),
              react.div({'className': 'label'}, 'Score'),
            ]),
          ]),
        ]),
        react.div({'className': 'fourteen wide column'}, [
          react.div({'className': 'item'}, [
            react.div({'className': 'content'}, [
              react.div({'className': 'header'}, 'Turn summary'),
              react.div({'className': 'meta'}, 'Player ${color}'),
              react.div({'className': 'description'}, 'Summarize the players turn.'),
              react.div({'className': 'extra'}, [
                react.div({'className': 'ui label'}, 'delete turn from history'),
              ]),
            ]),
          ]),
        ]),
      ]));
    });
    
    return react.div({'className': 'ui left aligned basic segment'}, [
      topItem,
      react.div({'className': 'ui divided items'}, historyItems),
    ]);
  }
}

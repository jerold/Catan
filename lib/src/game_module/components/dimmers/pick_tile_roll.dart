// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


final List<int> TILE_ROLLS = [2, 3, 4, 5, 6, 8, 9, 10, 11, 12];


var PickRoll = react.registerComponent(() => new _PickRoll());
class _PickRoll extends w_flux.FluxComponent<GameActions, GameStore> {

  int get selected => state['selected'];

  getInitialState() => {'selected': store.activeTile.roll};

  render() {
    List rolls = new List.from(TILE_ROLLS.map((roll) {
      return react.button({
          'className': 'ui inverted ${roll == selected ? "active" : ""} button',
          'onClick': (_) => _select(roll),
      }, '${roll}');
    }));

    return react.div({'className':'content'}, [
      react.div({'className':'center'}, [
        react.h2({'className':'ui inverted icon header'}, [
          react.i({'className':'cube icon'}),
          react.div({'className': 'segment'}, [
            'Tile Roll',
          ]),
          react.div({'className':'sub header'}, [
            react.div({'className': 'ui basic segment'}, rolls),
            react.div({'className': 'ui hidden divider'}),
            react.div({'className': 'ui basic segment'}, [
              react.button({
                  'className': 'ui red basic cancel inverted button',
                  'onClick': _handleCancel,
              }, react.i({'className': 'remove icon'})),
            ])
          ])
        ])
      ])
    ]);
  }

  _select(int value) {
    if (ROLLS.contains(value)) store.activeTile.actions.setRoll(value);
    actions.hideDimmer();
  }

  _handleCancel(_) {
    actions.hideDimmer();
  }
}

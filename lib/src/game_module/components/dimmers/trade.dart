// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var Trade = react.registerComponent(() => new _Trade());
class _Trade extends w_flux.FluxComponent<GameActions, GameStore> {

  int get selected => state['selected'];

  getInitialState() => {'selected': 0};

  render() {
    Player activePlayer = store.boardStore.activePlayer;

    return react.div({'className':'content'}, [
      react.div({'className':'center'}, [
        react.h2({'className':'ui inverted icon header'}, [
          react.div({'className': 'segment'}, 'Trade'),
          react.div({'className':'sub header'}, [
            react.div({'className': 'ui basic left aligned clearing segment'}, [

              react.h3({'style': {
                'color': activePlayer.color,
              }}, '${activePlayer != null ? activePlayer.color : ""} '),

              react.div({'className': 'ui divider'}),
              react.div({'className': 'ui six column grid'}, [
                react.div({'className': 'column'}, [
                  react.button({'className': 'ui button'}, '1'),
                ]),
                react.div({'className': 'column'}, [
                  react.button({'className': 'ui button'}, '2'),
                ]),
                react.div({'className': 'column'}, [
                  react.button({'className': 'ui button'}, '3'),
                ]),
                react.div({'className': 'column'}, [
                  react.button({'className': 'ui disabled button'}, '0'),
                ]),
                react.div({'className': 'column'}, [
                  react.button({'className': 'ui button'}, '1'),
                ]),
                react.div({'className': 'column'}, [
                  react.button({'className': 'ui disabled button'}, '0'),
                ]),
              ]),

              react.div({'className': 'ui six column grid'}, [
                react.div({'className': 'center aligned column'}, 'W'),
                react.div({'className': 'center aligned column'}, 'S'),
                react.div({'className': 'center aligned column'}, 'L'),
                react.div({'className': 'center aligned column'}, 'B'),
                react.div({'className': 'center aligned column'}, 'O'),
                react.div({'className': 'center aligned column'}, '?'),
              ]),

              react.div({'className': 'ui six column grid'}, [
                react.div({'className': 'column'}, [
                  react.button({'className': 'ui inverted disabled button'}, '0'),
                ]),
                react.div({'className': 'column'}, [
                  react.button({'className': 'ui inverted button'}, '1'),
                ]),
                react.div({'className': 'column'}, [
                  react.button({'className': 'ui inverted disabled button'}, '0'),
                ]),
                react.div({'className': 'column'}, [
                  react.button({'className': 'ui inverted disabled button'}, '0'),
                ]),
                react.div({'className': 'column'}, [
                  react.button({'className': 'ui inverted button'}, '1'),
                ]),
                react.div({'className': 'column'}, [
                  react.button({'className': 'ui inverted button'}, '1'),
                ]),
              ]),

            ]),
            react.div({'className': 'ui hidden divider'}),
            react.div({'className': 'ui basic segment'}, [
              react.button({
                  'className': 'ui red basic cancel inverted button',
                  'onClick': _handleCancel,
              }, react.i({'className': 'remove icon'})),
              react.button({
                  'className': 'ui green ok inverted button',
                  'onClick': _handleConfirm,
              }, react.i({'className': 'checkmark icon'}))
            ])
          ])
        ])
      ])
    ]);
  }

  _select(int value) {
    setState({'selected': value});
  }

  _handleCancel(_) {
    actions.hideDimmer();
  }

  _handleConfirm(_) {
    // if (ROLLS.contains(selected)) actions.roll(selected);
    actions.hideDimmer();
  }
}

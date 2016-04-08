// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var ConfirmNewGame = react.registerComponent(() => new _ConfirmNewGame());
class _ConfirmNewGame extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    return react.div({'className':'content'}, [
      react.div({'className':'center'}, [
        react.h2({'className':'ui inverted icon header'}, [
          react.i({'className':'warning sign icon'}),
          react.div({'className': 'segment'}, [
            'Start New Game',
          ]),
          react.div({'className':'sub header'}, [
            react.div({'className': 'ui basic segment'}, [
              'Starting a new game will cause the current game details to be lost. Which could suck... or not. I don\'t know you. You could be into that sort of thing.',
            ]),
            react.div({'className': 'ui hidden divider'}),
            react.div({'className': 'ui basic segment'}, [
              react.button({
                  'className': 'ui red basic cancel inverted button',
                  'onClick': _handleCancel,
              }, [
                react.i({'className': 'remove icon'}),
                'Nope, that sounds bad.'
              ]),
              react.button({
                  'className': 'ui green ok inverted button',
                  'onClick': _handleConfirm,
              }, [
                react.i({'className': 'checkmark icon'}),
                'Please, I know the guac is extra.'
              ])
            ])
          ])
        ])
      ])
    ]);
  }

  _handleCancel(_) {
    actions.hideDimmer();
  }

  _handleConfirm(_) {
    actions.startNewGame();
    actions.hideDimmer();
  }
}

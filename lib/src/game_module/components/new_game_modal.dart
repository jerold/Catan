// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var NewGameModal = react.registerComponent(() => new _NewGameModal());
class _NewGameModal extends w_flux.FluxComponent<GameActions, GameStore> {

  void componentDidMount(/*DOMElement */ rootNode) {
    context
      .callMethod(r'$', ['.modal'])
      .callMethod(r'modal', ['show']);
  }

  render() {
    // return react.div({'className': 'ui small basic modal'}, [
    //   react.div({'className': 'ui icon header'}, [
    //     react.i({'className': 'warning sign icon'}),
    //     'Start New Game'
    //   ]),
    //   react.div({'className': 'content'}, [
    //     react.p({}, 'Starting a new game will cause the current game details to be lost. Which could suck, or not. I don\'t know you. You could be into that sort of thing.')
    //   ]),
    //   react.div({'className': 'actions'}, [
    //     react.div({'className': 'ui red basic cancel inverted button'}, [
    //       react.i({'className': 'remove icon'}),
    //       'Nope, that sounds bad.'
    //     ]),
    //     react.div({
    //       'className': 'ui green ok inverted button',
    //       'onClick': _handleCancel,
    //     }, [
    //       react.i({'className': 'checkmark icon'}),
    //       'Please, I know the guac is extra.'
    //     ]),
    //   ]),
    // ]);

    // return react.div({'className': 'ui page ${store.visibleModal != Modals.None ? "active" : ""} dimmer'}, [
    //   react.div({'className': 'content'}, [
    //     react.div({'className': 'ui small basic modal'}, [
    //       react.div({'className': 'ui icon header'}, [
    //         react.i({'className': 'warning sign icon'}),
    //         'Start New Game'
    //       ]),
    //       react.div({'className': 'content'}, [
    //         react.p({}, 'Starting a new game will cause the current game details to be lost. Which could suck, or not. I don\'t know you. You could be into that sort of thing.')
    //       ]),
    //       react.div({'className': 'actions'}, [
    //         react.div({
    //           'className': 'ui red basic cancel inverted button',
    //           'onClick': _handleCancel,
    //         }, [
    //           react.i({'className': 'remove icon'}),
    //           'Nope, that sounds bad.'
    //         ]),
    //         react.div({'className': 'ui green ok inverted button'}, [
    //           react.i({'className': 'checkmark icon'}),
    //           'Please, I know the guac is extra.'
    //         ]),
    //       ]),
    //     ]),
    //   ]),
    // ]);
  }

  _handleCancel(_) => actions.showNewGameModal(false);
}

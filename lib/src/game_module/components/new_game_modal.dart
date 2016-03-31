// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var NewGameModal = React.registerComponent(() => new _NewGameModal());
class _NewGameModal extends FluxComponent<GameActions, GameStore> {

  void componentDidMount(/*DOMElement */ rootNode) {
    context
      .callMethod(r'$', ['.modal'])
      .callMethod(r'modal', ['show']);
  }

  render() {
    // return React.div({'className': 'ui small basic modal'}, [
    //   React.div({'className': 'ui icon header'}, [
    //     React.i({'className': 'warning sign icon'}),
    //     'Start New Game'
    //   ]),
    //   React.div({'className': 'content'}, [
    //     React.p({}, 'Starting a new game will cause the current game details to be lost. Which could suck, or not. I don\'t know you. You could be into that sort of thing.')
    //   ]),
    //   React.div({'className': 'actions'}, [
    //     React.div({'className': 'ui red basic cancel inverted button'}, [
    //       React.i({'className': 'remove icon'}),
    //       'Nope, that sounds bad.'
    //     ]),
    //     React.div({
    //       'className': 'ui green ok inverted button',
    //       'onClick': _handleCancel,
    //     }, [
    //       React.i({'className': 'checkmark icon'}),
    //       'Please, I know the guac is extra.'
    //     ]),
    //   ]),
    // ]);

    // return React.div({'className': 'ui page ${store.visibleModal != Modals.None ? "active" : ""} dimmer'}, [
    //   React.div({'className': 'content'}, [
    //     React.div({'className': 'ui small basic modal'}, [
    //       React.div({'className': 'ui icon header'}, [
    //         React.i({'className': 'warning sign icon'}),
    //         'Start New Game'
    //       ]),
    //       React.div({'className': 'content'}, [
    //         React.p({}, 'Starting a new game will cause the current game details to be lost. Which could suck, or not. I don\'t know you. You could be into that sort of thing.')
    //       ]),
    //       React.div({'className': 'actions'}, [
    //         React.div({
    //           'className': 'ui red basic cancel inverted button',
    //           'onClick': _handleCancel,
    //         }, [
    //           React.i({'className': 'remove icon'}),
    //           'Nope, that sounds bad.'
    //         ]),
    //         React.div({'className': 'ui green ok inverted button'}, [
    //           React.i({'className': 'checkmark icon'}),
    //           'Please, I know the guac is extra.'
    //         ]),
    //       ]),
    //     ]),
    //   ]),
    // ]);
  }

  _handleCancel(_) => actions.showNewGameModal(false);
}

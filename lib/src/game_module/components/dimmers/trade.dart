// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var Trade = react.registerComponent(() => new _Trade());
class _Trade extends w_flux.FluxComponent<GameActions, GameStore> {

  TradePayload get tradeTo => state['tradeTo'];
  TradePayload get tradeFrom => state['tradeFrom'];

  getInitialState() => {
    'tradeTo': new TradePayload(store.board.economy, payer: store.activePlayer, payee: store.board.players[0]),
    'tradeFrom': new TradePayload(store.board.economy, payer: store.board.players[0], payee: store.activePlayer),
  };

  render() {
    Player activePlayer = store.activePlayer;

    List tradeSegments = new List();

    if (tradeTo != null) tradeSegments.add(PayerSegment({'actions': actions, 'store': tradeTo.payer, 'trade': tradeTo}));
    if (tradeFrom != null) tradeSegments.add(PayerSegment({'actions': actions, 'store': tradeFrom.payer, 'trade': tradeFrom}));

    return react.div({'className':'content'}, [
      react.div({'className':'center'}, [
        react.h2({'className':'ui inverted icon header'}, [
          react.div({'className': 'segment'}, 'Trade'),
          react.div({'className':'sub header'}, tradeSegments),
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
    ]);
  }

  _handleCancel(_) {
    tradeTo?.revoke();
    tradeFrom?.revoke();
    actions.hideDimmer();
  }

  _handleConfirm(_) {
    if (tradeTo != null) store.board.economy.doTrade(tradeTo);
    if (tradeFrom != null) store.board.economy.doTrade(tradeFrom);
    actions.hideDimmer();
  }
}

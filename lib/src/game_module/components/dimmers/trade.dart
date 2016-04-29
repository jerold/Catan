// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var Trade = react.registerComponent(() => new _Trade());
class _Trade extends _Exchange {
  Player get activePlayer => store.board.activePlayer;

  Economy get economy => store.board.economy;

  Map getInitialState() => {'title': 'Nothing funny, just a trade partner...'};

  render() {
    print('Trades ${trades.length}');
    if (trades.length > 0) return super.render();

    List items = new List();
    store.board.players.forEach((player) {
      if (player != store.board.activePlayer) {
        List playerItems = new List();
        playerItems.add(react.i({'className': 'user icon'}));
        playerItems.add(react.span({'className': 'text'}, ' ${player.name}'));
        items.add(react.button({
          'className': 'ui big ${player.color} icon inverted button',
          'onClick': (_) => _configureTrade(player),
        }, playerItems));
      }
    });

    return react.div({'className':'content'}, [
      react.div({'className':'center'}, [
        react.h2({'className':'ui inverted icon header'}, [
          react.div({'className': 'segment'}, title),
        ]),
        react.div({'className':'sub header'}, items),
        react.div({'className': 'ui hidden divider'}),
        react.div({'className': 'ui basic segment'}, [
          react.button({
            'className': 'ui big red basic cancel inverted button',
            'onClick': _handleCancel,
          }, [
            react.i({'className': 'remove icon'}),
            'On second thought, yeah no.'
          ])
        ]),
      ])
    ]);
  }

  _configureTrade(Player player) {
    TradePayload a = new TradePayload(economy, payer: activePlayer, payee: player);
    TradePayload b = new TradePayload(economy, payee: activePlayer, payer: player);
    setState({
      'title': 'In for a penny, in for a pound...',
      'trades': [a, b]
    });
  }
}

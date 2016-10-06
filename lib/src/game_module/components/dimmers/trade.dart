part of catan.game_module;

var Trade = react.registerComponent(() => new _Trade());

class _Trade extends _Exchange {
  Player get activePlayer => store.board.activePlayer;

  Economy get economy => store.board.economy;

  Map getInitialState() => {'title': 'Nothing funny, just a trade partner...'};

  dynamic partnerComponent([Player player]) {
    String color = 'black';
    String title = '';
    String icon = 'spy';
    if (player != null) {
      color = player.color;
      title = player.name;
      icon = 'user';
    }
    List partnerItems = new List();
    partnerItems.add(react.i({'className': '${icon} icon'}));
    partnerItems.add(react.span({'className': 'text'}, ' ${title}'));
    return react.button({
      'className': 'ui big ${color} icon inverted button',
      'onClick': (_) => _configureTrade(player),
    }, partnerItems);
  }

  render() {
    if (trades.length > 0) return super.render();

    List items = new List();
    store.board.players.forEach((player) {
      if (player != store.board.activePlayer) {
        items.add(partnerComponent(player));
      }
    });
    items.add(partnerComponent());

    return react.div({
      'className': 'content'
    }, [
      react.div({
        'className': 'center'
      }, [
        react.h2({
          'className': 'ui inverted icon header'
        }, [
          react.div({'className': 'segment'}, title),
        ]),
        react.div({'className': 'sub header'}, items),
        react.div({'className': 'ui hidden divider'}),
        react.div({
          'className': 'ui basic segment'
        }, [
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
    List<TradePayload> trades = new List<TradePayload>();
    trades.add(new TradePayload(economy, payer: activePlayer, payee: player));
    trades.add(new TradePayload(economy, payee: activePlayer, payer: player));
    setState({'title': 'In for a penny, in for a pound...', 'trades': trades});
  }
}

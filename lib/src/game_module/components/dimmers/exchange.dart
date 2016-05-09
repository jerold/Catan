// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var Exchange = react.registerComponent(() => new _Exchange());
class _Exchange extends w_flux.FluxComponent<GameActions, GameStore> {
  List<TradePayload> get trades => state['trades'] ?? [];
  String get title => state['title'] ?? 'Trade';

  Map defaultState() => {'title': 'Trade', 'trades': []};

  _handlePlayerChanges(_) => redraw();

  // TODO: If the payer is the bank, no player exists, so this element will not
  // reDraw as often as one would expect (add commodity from banker, notice confirm
  // button is still disabled). Find a better way of setting up handlers here.
  Map<w_flux.Store, Function> getStoreHandlers() {
    Map<w_flux.Store, Function> handlers = new Map<w_flux.Store, Function>();
    store.board.players.forEach((player) {
      handlers[player] = _handlePlayerChanges;
    });
    return handlers;
  }

  render() {
    List tradeSegments = new List.from(trades.map((trade) {
      return PayerSegment({'actions': actions, 'store': trade});
    }));

    List footerOptions = new List();
    if (!_requiresSatisfaction()) {
      footerOptions.add(react.button({
        'className': 'ui big red basic cancel inverted button',
        'onClick': _handleCancel,
      }, [
        react.i({'className': 'checkmark icon'}),
        'On second thought, yeah no.'
      ]));
    }

    print("CAN:${_canComplete()} TOT:${_total()}");

    String confirmClasses = 'ui big green ok inverted button';
    if (!_canComplete() || _total() == 0) confirmClasses = '${confirmClasses} disabled';
    String confirmTitle = 'Jeez, really?';
    if (trades.length == 2 && _woodForSheep(trades[0], trades[1])) confirmTitle = 'Heh, you have wood for sheep.';
    footerOptions.add(react.button({
      'className': confirmClasses,
      'onClick': _handleConfirm,
    }, [
      react.i({'className': 'remove icon'}),
      confirmTitle
    ]));

    return react.div({'className':'content'}, [
      react.div({'className':'center'}, [
        react.h2({'className':'ui inverted icon header'}, [
          react.div({'className': 'segment'}, title),
          react.div({'className':'sub header'}, [
            react.div({'className': 'ui basic compact segment'}, tradeSegments),
          ]),
        ]),
        react.div({'className': 'ui basic segment'}, footerOptions),
      ])
    ]);
  }

  bool _woodForSheep(TradePayload a, TradePayload b) {
    if (!a.exchange.containsKey(Commodity.Lumber)) return false;
    if (!b.exchange.containsKey(Commodity.Sheep)) return false;
    return a.exchange[Commodity.Lumber] > 0 && b.exchange[Commodity.Sheep] > 0;
  }

  bool _requiresSatisfaction() => trades.any((trade) => trade.requiresSatisfaction());

  bool _canComplete() => trades.every((trade) => trade.canComplete());

  int _total() => trades.fold(0, (sum, trade) => sum + trade.total);

  _handleCancel(_) {
    trades.forEach((trade) => trade.revoke());
    setState(defaultState());
    actions.hideDimmer();
  }

  _handleConfirm(_) {
    trades.forEach((trade) => store.board.economy.doTrade(trade));
    setState(defaultState());
    actions.hideDimmer();
  }
}

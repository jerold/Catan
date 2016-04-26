// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var Exchange = react.registerComponent(() => new _Exchange());
class _Exchange extends w_flux.FluxComponent<GameActions, GameStore> {
  List<StreamSubscription> _playerSubs = new List<StreamSubscription>();

  List<TradePayload> get trades => state['trades'] ?? [];
  String get title => state['title'] ?? 'Trade';

  Map defaultState() => {'title': 'Trade', 'trades': []};

  void componentDidUpdate(prevProps, prevState, /*DOMElement */ rootNode) {
    _playerSubs.forEach((sub) => sub.cancel());
    _playerSubs.clear();
    trades.forEach((trade) => _playerSubs.add(trade.payer.listen(_handlePlayerChanges)));
  }

  _handlePlayerChanges(_) => redraw();

  render() {
    List tradeSegments = new List.from(trades.map((trade) {
      return PayerSegment({'actions': actions, 'store': trade.payer, 'trade': trade});
    }));

    String cancelClasses = 'ui big red basic cancel inverted button';
    if (_requiresSatisfaction()) cancelClasses = '${cancelClasses} disabled';

    String confirmClasses = 'ui big green ok inverted button';
    if (!_canComplete() || _total() == 0) confirmClasses = '${cancelClasses} disabled';

    String confirmTitle = 'Jeez, really?';
    if (trades.length == 2 && _woodForSheep(trades[0], trades[1])) confirmTitle = 'Heh, you have wood for sheep.';

    print('Render total ${_total()}');

    return react.div({'className':'content'}, [
      react.div({'className':'center'}, [
        react.h2({'className':'ui inverted icon header'}, [
          react.div({'className': 'segment'}, title),
          react.div({'className':'sub header'}, [
            react.div({'className': 'ui basic compact segment'}, tradeSegments),
          ]),
        ]),
        react.div({'className': 'ui basic segment'}, [
          react.button({
            'className': cancelClasses,
            'onClick': _handleCancel,
          }, [
            react.i({'className': 'checkmark icon'}),
            'On second thought, yeah no.'
          ]),
          react.button({
            'className': confirmClasses,
            'onClick': _handleConfirm,
          }, [
            react.i({'className': 'remove icon'}),
            confirmTitle
          ]),
        ]),
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

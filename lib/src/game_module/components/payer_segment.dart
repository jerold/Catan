// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var PayerSegment = react.registerComponent(() => new _PayerSegment());
class _PayerSegment extends w_flux.FluxComponent<GameActions, Player> {
  Player get player => store;

  TradePayload get trade => props['trade'];

  render() {
    List onHand = new List();
    player.commodities.forEach((commodity, count) {
      onHand.add(react.div({'className': 'column'},
        react.button({
          'className': 'ui ${count <= 0 ? "secondary inverted disabled" : "grey"} button',
          'onClick': (_) => trade.deposit(commodity, 1),
        }, '${count}')
      ));
    });

    List labels = new List();
    player.commodities.forEach((commodity, count) {
      labels.add(react.div({'className': 'center aligned column'}, '${stringFromCommodity(commodity)}'));
    });

    List deposits = new List();
    player.commodities.forEach((commodity, _) {
      bool disabled = !trade.exchange.containsKey(commodity) || trade.exchange[commodity] <= 0;
      int count = trade.exchange[commodity] ?? 0;
      deposits.add(react.div({'className': 'column'},
        react.button({
          'className': 'ui ${disabled ? "secondary inverted disabled" : "white"} button',
          'onClick': (_) => trade.withdraw(commodity, 1),
        }, '${count}')
      ));
    });

    return react.div({'className': 'ui basic left aligned segment'}, [
      react.h3({'className': 'ui ${player.color} inverted header'}, '${player.name}'),
      react.div({'className': 'ui divider'}),
      react.div({'className': 'ui six column grid'}, labels),
      react.div({'className': 'ui six column grid'}, onHand),
      react.div({'className': 'ui six column grid'}, deposits),
    ]);
  }
}

// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var PayerSegment = react.registerComponent(() => new _PayerSegment());
class _PayerSegment extends w_flux.FluxComponent<GameActions, Player> {
  Player get player => store;

  TradePayload get trade => props['trade'];

  render() {
    List onHand = new List();
    player.resources.forEach((resource, count) {
      onHand.add(react.div({'className': 'column'},
        react.button({
          'className': 'ui inverted ${count <= 0 ? "disabled" : ""} button',
          'onClick': (_) => trade.deposit(resource, 1),
        }, '${count}')
      ));
    });

    List labels = new List();
    player.resources.forEach((resource, count) {
      labels.add(react.div({'className': 'center aligned column'}, '${stringFromResource(resource)}'));
    });

    List deposits = new List();
    player.resources.forEach((resource, _) {
      bool disabled = !trade.exchange.containsKey(resource) || trade.exchange[resource] <= 0;
      int count = trade.exchange[resource] ?? 0;
      deposits.add(react.div({'className': 'column'},
        react.button({
          'className': 'ui ${disabled ? "inverted disabled" : ""} button',
          'onClick': (_) => trade.withdraw(resource, 1),
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

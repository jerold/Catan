// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var PayerSegment = react.registerComponent(() => new _PayerSegment());
class _PayerSegment extends w_flux.FluxComponent<GameActions, TradePayload> {
  Player get payer => trade.payer;

  TradePayload get trade => store;

  render() {
    List onHand = new List();
    COMMODITIES.forEach((commodity) {
      String label = '+';
      String classes = 'ui button';
      if (payer != null) {
        if (commodity == Commodity.Unknown) {
          classes = '${classes} grey';
        } else {
          label = '${payer.commodities[commodity]}';
          if (payer.commodities[commodity] <= 0) classes = '${classes} secondary inverted disabled';
          else classes = '${classes} grey';
        }
      } else {
        classes = '${classes} grey';
      }
      onHand.add(react.div({'className': 'column'},
        react.button({
          'className': classes,
          'onClick': (_) => trade.deposit(commodity, 1),
        }, label)
      ));
    });

    List labels = new List();
    COMMODITIES.forEach((commodity) {
      labels.add(react.div({'className': 'center aligned column'}, '${stringFromCommodity(commodity)}'));
    });

    List deposits = new List();
    COMMODITIES.forEach((commodity) {
      bool disabled = !trade.exchange.containsKey(commodity) || trade.exchange[commodity] <= 0;
      int count = trade.exchange[commodity] ?? 0;
      deposits.add(react.div({'className': 'column'},
        react.button({
          'className': 'ui ${disabled ? "secondary inverted disabled" : "white"} button',
          'onClick': (_) => trade.withdraw(commodity, 1),
        }, '${count}')
      ));
    });

    String title = 'Banker';
    String color = 'black';
    if (payer != null) {
      title = payer.name;
      color = payer.color;
    }

    List headerItems = new List();
    headerItems.add(title);
    if (trade.requiresSatisfaction()) {
      headerItems.add(react.div(
        {'className': 'ui ${trade.canComplete() ? "green" : "red"} top right attached label'},
        '${trade.total} / ${trade.quota}')
      );
    }

    return react.div({'className': 'ui basic left aligned segment'}, [
      react.h3({'className': 'ui ${color} inverted header'}, headerItems),
      react.div({'className': 'ui divider'}),
      react.div({'className': 'ui six column grid'}, labels),
      react.div({'className': 'ui six column grid'}, onHand),
      react.div({'className': 'ui six column grid'}, deposits),
    ]);
  }
}

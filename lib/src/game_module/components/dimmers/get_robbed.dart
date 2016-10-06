part of catan.game_module;

var GetRobbed = react.registerComponent(() => new _GetRobbed());

class _GetRobbed extends _Exchange {
  Economy get economy => store.board.economy;

  Map getInitialState() {
    List<TradePayload> trades = new List<TradePayload>();
    store.board.players.forEach((player) {
      if (player.handCount > 7) {
        trades.add(new TradePayload(economy,
            payer: player, quota: player.handCount ~/ 2));
      }
    });
    return {
      'title': 'Time to pay up!',
      'trades': trades,
    };
  }
}

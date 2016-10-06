part of catan.game_module;

var Playing = react.registerComponent(() => new _Playing());

class _Playing extends w_flux.FluxComponent<GameActions, GameStore> {
  Board get board => store.board;

  @override
  List<w_flux.Store> redrawOn() {
    if (store is GameStore)
      return [store.board];
    else
      return [];
  }

  Player get activePlayer => state['activePlayer'];

  getInitialState() => stateFromStore()..['renaming'] = false;

  stateFromStore() => {'activePlayer': board.activePlayer};

  setStateFromStore() => setState(stateFromStore());

  Map<w_flux.Store, Function> getStoreHandlers() => {
        store: (_) => setStateFromStore(),
        store.board: (_) => setStateFromStore(),
      };

  render() {
    List<int> exposed = new List<int>.from(KNOWN_COMMODITIES
        .map((commodity) => store.board.exposedCommodities(commodity)));
    List<int> inPlay = new List<int>.from(KNOWN_COMMODITIES
        .map((commodity) => store.board.inPlayCommodities(commodity)));
    List<String> fills = new List<String>.from(
        KNOWN_COMMODITIES.map((commodity) => commodityToColor(commodity)));

    return react.div({
      'className': 'ui basic vertical center aligned segment'
    }, [
      Players({'actions': actions, 'store': board}),

      react.div({
        'className': 'ui horizontal divider'
      }, [
        react.h3({'className': 'ui ${activePlayer?.color} header'},
            'Its ${activePlayer?.name ?? "Player"}\'s Turn'),
      ]),

      react.div({
        'className': 'ui basic vertical center aligned segment'
      }, [
        BoardSvg({'actions': actions, 'store': store}),
        react.div({
          'className': 'ui left internal attached rail',
          'style': {'width': 'auto'},
        }, [
          react.h4({'className': 'text'}, 'Exposed'),
          BarChart({
            'data': exposed,
            'fills': fills,
          }),
        ]),
        react.div({
          'className': 'ui right internal attached rail',
          'style': {'width': 'auto'},
        }, [
          react.h4({'className': 'text'}, 'In Play'),
          BarChart({
            'data': inPlay,
            'fills': fills,
          }),
        ]),
      ]),

      CurrentTurnOptions({'actions': actions, 'store': store}),
      // react.div({'className': 'ui horizontal divider'}, 'History'),
      // HistoryList({'actions': actions, 'store': store}),
    ]);
  }
}

part of catan.game_module;

var CurrentTurnOptions =
    react.registerComponent(() => new _CurrentTurnOptions());

class _CurrentTurnOptions extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    return react.div({
      'className': 'ui center aligned inverted segment'
    }, [
      react.div({
        'className': 'ui two column very relaxed grid'
      }, [
        react.div({
          'className': 'column'
        }, [
          react.h4({
            'className': 'header',
            'onClick': (_) => actions.showDimmer(DimmerType.Roll),
            'style': {'cursor': 'pointer'},
          }, 'Roll'),
        ]),
        react.div({
          'className': 'ui vertical divider'
        }, [
          react.i({'className': 'inverted chevron right icon'}),
        ]),
        react.div({
          'className': 'column'
        }, [
          react.h4({
            'className': 'header',
            'onClick': (_) => actions.showDimmer(DimmerType.Trade),
            'style': {'cursor': 'pointer'},
          }, 'Trade'),
        ]),
        // react.div({'className': 'ui vertical divider'}, [
        //   react.i({'className': 'inverted chevron right icon'}),
        // ]),
        // react.div({'className': 'column'}, [
        //   react.h4({'className': 'header'}, 'Build'),
        // ]),
        // react.div({'className': 'ui vertical divider'}, [
        //   react.i({'className': 'inverted chevron right icon'}),
        // ]),
        // react.div({'className': 'column'}, [
        //   react.h4({'className': 'header'}, 'Next'),
        // ]),
      ]),
    ]);
  }
}

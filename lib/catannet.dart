@JS('catannet')
library catannet;

import "package:js/js.dart";
export "src/catannet/catannet.dart";

@JS()
external Client NewClient(String url);


@JS()
class Client {
    external void OnLoadGame(Function handle);
}

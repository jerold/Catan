@JS('catannet')
library catannet;

import "package:js/js.dart";
part "src/catannet/catannet.dart";

@JS()
external Client NewClient();


typedef OnSaveFunction(SaveGameResponse sgr);
typedef OnLoadFunction(LoadGameResponse lgr);

@JS()
class Client {
    external void LoadGame(LoadGameRequest lg);
    external void SaveGame(SaveGameRequest sg);

    external void Dial(String url);

    external ClientEvents Events();
}

@JS()
class ClientEvents {
    external void OnSaveGame(OnSaveFunction handle);
    external void OnLoadGame(OnLoadFunction handle);
    external void OnConnect(Function handle);
}

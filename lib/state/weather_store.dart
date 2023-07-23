import 'package:flutter_mobx_tutorial/data/model/weather.dart';
import 'package:flutter_mobx_tutorial/data/weather_repository.dart';
import 'package:mobx/mobx.dart';

part 'weather_store.g.dart';

class WeatherStore extends _WeatherStore with _$WeatherStore {
  WeatherStore(super.weatherRepository);
}

enum StoredState { initial, loading, loaded }

abstract class _WeatherStore with Store {
  final WeatherRepository _weatherRepository;

  _WeatherStore(this._weatherRepository);

  @observable
  ObservableFuture<Weather>? _weatherFuture;

  @observable
  Weather ?weather;

  @observable
  String? errorMessage;

  @computed
  StoredState get state {
    if (_weatherFuture == null ||
        _weatherFuture?.status == FutureStatus.rejected) {
      return StoredState.initial;
    }
    return _weatherFuture?.status == FutureStatus.pending
        ? StoredState.loading
        : StoredState.loaded;
  }

  @action
  Future getWeather(String cityName) async {
    try {
      // Reset the possible previous error message.
      errorMessage = null;
      // Fetch weather from the repository and wrap the regular Future into an observable.
      // This _weatherFuture triggers updates to the computed state property.
      _weatherFuture = ObservableFuture(_weatherRepository.fetchWeather(cityName));
      // ObservableFuture extends Future - it can be awaited and exceptions will propagate as usual.
      weather = await _weatherFuture;
    } on NetworkError {
      errorMessage = "Couldn't fetch weather. Is the device online?";
    }
  }
}

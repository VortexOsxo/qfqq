class EventNotifier<T> {
  final _listeners = <void Function(T)>[];

  void subscribe(void Function(T) listener) {
    _listeners.add(listener);
  }

  void unsubscribe(void Function(T) listener) {
    _listeners.remove(listener);
  }

  void notify(T event) {
    for (var listener in _listeners) {
      listener(event);
    }
  }
}

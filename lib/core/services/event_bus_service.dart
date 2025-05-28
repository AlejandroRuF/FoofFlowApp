import 'dart:async';

enum RefreshEventType {
  orders,
  products,
  inventory,
  incidents,
  dashboard,
  profile,
}

class RefreshEvent {
  final RefreshEventType type;
  final Map<String, dynamic>? data;

  RefreshEvent(this.type, {this.data});
}

class EventBusService {
  static final EventBusService _instance = EventBusService._internal();
  factory EventBusService() => _instance;
  EventBusService._internal();

  final _controller = StreamController<RefreshEvent>.broadcast();

  Stream<RefreshEvent> get stream => _controller.stream;

  void publish(RefreshEvent event) {
    _controller.add(event);
  }

  void publishRefresh(RefreshEventType type, {Map<String, dynamic>? data}) {
    publish(RefreshEvent(type, data: data));
  }

  void dispose() {
    _controller.close();
  }
}

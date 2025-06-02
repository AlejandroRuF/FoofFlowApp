import 'dart:async';

enum RefreshEventType {
  orders,
  products,
  inventory,
  incidents,
  dashboard,
  profile,
  warehouse,
  all,
}

class RefreshEvent {
  final RefreshEventType type;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final String? eventId;

  RefreshEvent(this.type, {this.data, String? eventId})
    : timestamp = DateTime.now(),
      eventId = eventId ?? DateTime.now().millisecondsSinceEpoch.toString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RefreshEvent &&
        other.type == type &&
        other.eventId == eventId;
  }

  @override
  int get hashCode => type.hashCode ^ eventId.hashCode;
}

class EventBusService {
  static final EventBusService _instance = EventBusService._internal();
  factory EventBusService() => _instance;
  EventBusService._internal();

  final _controller = StreamController<RefreshEvent>.broadcast();
  final _dataChangedController = StreamController<String>.broadcast();

  final Set<String> _recentEvents = <String>{};
  final Map<String, DateTime> _lastEventTimes = <String, DateTime>{};
  Timer? _cleanupTimer;
  bool _isDisposed = false;
  static const Duration _eventDebounce = Duration(milliseconds: 300);

  Stream<RefreshEvent> get stream => _controller.stream;
  Stream<String> get dataChangedStream => _dataChangedController.stream;

  void publish(RefreshEvent event) {
    if (_isDisposed) return;

    final eventKey = '${event.type}_${event.eventId}';
    if (_recentEvents.contains(eventKey)) {
      return;
    }

    _recentEvents.add(eventKey);
    _scheduleCleanup();

    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  void publishRefresh(RefreshEventType type, {Map<String, dynamic>? data}) {
    if (_isDisposed) return;
    publish(RefreshEvent(type, data: data));
  }

  void publishDataChanged(
    String source, {
    Map<String, dynamic>? additionalData,
  }) {
    if (_isDisposed) return;

    final now = DateTime.now();
    final lastTime = _lastEventTimes[source];

    if (lastTime != null && now.difference(lastTime) < _eventDebounce) {
      return;
    }

    _lastEventTimes[source] = now;

    if (!_dataChangedController.isClosed) {
      _dataChangedController.add(source);
    }

    Map<String, dynamic> eventData = {'source': source};
    if (additionalData != null) {
      eventData.addAll(additionalData);
    }

    if (source.contains('inventory') || source.contains('warehouse')) {
      publishRefresh(RefreshEventType.inventory, data: eventData);
      publishRefresh(RefreshEventType.warehouse, data: eventData);
      publishRefresh(RefreshEventType.dashboard, data: eventData);
    } else if (source.contains('orders')) {
      publishRefresh(RefreshEventType.orders, data: eventData);
      publishRefresh(RefreshEventType.dashboard, data: eventData);
    } else if (source.contains('products')) {
      publishRefresh(RefreshEventType.products, data: eventData);
      publishRefresh(RefreshEventType.inventory, data: eventData);
      publishRefresh(RefreshEventType.dashboard, data: eventData);
    } else if (source.contains('incidents')) {
      publishRefresh(RefreshEventType.incidents, data: eventData);
      publishRefresh(RefreshEventType.dashboard, data: eventData);
    } else if (source.contains('profile')) {
      publishRefresh(RefreshEventType.profile, data: eventData);
    }
  }

  void _scheduleCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer(const Duration(seconds: 2), () {
      _recentEvents.clear();
      final now = DateTime.now();
      _lastEventTimes.removeWhere(
        (key, time) => now.difference(time) > const Duration(seconds: 5),
      );
    });
  }

  void dispose() {
    _isDisposed = true;
    _cleanupTimer?.cancel();
    _recentEvents.clear();
    _lastEventTimes.clear();

    if (!_controller.isClosed) {
      _controller.close();
    }
    if (!_dataChangedController.isClosed) {
      _dataChangedController.close();
    }
  }
}

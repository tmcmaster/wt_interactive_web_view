import 'package:wt_interactive_web_view/src/interactive_web_view_event_bus.dart';
import 'package:wt_interactive_web_view/src/utils/log.dart';

class InteractiveWebViewController {
  static final log = Log.d();

  final String name;
  late EventBusFlutter eventBus;
  final void Function(Map<String, dynamic>)? onEvent;

  InteractiveWebViewController({
    required this.name,
    this.onEvent,
  }) {
    eventBus = EventBusFlutter.getInstance(name);
    eventBus.addEventBusListener(receiveEvent);
  }

  void sendEvent(Map<String, dynamic> event) {
    log.d('InteractiveWebViewController : sendEvent : $event');
    eventBus.emitFromFlutter(event);
  }

  void receiveEvent(event) {
    log.d('InteractiveWebViewController : receiveEvent : $event');
    onEvent?.call(event);
  }

  dispose() {
    eventBus.removeEventBusListener(receiveEvent);
  }
}

import 'package:wt_interactive_web_view/interactive_web_view.dart';
import 'package:wt_logging/wt_logging.dart';

class InteractiveWebViewController {
  static final log = logger(InteractiveWebViewController, level: Level.debug);

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

  void sendEvent(GenericEvent event) {
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

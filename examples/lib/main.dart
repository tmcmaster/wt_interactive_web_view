import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:wt_interactive_web_view/interactive_web_view.dart';

// TODO: There is a condition where events go into infinite loop.

void main() async {
  debugPrint('MAIN Building');
  runApp(MaterialApp(
    title: 'Testing InAppWebView',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      useMaterial3: true,
    ),
    debugShowCheckedModeBanner: false,
    home: const CounterApp(),
  ));
}

class CounterApp extends StatefulWidget {
  const CounterApp({
    super.key,
  });

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  static final log = Logger(level: Level.debug, printer: SimplePrinter());

  static const double minValue = -50;
  static const double maxValue = 50;
  static const int increment = 5;

  late InteractiveWebViewController controller;
  int _counter = 20;

  @override
  void initState() {
    log.d('CounterApp.initState : Initialising the App');
    controller = InteractiveWebViewController(
      name: 'web-page',
      onEvent: onEvent,
    );
    super.initState();
  }

  void onEvent(GenericEvent event) {
    log.d('CounterApp.onEvent : $event');
    final newValue = event.data['rotation'];
    if (newValue != null && newValue != _counter) {
      setState(() {
        _counter = newValue;
      });
    }
  }

  @override
  void dispose() {
    log.d('CounterApp.dispose : Disposing the App');
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log.d('CounterApp.build : building material app');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    final newValue = _counter - increment;
                    if (newValue >= minValue) {
                      setState(() {
                        _counter = newValue;
                      });
                      controller.sendEvent(_rotationEvent(newValue));
                    }
                  },
                ),
                Slider(
                  min: minValue,
                  max: maxValue,
                  divisions: (maxValue - minValue) ~/ increment,
                  value: _counter.toDouble(),
                  onChanged: (value) {
                    final newValue = value.toInt();
                    if (newValue != _counter) {
                      setState(() {
                        _counter = newValue;
                      });
                      controller.sendEvent(_rotationEvent(newValue));
                    }
                  },
                ),
                SizedBox(
                  width: 24,
                  child: Text('$_counter'),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final newValue = _counter + increment;
                    if (newValue <= maxValue) {
                      setState(() {
                        _counter = newValue;
                      });
                      controller.sendEvent(_rotationEvent(newValue));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: InteractiveWebView(
                  controller: controller,
                  htmlUrl: '/assets/html/inner_page.html',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GenericEvent _rotationEvent(int degrees) {
    return GenericEvent(
      type: 'rotation',
      data: {'rotation': degrees},
    );
  }
}

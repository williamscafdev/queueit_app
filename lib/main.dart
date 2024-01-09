import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter To Native Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Native Code from Dart'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  static const flutterToNativeChannel = MethodChannel('flutter.native/helper');

  String _responseFromNativeCode =
      'Press the thumb icon to open the waiting room';

  // This is calling into native app
  Future<void> openQueueItWaitingRoom() async {
    String response = "";
    //This is to watch for method requests coming from native code
    flutterToNativeChannel
        .setMethodCallHandler((call) => flutterMethodCalledHandler(call));

    try {
      // This is to call into a method within the Native Code
      String result = await flutterToNativeChannel.invokeMethod(
        'openQueueItWaitingRoom',
        {
          'customerId': 'joinnus',
          'eventOrAliasId': 'pruebapp4',
        },
      );
      response = result;
    } on PlatformException catch (e) {
      response = "Failed to Invoke method in native: '${e.message}'.";
    }
    setState(() {
      _responseFromNativeCode = response;
    });
  }

  // This is receiving messages from native app
  Future<void> flutterMethodCalledHandler(MethodCall call) async {
    final String response = call.arguments;

    switch (call.method) {
      case "onQueuePassed":
        debugPrint('Response $response');
        break;
      case "onQueueDisabled":
        //TODO: This method is called in android platform but in iOS is not called
        debugPrint('Response $response');
        break;
      case "All other Methods":
        break;
      default:
        debugPrint('no method handler for method ${call.method}');
    }

    setState(() {
      _responseFromNativeCode = response;
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                  onPressed: _incrementCounter,
                  tooltip: 'Increment Counter',
                  child: const Icon(Icons.plus_one),
                ),
                const Text(
                  'You have pushed the button this many time(s):',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(_responseFromNativeCode),
                FloatingActionButton(
                  onPressed: openQueueItWaitingRoom,
                  tooltip: 'Open Waiting Room',
                  child: const Icon(Icons.thumb_up),
                ),
              ]),
        )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'services/service_manager.dart';
import 'widgets/firebase_status_widget.dart';
import 'pages/auth_demo_page.dart';
import 'pages/simple_auth_test.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set default environment (development)
  AppConfig.setEnvironment(Environment.dev);
  
  // Initialize Firebase
  try {
    await ServiceManager.initialize();
  } catch (e) {
    print('Service initialization failed: $e');
    // Continue without Firebase for now
  }
  
  runMainApp();
}

void runMainApp() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(title: '${AppConfig.appName} - ${AppConfig.environment.name.toUpperCase()}'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const FirebaseStatusWidget(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Environment: ${AppConfig.environment.name.toUpperCase()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Firebase: ${ServiceManager.isInitialized ? "Connected" : "Not Connected"}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ServiceManager.isInitialized ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('You have pushed the button this many times:'),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthDemoPage(),
                        ),
                      );
                    },
                    child: const Text('Try Firebase Auth'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SimpleAuthTest(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Simple Auth Test'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

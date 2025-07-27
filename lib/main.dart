import 'package:flutter/material.dart';
import 'auto_notify_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the AutoNotify SDK with configuration
  await autoNotify.init(
    config: const AutoNotifyConfig(
      notifyInitialize: 1, // Enable the SDK
      titlePool: [
        'Hey there!',
        'Miss you!',
        'Come back!',
      ],
      bodyPool: [
        'Come back and have fun!',
        'We have new content for you!',
        'Your friends are waiting for you!',
      ],
      hourStart: 9,
      hourEnd: 21,
      minuteJitter: 30,
      cooldownDays: 1,
    ),
    enableDebugLogs: true,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationState();
  }

  // Load the current notification state
  Future<void> _loadNotificationState() async {
    final enabled = autoNotify.isEnabled;
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  // Toggle notifications on/off
  Future<void> _toggleNotifications(bool value) async {
    await autoNotify.setEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Auto Notify SDK Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Text('Enable daily reminder notifications:'),
            const SizedBox(height: 10),
            Switch(
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => autoNotify.openSystemSettings(),
              child: const Text('Open System Settings'),
            ),
            const SizedBox(height: 30),
            if (autoNotify.nextScheduledTime != null)
              Text(
                'Next notification: ${autoNotify.nextScheduledTime.toString()}',
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

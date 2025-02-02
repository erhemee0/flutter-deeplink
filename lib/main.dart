import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

void main() {
  runApp(const MyApp());
}

bool isLoggedIn = false; // Global variable to track login status
String? pendingDeepLink; // Holds deep link until process completes
bool isProcessOngoing = false; // Tracks whether a process is ongoing

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Deep Link App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Deep Link Demo'),
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
  double _seconds = 0.0;
  Timer? _timer;
  String _deepLink = "No deep link received";
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() async {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        setState(() {
          _deepLink = uri.toString();
        });

        pendingDeepLink = uri.toString();
        if (!isProcessOngoing) {
          _mockApiRequest();
        }
      }
    }, onError: (err) {
      debugPrint("Error receiving deep link: $err");
    });
  }

  void _mockApiRequest() {
    setState(() {
      isProcessOngoing = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isProcessOngoing = false;
        isLoggedIn = true;
      });
      if (pendingDeepLink != null && isLoggedIn) {
        final deepLinkToNavigate = pendingDeepLink;
        pendingDeepLink = null;
        if (deepLinkToNavigate != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DeepLinkScreen(deepLink: deepLinkToNavigate),
            ),
          );
        }
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _seconds += 0.1;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      _seconds = 0.0;
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoggedIn = !isLoggedIn;
                  if (isLoggedIn &&
                      pendingDeepLink != null &&
                      !isProcessOngoing) {
                    _mockApiRequest();
                  }
                });
              },
              child: Text(isLoggedIn ? "Logout" : "Login"),
            ),
            const SizedBox(height: 20),
            const Text('Timer (in seconds):'),
            Text(
              _seconds.toStringAsFixed(2),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _startTimer,
                  child: const Text('Start Timer'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _stopTimer,
                  child: const Text('Stop Timer'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text('Reset Timer'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Deep Link Received:'),
            Text(
              _deepLink,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text('Process Ongoing:'),
            Text(
              isProcessOngoing ? "Yes" : "No",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class DeepLinkScreen extends StatelessWidget {
  final String deepLink;

  const DeepLinkScreen({super.key, required this.deepLink});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deep Link Opened")),
      body: Center(
        child: Text(
          "Deep Link: $deepLink",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

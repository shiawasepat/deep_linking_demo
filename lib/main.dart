import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;
  String _status = 'Waiting for link...';

  @override
  void initState() {
    super.initState();
    initAppLinks();
  }

  Future<void> initAppLinks() async {
    _appLinks = AppLinks();

    try {
      // 1️⃣ Handle initial link (when app opened from a link)
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleIncomingLink(initialUri);
      }

      // 2️⃣ Listen for links while app is running
      _sub = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          _handleIncomingLink(uri);
        },
        onError: (err) {
          setState(() => _status = 'Failed to receive link: $err');
        },
      );
    } catch (e) {
      setState(() => _status = 'Error initializing app links: $e');
    }
  }

  void _handleIncomingLink(Uri uri) {
    // Misal link: myapp://details?id=123
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'details') {
      final id = uri.queryParameters['id'] ?? 'unknown';
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(id: id)),
      );
    } else {
      setState(() => _status = 'Opened link: $uri');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deep Link Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: Center(child: Text(_status)),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String id;
  const DetailScreen({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: Center(child: Text('You opened item ID: $id')),
    );
  }
}

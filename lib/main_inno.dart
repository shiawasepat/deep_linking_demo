import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;
  String _status = 'Waiting for link...';
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initializeAppLinks();
  }

  void _initializeAppLinks() async {
    
    try {
      _appLinks = AppLinks();
      
      await Future.delayed(Duration(milliseconds: 200));
      
      _sub = _appLinks.uriLinkStream.listen(
        (uri) {
          _handleIncomingLink(uri);
        },
        onError: (err) {
          setState(() => _status = 'Failed to receive link: $err');
        },
      );
      

      final initialUri = await _appLinks.getInitialLink();
      
      if (initialUri != null) {
        Future.delayed(Duration(milliseconds: 500), () {
          _handleIncomingLink(initialUri);
        });
      } else {
        print('No initial URI found');
      }
      
      setState(() => _status = 'AppLinks initialized - ready for deep links');
      
    } catch (e) {
      setState(() => _status = 'Error initializing: $e');
    }
  }

  void _handleIncomingLink(Uri uri) {
    setState(() => _status = 'Received link: $uri');

    if (uri.host == 'details') {
      final id = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : 'unknown';

      _navigateToDetailScreen(id);
    } else {
    }
  }

  void _navigateToDetailScreen(String id) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailScreen(id: id)),
      );
      return;
    }

    Future.delayed(Duration(milliseconds: 100), () {
      final delayedContext = navigatorKey.currentContext;
      if (delayedContext != null) {
        Navigator.push(
          delayedContext,
          MaterialPageRoute(builder: (context) => DetailScreen(id: id)),
        );
      } else {
        setState(() => _status = 'Received link but cannot navigate - context unavailable');
      }
    });
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
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(title: Text('Home')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_status, textAlign: TextAlign.center),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailScreen(id: 'test')),
                  );
                },
                child: Text('Test Navigation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String id;
  const DetailScreen({required this.id});

  @override
  Widget build(BuildContext context) {
    print('DetailScreen built with ID: $id');
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You opened item ID: $id', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
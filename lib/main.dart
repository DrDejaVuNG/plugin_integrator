import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_integrator/ui/home_view.dart';

/// The main entry point of the application.
void main() {
  // Wrap the root widget with ProviderScope to enable Riverpod.
  runApp(ProviderScope(child: const MyApp()));
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Builds the main application widget.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Plugin Integrator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeView(),
    );
  }
}

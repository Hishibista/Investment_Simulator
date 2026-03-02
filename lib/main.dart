import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Investment Simulator',
      home: Scaffold(
        appBar: AppBar(title: const Text('Investment Simulator')),
        body: const Center(
          child: Text('App is running'),
        ),
      ),
    );
  }
}


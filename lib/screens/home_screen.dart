import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Investment Simulator")),
      body: const Center(
        child: Text("MVP starts here"),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:final_project/firebase_options.dart';
import 'package:final_project/theme.dart';
import 'package:final_project/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  runApp(ProviderScope(
    child: MyApp(firebaseInitialized: firebaseInitialized),
  ));
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;
  const MyApp({super.key, required this.firebaseInitialized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Investment Simulator',
      theme: AppTheme.darkTheme,
      home: firebaseInitialized 
          ? const HomeScreen() 
          : const Scaffold(
              body: Center(
                child: Text("Firebase could not be initialized. Please check your configuration."),
              ),
            ),
    );
  }
}


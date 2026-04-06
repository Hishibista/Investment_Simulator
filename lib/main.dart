import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:final_project/firebase_options.dart';
import 'package:final_project/theme.dart';
import 'package:final_project/screens/home_screen.dart';
import 'package:final_project/screens/portfolio_allocation_screen.dart';
import 'package:final_project/providers/auth_provider.dart';

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
          ? const AuthGate() 
          : const Scaffold(
              body: Center(
                child: Text("Firebase could not be initialized. Please check your configuration."),
              ),
            ),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (userProfile) {
        if (userProfile != null && userProfile.questionnaireData != null) {
          return const PortfolioAllocationScreen();
        }
        return const HomeScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => const HomeScreen(), // Fallback to home on error
    );
  }
}


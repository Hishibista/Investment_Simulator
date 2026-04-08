import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/screens/registration_screen.dart';
import 'package:final_project/screens/portfolio_allocation_screen.dart';
import 'package:final_project/screens/questionnaire_screen.dart';
import 'package:final_project/screens/sample_portfolio_button/sample_options_screen.dart';
import 'package:final_project/screens/user_profile_screen.dart';
import 'package:final_project/screens/login_screen.dart';
import 'package:final_project/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Investment Strategy"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              if (authState.value != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      //SafeArea ensures content does not overlap with system UI
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withAlpha(25), // ~0.1 opacity
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: theme.colorScheme.secondary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Build Your Future\nPortfolio Today",
                style: theme.textTheme.displayLarge?.copyWith(
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Personalized investment strategies based on your risk profile and financial goals.",
                style: theme.textTheme.bodyLarge,
              ),
              //Spacer pushes buttons to the bottom of the screen
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(

                  //when pressed, navigate the registration screen or dashboard
                  onPressed: () {
                    if (authState.value != null) {
                      userProfileAsync.maybeWhen(
                        data: (profile) {
                          if (profile != null && profile.questionnaireData != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PortfolioAllocationScreen()),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const QuestionnaireScreen()),
                            );
                          }
                        },
                        orElse: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const QuestionnaireScreen()),
                          );
                        },
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrationScreen(),
                        ),
                      );
                    }
                  },
                  child: Text(
                    authState.value != null
                        ? userProfileAsync.maybeWhen(
                            data: (profile) => profile != null && profile.questionnaireData != null
                                ? "Go to Dashboard"
                                : "Start Questionnaire",
                            orElse: () => "Start Questionnaire",
                          )
                        : "Get Started",
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  //Navigates to the samples screen
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SampleOptionsScreen(),
                      ),
                    );
                  },
                  child: const Text("View Samples"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
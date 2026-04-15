import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/questionnaire_provider.dart';
import 'dashboard_screen.dart';

class QuestionnaireScreen extends ConsumerStatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  ConsumerState<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _navigateToResults(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionnaire = ref.watch(questionnaireProvider);
    final notifier = ref.read(questionnaireProvider.notifier);
    final theme = Theme.of(context);

    if (questionnaire.currentStep == 5 && _amountController.text.isEmpty && questionnaire.initialInvestmentAmount != null) {
      _amountController.text = questionnaire.initialInvestmentAmount.toString();
    }

    final List<Widget> steps = [
      _buildSection(
        context,
        "1. Investment Objective",
        ["Grow wealth", "Preserve wealth"],
        questionnaire.investmentObjective,
        (val) => notifier.setInvestmentObjective(val),
      ),
      _buildSection(
        context,
        "2. Financial Goals",
        ["Buy a house", "Pay for education", "Retirement", "Other"],
        questionnaire.financialGoal,
        (val) => notifier.setFinancialGoal(val),
      ),
      _buildSection(
        context,
        "3. Risk Tolerance",
        [
          "High risk / High return",
          "Medium risk / Medium return",
          "Low risk / Low return",
          "No preference"
        ],
        questionnaire.riskTolerance,
        (val) => notifier.setRiskTolerance(val),
      ),
      _buildSection(
        context,
        "4. Time Horizon",
        ["Less than 3 years", "3–7 years", "7–15 years", "15+ years"],
        questionnaire.timeHorizon,
        (val) => notifier.setTimeHorizon(val),
      ),
      _buildSection(
        context,
        "5. Financial Profile",
        ["Student", "Early career", "Mid-career", "Near retirement"],
        questionnaire.financialProfile,
        (val) => notifier.setFinancialProfile(val),
      ),
      _buildAmountStep(
        context,
        "6. Initial Investment",
        "Enter the amount you plan to invest initially.",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Questionnaire"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (questionnaire.currentStep > 0) {
              notifier.previousStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Step ${questionnaire.currentStep + 1} of 6",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${((questionnaire.currentStep + 1) / 6 * 100).toInt()}%",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (questionnaire.currentStep + 1) / 6,
                      backgroundColor: theme.colorScheme.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: steps[questionnaire.currentStep],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (questionnaire.currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => notifier.previousStep(),
                        child: const Text("Back"),
                      ),
                    ),
                  if (questionnaire.currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: notifier.canMoveToNextStep()
                          ? () async {
                              if (questionnaire.currentStep < 5) {
                                notifier.nextStep();
                              } else {
                                try {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(child: CircularProgressIndicator()),
                                  );

                                  try {
                                    await notifier.saveToFirestore();
                                    if (context.mounted) {
                                      Navigator.pop(context); // Close loading
                                      _navigateToResults(context);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      Navigator.pop(context); // Close loading
                                      debugPrint("Questionnaire save error: $e");
                                      String errorMessage = e.toString();
                                      if (errorMessage.contains("permission-denied") || errorMessage.contains("insufficient permissions")) {
                                        errorMessage = "Results shown but not saved. Action Required: Please go to the Firebase Console -> Build -> Firestore -> Rules, and ensure you have published your security rules. Also verify the 'users' collection allows writes for authenticated users.";
                                      }
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Note: $errorMessage"),
                                          duration: const Duration(seconds: 10),
                                          action: SnackBarAction(label: "OK", onPressed: () {}),
                                        ),
                                      );
                                      _navigateToResults(context);
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    Navigator.pop(context); // Safety pop
                                  }
                                }
                              }
                            }
                          : null,
                      child: Text(questionnaire.currentStep == 5 ? "See Results" : "Next"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<String> options,
    String? selectedValue,
    void Function(String) onSelected,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: options.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = selectedValue == option;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.secondary : Colors.white.withValues(alpha: 0.1),
                    width: 2,
                  ),
                  color: isSelected 
                      ? theme.colorScheme.secondary.withValues(alpha: 0.1) 
                      : theme.colorScheme.surface,
                ),
                child: InkWell(
                  onTap: () => onSelected(option),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        Radio<String>(
                          value: option,
                          groupValue: selectedValue,
                          onChanged: (value) {
                            if (value != null) onSelected(value);
                          },
                          activeColor: theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountStep(BuildContext context, String title, String subtitle) {
    final theme = Theme.of(context);
    final notifier = ref.read(questionnaireProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 24),
          decoration: InputDecoration(
            prefixText: "\$ ",
            prefixStyle: const TextStyle(color: Colors.white, fontSize: 24),
            hintText: "0.00",
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.secondary),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          onChanged: (value) {
            final double? amount = double.tryParse(value);
            if (amount != null) {
              notifier.setInitialInvestmentAmount(amount);
            }
          },
        ),
      ],
    );
  }
}

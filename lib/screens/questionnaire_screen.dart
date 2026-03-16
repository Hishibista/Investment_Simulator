import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/questionnaire_provider.dart';

class QuestionnaireScreen extends ConsumerWidget {
  const QuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //watch the questionnaire state, updates UI when state changes
    final questionnaire = ref.watch(questionnaireProvider);

    //access questionnaire to update the questionnaire state
    final notifier = ref.read(questionnaireProvider.notifier);

    //access the theme for consistent styling
    final theme = Theme.of(context);

    final List<Widget> steps = [
      _buildSection(
        context,
        "1. Investment Objective",
        ["Grow wealth", "Preserve wealth"],
        questionnaire.investmentObjective,
        notifier.setInvestmentObjective,
      ),
      _buildSection(
        context,
        "2. Financial Goals",
        ["Buy a house", "Pay for education", "Retirement", "Other"],
        questionnaire.financialGoal,
        notifier.setFinancialGoal,
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
        notifier.setRiskTolerance,
      ),
      _buildSection(
        context,
        "4. Time Horizon",
        ["Less than 3 years", "3–7 years", "7–15 years", "15+ years"],
        questionnaire.timeHorizon,
        notifier.setTimeHorizon,
      ),
      _buildSection(
        context,
        "5. Financial Profile",
        ["Student", "Early career", "Mid-career", "Near retirement"],
        questionnaire.financialProfile,
        notifier.setFinancialProfile,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Questionnaire"),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {

            //if user is not on first step, go to previous
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
            // Progress Indicator
            //shows which step we are currently on
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //shows step number and completion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //current step text
                      Text(
                        "Step ${questionnaire.currentStep + 1} of 5",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      //percentage completion
                      Text(
                        "${((questionnaire.currentStep + 1) / 5 * 100).toInt()}%",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (questionnaire.currentStep + 1) / 5,
                    backgroundColor: theme.colorScheme.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                    borderRadius: BorderRadius.circular(4),
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

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  //back button only appears after step 1
                  if (questionnaire.currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: notifier.previousStep,
                        child: const Text("Back"),
                      ),
                    ),
                  if (questionnaire.currentStep > 0) 
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      //only allow next step if question is answered
                      onPressed: notifier.canMoveToNextStep()
                          ? () {
                            //if not on final step - go forward
                              if (questionnaire.currentStep < 4) {
                                notifier.nextStep();

                                //if final step - show completion message
                              } else {
                                // Final step - navigation to results will be handled later
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Questionnaire Complete!")),
                                );
                              }
                            }
                          : null,
                      child: Text(questionnaire.currentStep == 4 ? "See Results" : "Next"),
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
    List<String> options, //answer choices 
    String? selectedValue, //currently selected answer 
    Function(String) onSelected, //function to call when selected
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //question title 
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 24),

        //list of selectable options
        Expanded(
          child: ListView.separated(
            itemCount: options.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final option = options[index];

              //check if this option is selected 
              final isSelected = selectedValue == option;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  //highlight border if selected 
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.secondary : Colors.white.withAlpha(25),
                    width: 2,
                  ),
                  // highlight background if selected 
                  color: isSelected 
                      ? theme.colorScheme.secondary.withAlpha(25) 
                      : theme.colorScheme.surface,
                ),
                // radio list tile creates selectable options
                child: RadioListTile<String>(
                  title: Text(
                    option,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  value: option,
                  groupValue: selectedValue,
                  onChanged: (value) {
                    if (value != null) onSelected(value);
                  },
                  activeColor: theme.colorScheme.secondary,
                  controlAffinity: ListTileControlAffinity.trailing,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

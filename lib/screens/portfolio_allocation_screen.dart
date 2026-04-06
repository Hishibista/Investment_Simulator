import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'registration_screen.dart';
import '../providers/questionnaire_provider.dart';
import '../providers/auth_provider.dart';
import '../models/portfolio_sample.dart';
import '../models/questionnaire.dart';

class PortfolioAllocationScreen extends ConsumerWidget {
  const PortfolioAllocationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);
    final questionnaireInMemory = ref.watch(questionnaireProvider);

    // Prefer data from Firestore (via userProfileProvider)
    // If not available, fall back to in-memory state
    final Questionnaire questionnaire = userProfileAsync.maybeWhen(
      data: (profile) {
        if (profile != null && profile.questionnaireData != null) {
          final data = profile.questionnaireData!;
          return Questionnaire(
            investmentObjective: data['investmentObjective'] as String?,
            financialGoal: data['financialGoal'] as String?,
            riskTolerance: data['riskTolerance'] as String?,
            timeHorizon: data['timeHorizon'] as String?,
            financialProfile: data['financialProfile'] as String?,
            initialInvestmentAmount: (data['initialInvestmentAmount'] as num?)?.toDouble(),
          );
        }
        return questionnaireInMemory;
      },
      orElse: () => questionnaireInMemory,
    );

    // Determine the portfolio based on risk tolerance and objective
    PortfolioSample selectedPortfolio = portfolioSamples[1]; // Default to Medium Risk

    if (questionnaire.investmentObjective == "Preserve wealth") {
      selectedPortfolio = portfolioSamples[3]; // Conservative
    } else {
      switch (questionnaire.riskTolerance) {
        case "High risk / High return":
          selectedPortfolio = portfolioSamples[0];
          break;
        case "Medium risk / Medium return":
          selectedPortfolio = portfolioSamples[1];
          break;
        case "Low risk / Low return":
          selectedPortfolio = portfolioSamples[2];
          break;
        case "No preference":
          selectedPortfolio = portfolioSamples[1]; // Balanced
          break;
      }
    }

    final double investmentAmount = questionnaire.initialInvestmentAmount ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Personalized Portfolio"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Based on your profile, we recommend a:",
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                selectedPortfolio.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Initial Investment", style: TextStyle(color: Colors.grey)),
                        Text(
                          "\$${investmentAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.width * 0.7,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: MediaQuery.of(context).size.width * 0.12,
                      sections: selectedPortfolio.assets.map((asset) {
                        return PieChartSectionData(
                          color: asset.color,
                          value: asset.percentage,
                          title: '${asset.percentage.toInt()}%',
                          radius: MediaQuery.of(context).size.width * 0.18,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Asset Distribution",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedPortfolio.assets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final asset = selectedPortfolio.assets[index];
                  final double amount = (asset.percentage / 100) * investmentAmount;
                  return _AllocationCard(asset: asset, amount: amount);
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text("Go to Dashboard"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


class _AllocationCard extends StatelessWidget {
  final PortfolioAsset asset;
  final double amount;

  const _AllocationCard({required this.asset, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: asset.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                Text(
                  "${asset.percentage.toInt()}% of portfolio",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

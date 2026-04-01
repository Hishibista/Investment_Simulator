import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/providers/auth_provider.dart';
import 'package:final_project/models/user_profile.dart';
import 'package:final_project/models/portfolio_sample.dart';
import 'package:fl_chart/fl_chart.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  PortfolioSample _calculatePortfolio(Map<String, dynamic> data) {
    if (data['investmentObjective'] == "Preserve wealth") {
      return portfolioSamples[3]; // Conservative
    }
    final risk = data['riskTolerance'];
    switch (risk) {
      case "High risk / High return":
        return portfolioSamples[0];
      case "Medium risk / Medium return":
        return portfolioSamples[1];
      case "Low risk / Low return":
        return portfolioSamples[2];
      default:
        return portfolioSamples[1];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authStateProvider).value;
    final theme = Theme.of(context);

    if (authUser == null) {
      return const Scaffold(
        body: Center(child: Text("Please sign in to view your profile.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authServiceProvider).signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<UserProfile?>(
        future: ref.read(authServiceProvider).getUserProfile(authUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text("Error fetching profile."));
          }

          final data = profile.questionnaireData;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard("Account Details", [
                  _buildDetailRow("Email", profile.email),
                  _buildDetailRow("Joined", profile.createdAt.toString().split(' ')[0]),
                ]),
                const SizedBox(height: 24),
                if (data != null) ...[
                  _buildInfoCard("Investment Preferences", [
                    _buildDetailRow("Objective", data['investmentObjective'] ?? "N/A"),
                    _buildDetailRow("Goal", data['financialGoal'] ?? "N/A"),
                    _buildDetailRow("Risk Tolerance", data['riskTolerance'] ?? "N/A"),
                    _buildDetailRow("Time Horizon", data['timeHorizon'] ?? "N/A"),
                    _buildDetailRow("Financial Profile", data['financialProfile'] ?? "N/A"),
                  ]),
                  const SizedBox(height: 24),
                  Text("Your Portfolio", style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  _buildPortfolioSection(context, data),
                ] else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No questionnaire data found. Complete the questionnaire to see your portfolio."),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection(BuildContext context, Map<String, dynamic> data) {
    final portfolio = _calculatePortfolio(data);
    final amount = (data['initialInvestmentAmount'] as num?)?.toDouble() ?? 0.0;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: portfolio.assets.map((asset) {
                return PieChartSectionData(
                  color: asset.color,
                  value: asset.percentage,
                  title: '${asset.percentage.toInt()}%',
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(portfolio.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 8),
        Text("Initial Investment: \$${amount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ...portfolio.assets.map((asset) => ListTile(
              leading: CircleAvatar(backgroundColor: asset.color, radius: 8),
              title: Text(asset.label),
              trailing: Text("\$${((asset.percentage / 100) * amount).toStringAsFixed(2)}"),
            )),
      ],
    );
  }
}

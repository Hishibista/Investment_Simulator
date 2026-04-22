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
    final userProfileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

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
      body: userProfileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text("Please sign in to view your profile."));
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
                  _buildInfoCard(
                    "Investment Preferences",
                    [
                      _buildDetailRow("Objective", data['investmentObjective'] ?? "N/A"),
                      _buildDetailRow("Goals", (data['financialGoals'] as List<dynamic>?)?.join(", ") ?? data['financialGoal'] ?? "N/A"),
                      _buildDetailRow("Risk Tolerance", data['riskTolerance'] ?? "N/A"),
                      _buildDetailRow("Time Horizon", data['timeHorizon'] ?? "N/A"),
                      _buildDetailRow("Financial Profile", data['financialProfile'] ?? "N/A"),
                    ],
                    onEdit: () => _showEditPreferencesDialog(context, ref, profile),
                  ),
                  const SizedBox(height: 24),
                  Text("Your Portfolio", style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  _buildPortfolioSection(context, ref, profile, data),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children, {VoidCallback? onEdit}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.green),
                    onPressed: onEdit,
                  ),
              ],
            ),
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

  Widget _buildPortfolioSection(BuildContext context, WidgetRef ref, UserProfile profile, Map<String, dynamic> data) {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Initial Investment: \$${amount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.grey)),
            IconButton(
              icon: const Icon(Icons.edit, size: 16, color: Colors.green),
              onPressed: () => _showEditInvestmentDialog(context, ref, profile),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...portfolio.assets.map((asset) => ListTile(
              leading: CircleAvatar(backgroundColor: asset.color, radius: 8),
              title: Text(asset.label),
              trailing: Text("\$${((asset.percentage / 100) * amount).toStringAsFixed(2)}"),
            )),
      ],
    );
  }

  void _showEditPreferencesDialog(BuildContext context, WidgetRef ref, UserProfile profile) {
    final data = Map<String, dynamic>.from(profile.questionnaireData ?? {});
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Preferences"),
              scrollable: true,
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDropdownField(
                      "Objective",
                      data['investmentObjective'],
                      ["Grow wealth", "Preserve wealth"],
                      (val) => setState(() => data['investmentObjective'] = val),
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Financial Goals (up to 3)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ["Buy a house", "Pay for education", "Retirement", "Other"].map((goal) {
                        final goals = List<String>.from(data['financialGoals'] ?? (data['financialGoal'] != null ? [data['financialGoal']] : []));
                        final isSelected = goals.contains(goal);
                        return FilterChip(
                          label: Text(goal, style: TextStyle(fontSize: 12, color: isSelected ? Colors.black : Colors.white)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                if (goals.length < 3) {
                                  goals.add(goal);
                                }
                              } else {
                                goals.remove(goal);
                              }
                              data['financialGoals'] = goals;
                              data.remove('financialGoal'); // Clean up old field
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdownField(
                      "Risk Tolerance",
                      data['riskTolerance'],
                      ["High risk / High return", "Medium risk / Medium return", "Low risk / Low return", "No preference"],
                      (val) => setState(() => data['riskTolerance'] = val),
                    ),
                    _buildDropdownField(
                      "Time Horizon",
                      data['timeHorizon'],
                      ["Less than 3 years", "3–7 years", "7–15 years", "15+ years"],
                      (val) => setState(() => data['timeHorizon'] = val),
                    ),
                    _buildDropdownField(
                      "Financial Profile",
                      data['financialProfile'],
                      ["Student", "Early career", "Mid-career", "Near retirement"],
                      (val) => setState(() => data['financialProfile'] = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    final confirmed = await _showConfirmationDialog(
                      context,
                      title: "Update Preferences",
                      message: "Are you sure you want to update your investment preferences? This will recalculate your suggested portfolio.",
                    );
                    if (confirmed == true) {
                      await ref.read(authServiceProvider).updateQuestionnaireData(profile.uid, data);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditInvestmentDialog(BuildContext context, WidgetRef ref, UserProfile profile) {
    final data = Map<String, dynamic>.from(profile.questionnaireData ?? {});
    final controller = TextEditingController(text: (data['initialInvestmentAmount'] ?? 0).toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Investment"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Initial Investment Amount",
              prefixText: "\$",
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(controller.text);
                if (amount != null) {
                  final confirmed = await _showConfirmationDialog(
                    context,
                    title: "Update Investment",
                    message: "Update your initial investment amount to \$${amount.toStringAsFixed(2)}?",
                  );
                  if (confirmed == true) {
                    data['initialInvestmentAmount'] = amount;
                    await ref.read(authServiceProvider).updateQuestionnaireData(profile.uid, data);
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, {required String title, required String message}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: options.map((opt) => DropdownMenuItem(
          value: opt, 
          child: Text(
            opt,
            overflow: TextOverflow.ellipsis,
          ),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../providers/questionnaire_provider.dart';
import '../providers/auth_provider.dart';
import '../models/questionnaire.dart';
import 'user_profile_screen.dart';
import 'home_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedInterval = '10Y';

  double _getGrowthRate(String? riskTolerance, String? objective) {
    if (objective == "Preserve wealth") return 0.04; // Low risk

    switch (riskTolerance) {
      case "High risk / High return":
        return 0.11;
      case "Medium risk / Medium return":
        return 0.07;
      case "Low risk / Low return":
        return 0.04;
      default:
        return 0.07;
    }
  }

  List<FlSpot> _generateGrowthSpots(double initialAmount, double annualRate) {
    // We'll show points for 0, 1M, 6M, 1Y, 5Y, 10Y
    // X axis indices: 0, 1, 2, 3, 4, 5
    
    double v0 = initialAmount;
    double v1m = initialAmount * math.pow(1 + annualRate / 12, 1);
    double v6m = initialAmount * math.pow(1 + annualRate / 12, 6);
    double v1y = initialAmount * math.pow(1 + annualRate, 1);
    double v5y = initialAmount * math.pow(1 + annualRate, 5);
    double v10y = initialAmount * math.pow(1 + annualRate, 10);

    return [
      FlSpot(0, v0),
      FlSpot(1, v1m),
      FlSpot(2, v6m),
      FlSpot(3, v1y),
      FlSpot(4, v5y),
      FlSpot(5, v10y),
    ];
  }

  String _getBottomTitle(double value) {
    switch (value.toInt()) {
      case 0: return 'Start';
      case 1: return '1M';
      case 2: return '6M';
      case 3: return '1Y';
      case 4: return '5Y';
      case 5: return '10Y';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);
    final questionnaireInMemory = ref.watch(questionnaireProvider);

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

    final double initialAmount = questionnaire.initialInvestmentAmount ?? 0.0;
    final double rate = _getGrowthRate(questionnaire.riskTolerance, questionnaire.investmentObjective);
    final spots = _generateGrowthSpots(initialAmount, rate);
    final double projectedValue = spots.last.y;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Portfolio Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Growth Overview",
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Projected performance over 10 years",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildValueCard("Initial", initialAmount, theme),
                _buildValueCard("Projected (10Y)", projectedValue, theme, isHighlight: true),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              height: 300,
              padding: const EdgeInsets.only(right: 16, top: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _getBottomTitle(value),
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: theme.colorScheme.secondary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) => Colors.grey[900]!,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${_getBottomTitle(spot.x)}: \$${spot.y.toStringAsFixed(0)}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoSection(theme, questionnaire.riskTolerance ?? "Medium", rate),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text("Go to Home"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCard(String label, double value, ThemeData theme, {bool isHighlight = false}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: isHighlight ? 0 : 8, left: isHighlight ? 8 : 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlight 
              ? theme.colorScheme.secondary.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlight 
                ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              "\$${value.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isHighlight ? theme.colorScheme.secondary : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, String risk, double rate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow("Risk Profile", risk),
          const Divider(height: 24, color: Colors.white10),
          _buildInfoRow("Expected Return", "${(rate * 100).toStringAsFixed(0)}% annually"),
          const Divider(height: 24, color: Colors.white10),
          _buildInfoRow("Compounding", "Monthly"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

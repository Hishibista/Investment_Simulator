import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/effective_questionnaire_provider.dart';
import '../providers/growth_simulation_provider.dart';
import 'user_profile_screen.dart';
import 'home_screen.dart';

//This is the portfolio tracker page
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
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
    final questionnaire = ref.watch(effectiveQuestionnaireProvider);
    final simulation = ref.watch(growthSimulationProvider);

    final double initialAmount = questionnaire.initialInvestmentAmount ?? 0.0;
    final spots = simulation.spots;
    final double projectedValue = simulation.projectedValue;
    final bool isNegativeGrowth = projectedValue < initialAmount;
    final Color chartColor = isNegativeGrowth ? Colors.redAccent : theme.colorScheme.secondary;

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
              "Projected performance over 10 years (Simulated)",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildValueCard("Initial", initialAmount, theme),
                _buildValueCard(
                  "Projected (10Y)",
                  projectedValue,
                  theme,
                  isHighlight: true,
                  highlightColor: chartColor,
                ),
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
                      color: chartColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: chartColor.withValues(alpha: 0.2),
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
            _buildInfoSection(theme, questionnaire.riskTolerance ?? "Medium", simulation.annualReturns),
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

  Widget _buildValueCard(String label, double value, ThemeData theme, {bool isHighlight = false, Color? highlightColor}) {
    final Color displayColor = highlightColor ?? theme.colorScheme.secondary;
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: isHighlight ? 0 : 8, left: isHighlight ? 8 : 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlight 
              ? displayColor.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlight 
                ? displayColor.withValues(alpha: 0.3)
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
                color: isHighlight ? displayColor : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, String risk, List<double> returns) {
    double avgReturn = returns.reduce((a, b) => a + b) / returns.length;
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
          _buildInfoRow("Avg. Simulation Return", "${(avgReturn * 100).toStringAsFixed(1)}% annually"),
          const Divider(height: 24, color: Colors.white10),
          _buildInfoRow("Simulation", "Randomized Yearly"),
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

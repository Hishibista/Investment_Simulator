import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'effective_questionnaire_provider.dart';

class GrowthSimulation {
  final List<FlSpot> spots;
  final List<double> annualReturns;
  final double projectedValue;

  GrowthSimulation({
    required this.spots,
    required this.annualReturns,
    required this.projectedValue,
  });
}

final growthSimulationProvider = Provider<GrowthSimulation>((ref) {
  final questionnaire = ref.watch(effectiveQuestionnaireProvider);
  final initialAmount = questionnaire.initialInvestmentAmount ?? 0.0;
  final riskTolerance = questionnaire.riskTolerance;
  final objective = questionnaire.investmentObjective;

  double minReturn, maxReturn;

  if (objective == "Preserve wealth") {
    minReturn = 0.02;
    maxReturn = 0.05;
  } else {
    switch (riskTolerance) {
      case "High risk / High return":
        minReturn = -0.20;
        maxReturn = 0.25;
        break;
      case "Medium risk / Medium return":
        minReturn = -0.10;
        maxReturn = 0.15;
        break;
      case "Low risk / Low return":
        minReturn = -0.05;
        maxReturn = 0.08;
        break;
      default:
        minReturn = -0.10;
        maxReturn = 0.15; // default to medium
    }
  }

  final math.Random random = math.Random();
  final List<double> annualReturns = [];
  for (int i = 0; i < 10; i++) {
    annualReturns.add(minReturn + random.nextDouble() * (maxReturn - minReturn));
  }

  // Calculate spots
  double v0 = initialAmount;
  
  // Year 1 breakdown
  double r1 = annualReturns[0];
  // Using simple monthly fraction for sub-year points
  double v1m = v0 * (1 + (r1 / 12));
  double v6m = v0 * (1 + (r1 / 2));
  double v1y = v0 * (1 + r1);

  // Year 5
  double v5y = v1y;
  for (int i = 1; i < 5; i++) {
    v5y *= (1 + annualReturns[i]);
  }

  // Year 10
  double v10y = v5y;
  for (int i = 5; i < 10; i++) {
    v10y *= (1 + annualReturns[i]);
  }

  final spots = [
    FlSpot(0, v0),
    FlSpot(1, v1m),
    FlSpot(2, v6m),
    FlSpot(3, v1y),
    FlSpot(4, v5y),
    FlSpot(5, v10y),
  ];

  return GrowthSimulation(
    spots: spots,
    annualReturns: annualReturns,
    projectedValue: v10y,
  );
});

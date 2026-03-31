class Questionnaire {
  final String? investmentObjective;
  final String? financialGoal;
  final String? riskTolerance;
  final String? timeHorizon;
  final String? financialProfile;
  final double? initialInvestmentAmount;
  final int currentStep;

  Questionnaire({
    this.investmentObjective,
    this.financialGoal,
    this.riskTolerance,
    this.timeHorizon,
    this.financialProfile,
    this.initialInvestmentAmount,
    this.currentStep = 0,
  });

  Questionnaire copyWith({
    String? investmentObjective,
    String? financialGoal,
    String? riskTolerance,
    String? timeHorizon,
    String? financialProfile,
    double? initialInvestmentAmount,
    int? currentStep,
  }) {
    return Questionnaire(
      investmentObjective: investmentObjective ?? this.investmentObjective,
      financialGoal: financialGoal ?? this.financialGoal,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      timeHorizon: timeHorizon ?? this.timeHorizon,
      financialProfile: financialProfile ?? this.financialProfile,
      initialInvestmentAmount: initialInvestmentAmount ?? this.initialInvestmentAmount,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

class Questionnaire {
  final String? investmentObjective;
  final List<String>? financialGoals;
  final String? riskTolerance;
  final String? timeHorizon;
  final String? financialProfile;
  final double? initialInvestmentAmount;
  final int currentStep;

  Questionnaire({
    this.investmentObjective,
    this.financialGoals,
    this.riskTolerance,
    this.timeHorizon,
    this.financialProfile,
    this.initialInvestmentAmount,
    this.currentStep = 0,
  });

  Questionnaire copyWith({
    String? investmentObjective,
    List<String>? financialGoals,
    String? riskTolerance,
    String? timeHorizon,
    String? financialProfile,
    double? initialInvestmentAmount,
    int? currentStep,
  }) {
    return Questionnaire(
      investmentObjective: investmentObjective ?? this.investmentObjective,
      financialGoals: financialGoals ?? this.financialGoals,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      timeHorizon: timeHorizon ?? this.timeHorizon,
      financialProfile: financialProfile ?? this.financialProfile,
      initialInvestmentAmount: initialInvestmentAmount ?? this.initialInvestmentAmount,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/questionnaire.dart';

class QuestionnaireNotifier extends StateNotifier<Questionnaire> {
  QuestionnaireNotifier() : super(Questionnaire());

  void setInvestmentObjective(String value) {
    state = state.copyWith(investmentObjective: value);
    nextStep();
  }

  void setFinancialGoal(String value) {
    state = state.copyWith(financialGoal: value);
    nextStep();
  }

  void setRiskTolerance(String value) {
    state = state.copyWith(riskTolerance: value);
    nextStep();
  }

  void setTimeHorizon(String value) {
    state = state.copyWith(timeHorizon: value);
    nextStep();
  }

  void setFinancialProfile(String value) {
    state = state.copyWith(financialProfile: value);
  }
  
  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void reset() {
    state = Questionnaire();
  }

  bool isComplete() {
    return state.investmentObjective != null &&
        state.financialGoal != null &&
        state.riskTolerance != null &&
        state.timeHorizon != null &&
        state.financialProfile != null;
  }
  
  bool canMoveToNextStep() {
    switch (state.currentStep) {
      case 0: return state.investmentObjective != null;
      case 1: return state.financialGoal != null;
      case 2: return state.riskTolerance != null;
      case 3: return state.timeHorizon != null;
      case 4: return state.financialProfile != null;
      default: return false;
    }
  }
}

final questionnaireProvider = StateNotifierProvider<QuestionnaireNotifier, Questionnaire>((ref) {
  return QuestionnaireNotifier();
});

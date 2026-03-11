import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/questionnaire.dart';

//Class controls and updates the questionnaire data
// Extends to stateNotifier so riverpod can track changes in state
class QuestionnaireNotifier extends StateNotifier<Questionnaire> {
  QuestionnaireNotifier() : super(Questionnaire()); 
  //super(Questionnaire()) start the state with empty questionnaire

//calls investment objective and gets value of either growth or preserve
  void setInvestmentObjective(String value) {
    //Updates the questionnaire data stored in riverpod
    //copywith - instead of editing object directly,
    //it creates a new copy and updates only the field specified
    state = state.copyWith(investmentObjective: value);
    nextStep();
  }
  //moves to financial goal 
  void setFinancialGoal(String value) {
    //creates new copy with selected option
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
  // Clears all answers and restarts questionnaire
  void reset() {
    state = Questionnaire();
  }

  bool isComplete() {
    // Return true only if all fields have values
    return state.investmentObjective != null &&
        state.financialGoal != null &&
        state.riskTolerance != null &&
        state.timeHorizon != null &&
        state.financialProfile != null;
  }
  
  bool canMoveToNextStep() {
    //check current step and verify required input exists
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
//This exposes questionnaireNotifier so UI can access it
//stateNotifierProvider allows UI widgets to 
//update questionnaire using the notifier
final questionnaireProvider = StateNotifierProvider<QuestionnaireNotifier, Questionnaire>((ref) {
  return QuestionnaireNotifier();
});

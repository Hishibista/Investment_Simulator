import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/questionnaire.dart';
import 'auth_provider.dart';

//Class controls and updates the questionnaire data
// Extends to stateNotifier so riverpod can track changes in state
class QuestionnaireNotifier extends StateNotifier<Questionnaire> {
  final Ref _ref;
  QuestionnaireNotifier(this._ref) : super(Questionnaire()); 
  //super(Questionnaire()) start the state with empty questionnaire

//calls investment objective and gets value of either growth or preserve
  void setInvestmentObjective(String value) {
    //Updates the questionnaire data stored in riverpod
    //copywith - instead of editing object directly,
    //it creates a new copy and updates only the field specified
    state = state.copyWith(investmentObjective: value);
  }
  //moves to financial goal 
  void setFinancialGoal(String value) {
    //creates new copy with selected option
    state = state.copyWith(financialGoal: value);
  }

  void setRiskTolerance(String value) {
    state = state.copyWith(riskTolerance: value);
  }

  void setTimeHorizon(String value) {
    state = state.copyWith(timeHorizon: value);
  }

  void setFinancialProfile(String value) {
    state = state.copyWith(financialProfile: value);
  }

  void setInitialInvestmentAmount(double value) {
    state = state.copyWith(initialInvestmentAmount: value);
  }

  Future<void> saveToFirestore() async {
    final userValue = _ref.read(authStateProvider);
    final user = userValue.value;
    
    if (user == null) {
      throw "User must be signed in to save questionnaire data.";
    }

    final authService = _ref.read(authServiceProvider);
    try {
      await authService.updateQuestionnaireData(user.uid, {
        'investmentObjective': state.investmentObjective,
        'financialGoal': state.financialGoal,
        'riskTolerance': state.riskTolerance,
        'timeHorizon': state.timeHorizon,
        'financialProfile': state.financialProfile,
        'initialInvestmentAmount': state.initialInvestmentAmount,
        'updatedAt': FieldValue.serverTimestamp(),
        'email': user.email,
        'username': user.email?.split('@')[0], // Using email prefix as username
      });
    } catch (e) {
      debugPrint("Error in saveToFirestore: $e");
      rethrow;
    }
  }
  
  void nextStep() {
    if (state.currentStep < 5) {
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
        state.financialProfile != null &&
        state.initialInvestmentAmount != null;
  }
  
  bool canMoveToNextStep() {
    //check current step and verify required input exists
    switch (state.currentStep) {
      case 0: return state.investmentObjective != null;
      case 1: return state.financialGoal != null;
      case 2: return state.riskTolerance != null;
      case 3: return state.timeHorizon != null;
      case 4: return state.financialProfile != null;
      case 5: return state.initialInvestmentAmount != null && state.initialInvestmentAmount! > 0;
      default: return false;
    }
  }
}
//This exposes questionnaireNotifier so UI can access it
//stateNotifierProvider allows UI widgets to 
//update questionnaire using the notifier
final questionnaireProvider = StateNotifierProvider<QuestionnaireNotifier, Questionnaire>((ref) {
  return QuestionnaireNotifier(ref);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/questionnaire.dart';
import 'auth_provider.dart';
import 'questionnaire_provider.dart';

final effectiveQuestionnaireProvider = Provider<Questionnaire>((ref) {
  final userProfileAsync = ref.watch(userProfileProvider);
  final questionnaireInMemory = ref.watch(questionnaireProvider);

  return userProfileAsync.maybeWhen(
    data: (profile) {
      if (profile != null && profile.questionnaireData != null) {
        final data = profile.questionnaireData!;
        return Questionnaire(
          investmentObjective: data['investmentObjective'] as String?,
          financialGoals: (data['financialGoals'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
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
});

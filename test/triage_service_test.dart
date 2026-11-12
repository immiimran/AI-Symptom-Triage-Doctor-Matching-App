import 'package:curely/models/symptom_input.dart';
import 'package:curely/models/triage_result.dart';
import 'package:curely/services/triage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // (symptom text, expected top specialty). Add 50-100 of your own cases.
  const cases = <(String, String)>[
    ('fever and cough for two days', 'general'),
    ('বুকে ব্যথা আর ধড়ফড়', 'cardiology'),
    ('skin rash and itching', 'dermatology'),
    ('knee pain when walking', 'orthopedics'),
    ('ear pain with hearing loss', 'ent'),
    ('blurred vision', 'eye'),
    ('পেটে ব্যথা আর বমি', 'gastro'),
    ('period pain and irregular period', 'gynecology'),
    ('headache and numbness in hand', 'neurology'),
    ('sore throat and runny nose', 'ent'),
  ];

  test('top specialty accuracy on sample cases', () async {
    final service = TriageService();
    var correct = 0;

    for (final (text, expected) in cases) {
      final result = await service.analyze(SymptomInput(text: text));
      if (result.topMatch.specialtyId == expected) {
        correct++;
      } else {
        // ignore: avoid_print
        print(
          'MISS: "$text" expected $expected got ${result.topMatch.specialtyId}',
        );
      }
    }

    final accuracy = correct / cases.length;
    // ignore: avoid_print
    print('Top-1 accuracy: ${(accuracy * 100).toStringAsFixed(1)}%');
    expect(accuracy, greaterThanOrEqualTo(0.8));
  });

  test('red flags give emergency', () async {
    final service = TriageService();

    final breathing = await service.analyze(
      const SymptomInput(text: "I can't breathe"),
    );
    expect(breathing.urgency, UrgencyLevel.emergency);

    final severeChest = await service.analyze(
      const SymptomInput(text: 'chest pain', severity: SymptomSeverity.severe),
    );
    expect(severeChest.urgency, UrgencyLevel.emergency);
  });

  test('mild case is routine', () async {
    final service = TriageService();
    final result = await service.analyze(
      const SymptomInput(text: 'mild headache', severity: SymptomSeverity.mild),
    );
    expect(result.urgency, UrgencyLevel.routine);
  });
}

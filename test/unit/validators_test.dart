import 'package:campus_incident_reporter/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('email', () {
    test('rejects empty and malformed input', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email('   '), 'Email is required');
      expect(Validators.email('amina'), isNotNull);
      expect(Validators.email('amina@'), isNotNull);
      expect(Validators.email('amina@alu'), isNotNull);
    });

    test('accepts a normal address and ignores surrounding spaces', () {
      expect(Validators.email('amina@alustudent.com'), isNull);
      expect(Validators.email('  a.hassan+test@alu.edu  '), isNull);
    });
  });

  group('newPassword', () {
    test('needs eight characters with letters and digits', () {
      expect(Validators.newPassword('short1'), 'Use at least 8 characters');
      expect(Validators.newPassword('onlyletters'), isNotNull);
      expect(Validators.newPassword('12345678'), isNotNull);
      expect(Validators.newPassword('campus2026'), isNull);
    });
  });

  test('confirmPassword compares against the current original value', () {
    var original = 'campus2026';
    final validate = Validators.confirmPassword(() => original);

    expect(validate('campus2026'), isNull);
    expect(validate('campus2025'), "Passwords don't match");

    original = 'changed123';
    expect(validate('changed123'), isNull);
  });

  group('report fields', () {
    test('title length is bounded', () {
      expect(Validators.title(''), isNotNull);
      expect(Validators.title('Leak'), isNotNull);
      expect(Validators.title('Broken projector'), isNull);
      expect(Validators.title('x' * 81), isNotNull);
    });

    test('description needs real detail', () {
      expect(Validators.description('Broken'), isNotNull);
      expect(Validators.description('The tap in room 12 keeps leaking.'), isNull);
      expect(Validators.description('x' * 1001), isNotNull);
    });
  });
}

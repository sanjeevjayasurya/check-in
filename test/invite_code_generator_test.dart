import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/core/utils/invite_code_generator.dart';

void main() {
  test('generates zero-padded 6-digit invite codes', () {
    final generator = InviteCodeGenerator(random: Random(0));
    final code = generator.generate();
    expect(code.length, AppConstants.inviteCodeLength);
    expect(int.tryParse(code), isNotNull);
  });
}

import 'dart:math';

import 'package:sunsafe_checkin/core/constants/app_constants.dart';

/// Generates cryptographically-weak but user-friendly 6-digit invite codes.
class InviteCodeGenerator {
  InviteCodeGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  String generate() {
    final max = pow(10, AppConstants.inviteCodeLength).toInt();
    final code = _random.nextInt(max);
    return code.toString().padLeft(AppConstants.inviteCodeLength, '0');
  }
}

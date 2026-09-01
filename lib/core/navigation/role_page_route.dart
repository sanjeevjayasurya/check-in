import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

class RolePageRoute<T> extends MaterialPageRoute<T> {
  RolePageRoute({
    required this.role,
    required super.builder,
    super.settings,
  });

  final UserRole role;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final child = builder(context);
    return RoleThemedScope(role: role, child: child);
  }
}

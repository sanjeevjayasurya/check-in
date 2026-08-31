import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';
import 'package:sunsafe_checkin/features/auth/presentation/role_selection_screen.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

/// Root application widget with role-aware theming.
class SunSafeApp extends ConsumerWidget {
  const SunSafeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'SunSafe Check-In',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.caregiverTheme(),
      darkTheme: AppTheme.seniorTheme(),
      themeMode: ThemeMode.system,
      home: const RoleSelectionScreen(),
      builder: (context, child) {
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 1.0,
          maxScaleFactor: 2.0,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Applies the correct theme wrapper based on the active user role.
class RoleThemedScope extends StatelessWidget {
  const RoleThemedScope({
    super.key,
    required this.role,
    required this.child,
  });

  final UserRole role;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = role == UserRole.senior
        ? AppTheme.seniorTheme()
        : AppTheme.caregiverTheme();

    final themedChild = Theme(
      data: theme,
      child: child,
    );

    if (role == UserRole.senior) {
      return SeniorAccessibleScope(child: themedChild);
    }
    return themedChild;
  }
}

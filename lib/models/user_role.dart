/// The two distinct user roles in SunSafe Check-In.
enum UserRole {
  /// The elderly parent using simplified, high-accessibility UI.
  senior('senior', 'Senior Mode'),

  /// The adult child caregiver using the monitoring dashboard.
  caregiver('caregiver', 'Caregiver Mode');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.senior,
    );
  }
}

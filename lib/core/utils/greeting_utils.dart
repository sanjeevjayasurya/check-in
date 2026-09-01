class GreetingUtils {
  GreetingUtils._();

  static String timeAwareGreeting({DateTime? now}) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

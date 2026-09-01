String userFriendlyError(Object error) {
  final message = error.toString().toLowerCase();
  if (message.contains('network') || message.contains('socket')) {
    return 'No internet connection. We saved your update and will try again.';
  }
  if (message.contains('invalid') && message.contains('code')) {
    return 'That family code is not valid. Please check with your caregiver.';
  }
  if (message.contains('wrong-password') || message.contains('invalid-credential')) {
    return 'Email or password is incorrect. Please try again.';
  }
  if (message.contains('email-already-in-use')) {
    return 'An account with this email already exists. Try signing in instead.';
  }
  if (message.contains('permission')) {
    return 'Permission needed. Please allow access in your phone settings.';
  }
  return 'Something went wrong. Please try again.';
}

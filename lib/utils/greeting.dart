/// Returns the text key for the greeting that matches the time of day.
String greetingKey([DateTime? now]) {
  final hour = (now ?? DateTime.now()).hour;
  if (hour < 12) return 'greeting_morning';
  if (hour < 17) return 'greeting_afternoon';
  if (hour < 20) return 'greeting_evening';
  return 'greeting_night';
}

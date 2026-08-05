/// Shared story count formatter matching app-wide rules:
/// - count < 10: exact count (e.g. '0', '5', '9')
/// - count < 50: '+10'
/// - count < 100: '+50'
/// - count < 500: '+100'
/// - count < 1000: '+500'
/// - count < 2500: '+1000'
/// - count < 5000: '+2500'
/// - count < 10000: '+5000'
/// - >= 10000: '+10000'
String formatStoryCount(int count) {
  if (count < 10) return '$count';
  if (count < 50) return '+10';
  if (count < 100) return '+50';
  if (count < 500) return '+100';
  if (count < 1000) return '+500';
  if (count < 2500) return '+1000';
  if (count < 5000) return '+2500';
  if (count < 10000) return '+5000';
  return '+10000';
}

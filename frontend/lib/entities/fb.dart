//Named Fb because of conflicting names with flutters own Feedback class
class Fb {
  final String text;
  final String feedback;
  final List<String> opinion;
  final DateTime date;

  Fb({
    required this.text,
    required this.feedback,
    required this.opinion,
    required this.date
  });
}
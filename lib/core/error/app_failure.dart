class AppFailure{
  final String message;
  final String code;

  AppFailure({required this.message, required this.code});

  @override
  String toString() => "[$code] $message";
}
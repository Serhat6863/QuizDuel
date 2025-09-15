class RegisterUserRequestDto{
  final String email;
  final String username;
  final String password;

  RegisterUserRequestDto({
    required this.email,
    required this.password,
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
    };
  }

  factory RegisterUserRequestDto.fromJson(Map<String, dynamic> json) {
    return RegisterUserRequestDto(
      email: json['email'],
      password: json['password'],
      username: json['username'],
    );
  }
}
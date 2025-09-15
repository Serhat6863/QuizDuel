class LoginUserRequestDto{
  final String email;
  final String password;

  LoginUserRequestDto({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory LoginUserRequestDto.fromJson(Map<String, dynamic> json) {
    return LoginUserRequestDto(
      email: json['email'],
      password: json['password'],
    );
  }
}
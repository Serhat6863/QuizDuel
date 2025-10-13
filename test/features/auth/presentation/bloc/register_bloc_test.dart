import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quizduel/core/error/app_failure.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'package:quizduel/features/auth/presentation/bloc/register_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/register_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/register_state.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group("RegisterBloc", () {
    late MockUserRepository mockUserRepository;

    setUp(() {
      mockUserRepository = MockUserRepository();
    });

    const email = "test@example.com";
    const password = "123456";
    const username = "Serhat";

    final mockUser = UserEntity(
      id: "1",
      email: email,
      username: username,
      isReady: false,
      score: 0,
    );

    blocTest<RegisterBloc, RegisterState>(
      "emits [loading, success] when register succeeds",
      build: () => RegisterBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.register(email, password, username))
            .thenAnswer((_) async => mockUser);
      },
      act: (bloc) =>
          bloc.add(RegisterButtonPressed(email: email, password: password, username: username)),
      expect: () => [
        RegisterState.loading(),
        RegisterState.success(),
      ],
    );

    blocTest<RegisterBloc, RegisterState>(
      "emits [loading, failure] when register fails",
      build: () => RegisterBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.register(email, password, username))
            .thenThrow(Exception("Register failed"));
      },
      act: (bloc) =>
          bloc.add(RegisterButtonPressed(email: email, password: password, username: username)),
      expect: () => [
        RegisterState.loading(),
        RegisterState.failure("Exception: Register failed"),
      ],
    );
  });
}

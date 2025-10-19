import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quizduel/core/error/app_failure.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/login_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/login_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/login_state.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  group("🧩 LoginBloc Tests", () {
    late MockUserRepository mockUserRepository;
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockUserRepository = MockUserRepository();
      mockAuthBloc = MockAuthBloc();
    });

    const email = "test@example.com";
    const password = "123456";
    final mockUser = UserEntity(
      id: "1",
      email: email,
      username: "Serhat",
      isReady: false,
      score: 0,
      isOnline: true,
      deviceId: "device123",
    );

    blocTest<LoginBloc, LoginState>(
      "✅ emits [loading, success] when login succeeds",
      build: () => LoginBloc(
        userRepository: mockUserRepository,
        authBloc: mockAuthBloc,
      ),
      setUp: () {
        when(() => mockUserRepository.signIn(email, password))
            .thenAnswer((_) async => mockUser);
      },
      act: (bloc) => bloc.add(LoginButtonPressed(email: email, password: password)),
      expect: () => [
        LoginState.loading(),
        LoginState.success(),
      ],
      verify: (_) {
        verify(() => mockAuthBloc.add(LoggedIn())).called(1);
        verify(() => mockUserRepository.signIn(email, password)).called(1);
      },
    );

    blocTest<LoginBloc, LoginState>(
      "❌ emits [loading, failure] when AppFailure is thrown",
      build: () => LoginBloc(
        userRepository: mockUserRepository,
        authBloc: mockAuthBloc,
      ),
      setUp: () {
        when(() => mockUserRepository.signIn(email, password))
            .thenThrow(AppFailure(message: "Invalid credentials", code: "invalid-credentials"));
      },
      act: (bloc) => bloc.add(LoginButtonPressed(email: email, password: password)),
      expect: () => [
        LoginState.loading(),
        LoginState.failure("Invalid credentials"),
      ],
      verify: (_) {
        verify(() => mockUserRepository.signIn(email, password)).called(1);
      },
    );

    blocTest<LoginBloc, LoginState>(
      "❌ emits [loading, failure] with generic message when non-AppFailure is thrown",
      build: () => LoginBloc(
        userRepository: mockUserRepository,
        authBloc: mockAuthBloc,
      ),
      setUp: () {
        when(() => mockUserRepository.signIn(email, password))
            .thenThrow(Exception("Login failed"));
      },
      act: (bloc) => bloc.add(LoginButtonPressed(email: email, password: password)),
      expect: () => [
        LoginState.loading(),
        LoginState.failure("An unknown error occurred during login."),
      ],
    );
  });
}

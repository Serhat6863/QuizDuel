import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_state.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group("AuthBloc", () {
    late MockUserRepository mockUserRepository;
    late UserEntity mockUser;

    setUp(() {
      mockUserRepository = MockUserRepository();
      mockUser = UserEntity(
        id: "123",
        email: "test@example.com",
        username: "Serhat",
        isReady: false,
        score: 0,
      );
    });

    blocTest<AuthBloc, AuthState>(
      "emits [loading, authenticated] when AppStarted finds a user",
      build: () => AuthBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.getCurrentUser())
            .thenAnswer((_) async => mockUser);
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [
        AuthState.loading(),
        AuthState.authenticated(mockUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      "emits [loading, unauthenticated] when AppStarted finds no user",
      build: () => AuthBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.getCurrentUser())
            .thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [
        AuthState.loading(),
        AuthState.unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      "emits [loading, failure] when AppStarted throws an error",
      build: () => AuthBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.getCurrentUser())
            .thenThrow(Exception("Error loading user"));
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [
        AuthState.loading(),
        AuthState.failure("Exception: Error loading user"),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      "emits [loading, unauthenticated] when LoggedOut succeeds",
      build: () => AuthBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.signOut()).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(LoggedOut()),
      expect: () => [
        AuthState.loading(),
        AuthState.unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      "emits [loading, failure] when LoggedOut throws an error",
      build: () => AuthBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.signOut())
            .thenThrow(Exception("Logout failed"));
      },
      act: (bloc) => bloc.add(LoggedOut()),
      expect: () => [
        AuthState.loading(),
        AuthState.failure("Exception: Logout failed"),
      ],
    );
  });
}

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
      isOnline: true,
      deviceId: "device123",
    );
  });

  group("🧩 AuthBloc Tests", () {
    blocTest<AuthBloc, AuthState>(
      "✅ emits [loading, authenticated] when AppStarted finds a user",
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
      verify: (_) {
        verify(() => mockUserRepository.getCurrentUser()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      "✅ emits [loading, unauthenticated] when AppStarted finds no user",
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
      "❌ emits [loading, failure] when AppStarted throws an exception",
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
      "✅ emits [loading, authenticated] when LoggedIn retrieves a user",
      build: () => AuthBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.getCurrentUser())
            .thenAnswer((_) async => mockUser);
      },
      act: (bloc) => bloc.add(LoggedIn()),
      expect: () => [
        AuthState.loading(),
        AuthState.authenticated(mockUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      "✅ emits [loading, unauthenticated] when LoggedIn finds no user",
      build: () => AuthBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.getCurrentUser())
            .thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(LoggedIn()),
      expect: () => [
        AuthState.loading(),
        AuthState.unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      "✅ emits [loading, unauthenticated] when LoggedOut succeeds",
      build: () => AuthBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.signOut()).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(LoggedOut()),
      expect: () => [
        AuthState.loading(),
        AuthState.unauthenticated(),
      ],
      verify: (_) {
        verify(() => mockUserRepository.signOut()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      "❌ emits [loading, failure] when LoggedOut throws an error",
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

    blocTest<AuthBloc, AuthState>(
      "✅ emits [loading, deleted] when DeleteAccountEvent succeeds",
      build: () => AuthBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.deleteAccount()).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(DeleteAccountEvent()),
      expect: () => [
        AuthState.loading(),
        AuthState.deleted(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      "❌ emits [loading, failure] when DeleteAccountEvent throws an error",
      build: () => AuthBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.deleteAccount())
            .thenThrow(Exception("Deletion failed"));
      },
      act: (bloc) => bloc.add(DeleteAccountEvent()),
      expect: () => [
        AuthState.loading(),
        AuthState.failure("Exception: Deletion failed"),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      "✅ emits [loading, passwordResetEmailSent] when SendPasswordResetEmailEvent succeeds",
      build: () => AuthBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.resetPassword(any())).thenAnswer((_) async {});
      },
      act: (bloc) =>
          bloc.add(SendPasswordResetEmailEvent("test@example.com")),
      expect: () => [
        AuthState.loading(),
        AuthState.passwordResetEmailSent(),
      ],
      verify: (_) {
        verify(() => mockUserRepository.resetPassword("test@example.com"))
            .called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      "❌ emits [loading, failure] when SendPasswordResetEmailEvent throws an error",
      build: () => AuthBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.resetPassword(any()))
            .thenThrow(Exception("Reset failed"));
      },
      act: (bloc) =>
          bloc.add(SendPasswordResetEmailEvent("test@example.com")),
      expect: () => [
        AuthState.loading(),
        AuthState.failure("Exception: Reset failed"),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      "✅ updates user when RefreshUserEvent succeeds",
      build: () => AuthBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.getCurrentUser())
            .thenAnswer((_) async => mockUser);
      },
      act: (bloc) => bloc.add(RefreshUserEvent()),
      expect: () => [
        AuthState.initial().copyWith(user: mockUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      "❌ does nothing when RefreshUserEvent throws an error",
      build: () => AuthBloc(userRepository: mockUserRepository),
      setUp: () {
        when(() => mockUserRepository.getCurrentUser())
            .thenThrow(Exception("Error refreshing user"));
      },
      act: (bloc) => bloc.add(RefreshUserEvent()),
      expect: () => [],
    );
  });
}

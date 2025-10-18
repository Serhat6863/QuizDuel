import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'package:quizduel/features/room/presentation/bloc/leader_bloc.dart';
import 'package:quizduel/features/room/presentation/bloc/leader_event.dart';
import 'package:quizduel/features/room/presentation/bloc/leader_state.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late LeaderBloc leaderBloc;
  late MockUserRepository mockUserRepo;

  final mockUsers = [
    UserEntity(
      id: 'u1',
      email: 'a',
      username: 'Serhat',
      isReady: false,
      score: 50,
      isOnline: true,
      deviceId: '',
    ),
    UserEntity(
      id: 'u2',
      email: 'b',
      username: 'Alex',
      isReady: false,
      score: 100,
      isOnline: false,
      deviceId: '',
    ),
  ];

  setUp(() {
    mockUserRepo = MockUserRepository();
    leaderBloc = LeaderBloc(userRepository: mockUserRepo);
  });

  tearDown(() => leaderBloc.close());

  group('🧩 LeaderBloc Tests', () {
    test('✅ initial state est LeaderState.initial()', () {
      expect(leaderBloc.state.status.isInitial, true);
      expect(leaderBloc.state.leaders, isEmpty);
    });

    blocTest<LeaderBloc, LeaderState>(
      '✅ emits [loading, success] avec les utilisateurs triés par score décroissant',
      build: () {
        when(() => mockUserRepo.getAllUsers()).thenAnswer((_) async => mockUsers);
        return leaderBloc;
      },
      act: (bloc) => bloc.add(FetchLeaderBoardEvent()),
      expect: () => [
        LeaderState.loading(),
        predicate<LeaderState>((state) {
          // Vérifie que l’état est "success" et que les scores sont triés correctement
          final scores = state.leaders.map((u) => u.score ?? 0).toList();
          return state.status == LeaderStatus.success &&
              scores.length == 2 &&
              scores[0] >= scores[1];
        }),
      ],
      verify: (_) => verify(() => mockUserRepo.getAllUsers()).called(1),
    );

    blocTest<LeaderBloc, LeaderState>(
      '❌ emits [loading, failure] quand une exception est levée',
      build: () {
        when(() => mockUserRepo.getAllUsers()).thenThrow(Exception("DB error"));
        return leaderBloc;
      },
      act: (bloc) => bloc.add(FetchLeaderBoardEvent()),
      expect: () => [
        LeaderState.loading(),
        predicate<LeaderState>(
              (state) =>
          state.status == LeaderStatus.failure &&
              (state.errorMessage ?? "").contains("Erreur lors du chargement du classement"),
        ),
      ],
    );
  });
}

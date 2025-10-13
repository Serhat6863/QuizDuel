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
    UserEntity(id: 'u1', email: 'a', username: 'Serhat', isReady: false, score: 50),
    UserEntity(id: 'u2', email: 'b', username: 'Alex', isReady: false, score: 100),
  ];

  setUp(() {
    mockUserRepo = MockUserRepository();
    leaderBloc = LeaderBloc(userRepository: mockUserRepo);
  });

  tearDown(() => leaderBloc.close());

  group('LeaderBloc', () {
    test('initial state est LeaderState.initial()', () {
      expect(leaderBloc.state.status.isInitial, true);
    });

    blocTest<LeaderBloc, LeaderState>(
      'emits [loading, success] quand le fetch réussit',
      build: () {
        when(() => mockUserRepo.getAllUsers()).thenAnswer((_) async => mockUsers);
        return leaderBloc;
      },
      act: (bloc) => bloc.add(FetchLeaderBoardEvent()),
      expect: () => [
        isA<LeaderState>().having((s) => s.status, 'loading', LeaderStatus.loading),
        isA<LeaderState>().having((s) => s.status, 'success', LeaderStatus.success),
      ],
      verify: (_) => verify(() => mockUserRepo.getAllUsers()).called(1),
    );

    blocTest<LeaderBloc, LeaderState>(
      'emits [loading, failure] quand une erreur survient',
      build: () {
        when(() => mockUserRepo.getAllUsers()).thenThrow(Exception("DB error"));
        return leaderBloc;
      },
      act: (bloc) => bloc.add(FetchLeaderBoardEvent()),
      expect: () => [
        isA<LeaderState>().having((s) => s.status, 'loading', LeaderStatus.loading),
        isA<LeaderState>().having((s) => s.status, 'failure', LeaderStatus.failure),
      ],
    );
  });
}

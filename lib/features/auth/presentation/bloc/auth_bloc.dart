import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/core/utils/logger.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({required this.userRepository}) : super(AuthState.initial()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);

    on<RefreshUserEvent>((event, emit) async {
      try {
        final user = await userRepository.getCurrentUser();
        if (user != null) {
          emit(state.copyWith(user: user)); // ✅ pas de nouveau AuthState.authenticated
          logger.i("🔄 Utilisateur rafraîchi avec succès: ${user.username}");
        }
      } catch (e) {
        logger.e("❌ Erreur lors du rafraîchissement utilisateur: $e");
      }
    });

  }

  /// 🔥 Quand l’app démarre, on check Firestore pour voir si un user existe
  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthState.loading());
    try {
      final user = await userRepository.getCurrentUser();
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  /// 🔥 Quand un user vient de se connecter (login/register)
  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthState.loading());
    try {
      final user = await userRepository.getCurrentUser();
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  /// 🔥 Déconnexion
  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthState.loading());
    try {
      await userRepository.signOut();
      emit(AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  
}

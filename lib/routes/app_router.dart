// 📄 lib/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:quizduel/features/auth/presentation/screen/login_screen.dart';
import 'package:quizduel/features/auth/presentation/screen/register_screen.dart';
import 'package:quizduel/features/auth/presentation/screen/verification_email_screen.dart';
import 'package:quizduel/features/game/presentation/screen/game_screen.dart';
import 'package:quizduel/features/game/presentation/screen/winner_screen.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
import 'package:quizduel/features/room/presentation/screen/leaderboard_screen.dart';
import 'package:quizduel/features/room/presentation/screen/room_list_screen.dart';
import 'package:quizduel/features/room/presentation/screen/room_home_screen.dart';
import 'package:quizduel/routes/route_names.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
    // 🔐 AUTH ROUTES --------------------------------------------------------
      case RouteNames.login:
        return _buildRoute(const LoginScreen(), settings);
      case RouteNames.register:
        return _buildRoute(const RegisterScreen(), settings);
      case RouteNames.verificationEmail:
        return _buildRoute(const VerificationEmailScreen(), settings);

    // 🏠 HOME ---------------------------------------------------------------
      case RouteNames.home:
        return _buildRoute(const HomeScreen(), settings);

    // 🧩 ROOMS --------------------------------------------------------------
      case RouteNames.roomList:
        return _buildRoute(const RoomListScreen(), settings);

    // 🧠 GAME ---------------------------------------------------------------
      case RouteNames.game:
        final room = settings.arguments as RoomEntity;
        return _buildRoute(GameScreen(roomEntity: room), settings);

    // 🏆 LEADERBOARD / WINNER ----------------------------------------------
      case RouteNames.leaderboard:
        return _buildRoute(const LeaderboardScreen(), settings);
      case RouteNames.winner:
        final room = settings.arguments as RoomEntity;
        return _buildRoute(WinnerScreen(roomEntity: room), settings);

    // ❌ DEFAULT ------------------------------------------------------------
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                '⚠️ Route not found: ${settings.name}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
    }
  }

  /// Helper pour factoriser le MaterialPageRoute
  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}

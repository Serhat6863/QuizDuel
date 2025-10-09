import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:quizduel/features/auth/data/repository/user_repository_impl.dart';
import 'package:quizduel/features/auth/data/service/firebase_user_service.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/login_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/register_bloc.dart';
import 'package:quizduel/features/auth/presentation/screen/login_screen.dart';
import 'package:quizduel/features/game/data/repository/quiz_repository_impl.dart';
import 'package:quizduel/features/game/data/service/quiz_api.dart';
import 'package:quizduel/features/game/domain/repository/quiz_repository.dart';
import 'package:quizduel/features/game/presentation/bloc/quiz_bloc.dart';
import 'package:quizduel/features/room/data/repository/room_repository_impl.dart';
import 'package:quizduel/features/room/domain/repository/room_repository.dart';
import 'package:quizduel/features/room/presentation/bloc/leader_bloc.dart';
import 'package:quizduel/features/room/presentation/bloc/room_bloc.dart';
import 'package:quizduel/features/room/presentation/screen/room_home_screen.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/room/data/service/firebase_room_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  final db = FirebaseDatabase.instance.ref();
  final dio = Dio();

  final firebaseUserService = FirebaseUserService();
  final firebaseRoomService = FirebaseRoomService();
  final quizApi = QuizApi(dio);

  final userRepository = UserRepositoryImpl(
    firebaseUserService: firebaseUserService,
  );

  final roomRepository = RoomRepositoryImpl(
    firebaseRoomService: firebaseRoomService,
  );

  final quizRepository = QuizRepositoryImpl(
    quizApi: quizApi,
  );

  runApp(MyApp(userRepository: userRepository, roomRepository: roomRepository, quizRepository: quizRepository,));
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  final RoomRepository roomRepository;
  final QuizRepository quizRepository;

  const MyApp({
    super.key,
    required this.userRepository,
    required this.roomRepository,
    required this.quizRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        Provider<UserRepository>.value(value: userRepository),
        Provider<RoomRepository>.value(value: roomRepository),
        Provider<QuizRepository>.value(value: quizRepository,),


        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(userRepository: context.read<UserRepository>())..add(AppStarted()),
        ),
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(userRepository: context.read<UserRepository>(), authBloc: context.read<AuthBloc>()),
        ),
        BlocProvider<RegisterBloc>(
          create: (context) => RegisterBloc(userRepository: context.read<UserRepository>()),
        ),
        BlocProvider<RoomBloc>(
          create: (context) => RoomBloc(roomRepository: context.read<RoomRepository>() , userRepository: context.read<UserRepository>()),
        ),
        BlocProvider<QuizBloc>(
          create: (context) => QuizBloc(quizRepository: context.read<QuizRepository>()),
        ),
        BlocProvider<LeaderBloc>(
          create: (context) => LeaderBloc(userRepository: context.read<UserRepository>()),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.status.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (state.status.isAuthenticated) {
              return const HomeScreen();
            } else if (state.status.isUnauthenticated) {
              return const LoginScreen();
            }

            return const Scaffold(
              body: Center(child: Text('Something went wrong!')),
            );
          },
        ),
      ),
    );
  }
}
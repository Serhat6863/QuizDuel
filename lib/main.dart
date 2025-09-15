import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/features/auth/data/repository/user_repository_impl.dart';
import 'package:quizduel/features/auth/data/service/firebase_user_service.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/login_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/register_bloc.dart';
import 'package:quizduel/features/auth/presentation/screen/login_screen.dart';
import 'package:quizduel/features/room/presentation/screen/room_home_screen.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firebaseUserService = FirebaseUserService();

  final userRepository = UserRepositoryImpl(
    firebaseUserService: firebaseUserService,
  );

  runApp(MyApp(userRepository: userRepository));
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;

  const MyApp({super.key, required this.userRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (_) => LoginBloc(userRepository : userRepository),
        ),
        BlocProvider<RegisterBloc>(
          create: (_) => RegisterBloc(userRepository: userRepository),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(userRepository: userRepository)..add(AppStarted()),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state){
            if(state.status.isLoading){
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }else if(state.status.isAuthenticated){
              return const RoomHomeScreen();
            }else if(state.status.isUnauthenticated) {
              return const LoginScreen();
            }

            return const Scaffold(
              body: Center(child: Text('Something went wrong!')),
            );
          },
        )
      ),
    );
  }
}

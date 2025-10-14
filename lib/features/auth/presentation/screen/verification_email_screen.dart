import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_state.dart';
import 'package:quizduel/features/auth/presentation/bloc/register_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/register_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/register_state.dart';
import 'package:quizduel/features/auth/presentation/screen/login_screen.dart';
import 'package:quizduel/features/auth/presentation/screen/register_screen.dart';

class VerificationEmailScreen extends StatefulWidget {
  const VerificationEmailScreen({super.key});

  @override
  State<VerificationEmailScreen> createState() =>
      _VerificationEmailScreenState();
}

class _VerificationEmailScreenState extends State<VerificationEmailScreen> {
  bool _isSending = false;
  int _remainingSeconds = 30;
  Timer? _timer;

  /// 🔹 Démarre le timer (30s)
  void _startTimer() {
    setState(() {
      _isSending = true;
      _remainingSeconds = 30;
    });

    _timer?.cancel(); // évite les doublons

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        setState(() {
          timer.cancel();
          _isSending = false;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  /// 🔹 Nettoyage du timer quand on quitte l’écran
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 🔹 RegisterBloc → gère la logique d'email
        BlocListener<RegisterBloc, RegisterState>(
          listener: (context, state) {
            if (state.status.isResentEmail) {
              _showSnack(
                context,
                title: '✅ Success!',
                message: 'Verification email has been resent.',
                type: ContentType.success,
              );
            } else if (state.status.isSuccess) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            } else if (state.status.isNotVerified) {
              _showSnack(
                context,
                title: '⚠️ Not Verified!',
                message:
                'Your email is still not verified. Please check your inbox.',
                type: ContentType.warning,
              );
            } else if (state.status.isFailure) {
              _showSnack(
                context,
                title: '❌ Error!',
                message: state.failure ?? 'An unknown error occurred.',
                type: ContentType.failure,
              );
            }
          },
        ),

        // 🔹 AuthBloc → gère la suppression de compte
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status.isDeleted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    (route) => false,
              );
            } else if (state.status.isFailure) {
              _showSnack(
                context,
                title: '❌ Error!',
                message: state.failure ?? 'Could not delete the account.',
                type: ContentType.failure,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF5E6C4),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.email_rounded,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Verify your email 📩',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'A verification email has been sent to your inbox.\nPlease check your email and click on the verification link to activate your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ✅ Check verification button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<RegisterBloc>().add(CheckEmailVerified());
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Colors.deepPurple, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.deepPurple),
                      label: const Text(
                        "I’ve verified my email",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),


                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSending
                          ? null
                          : () {
                        context
                            .read<RegisterBloc>()
                            .add(ResentEmailVerification());
                        _startTimer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: Text(
                        _isSending
                            ? "Wait ($_remainingSeconds s)"
                            : "Resend Verification Email",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(height: 30),

                  // 🔙 Cancel
                  TextButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(DeleteAccountEvent());
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      "Cancel & delete account",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  void _showSnack(
      BuildContext context, {
        required String title,
        required String message,
        required ContentType type,
      }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

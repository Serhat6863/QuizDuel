import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/core/theme/app_colors.dart';
import 'package:quizduel/core/theme/app_text_styles.dart';
import 'package:quizduel/core/theme/app_button_styles.dart';
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

  void _startTimer() {
    setState(() {
      _isSending = true;
      _remainingSeconds = 30;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        setState(() {
          timer.cancel();
          _isSending = false;
        });
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RegisterBloc, RegisterState>(
          listener: (context, state) {
            if (state.status.isResentEmail) {
              _showSnack(
                context,
                title: 'Success!',
                message: 'Verification email has been resent.',
                type: ContentType.success,
              );
            } else if (state.status.isSuccess) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            } else if (state.status.isNotVerified) {
              _showSnack(
                context,
                title: 'Not Verified!',
                message:
                'Your email is still not verified. Please check your inbox.',
                type: ContentType.warning,
              );
            } else if (state.status.isFailure) {
              _showSnack(
                context,
                title: 'Error!',
                message: state.failure ?? 'An unknown error occurred.',
                type: ContentType.failure,
              );
            }
          },
        ),
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
                title: 'Error!',
                message: state.failure ?? 'Could not delete the account.',
                type: ContentType.failure,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 📩 Icône principale
                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Icon(
                      Icons.email_rounded,
                      color: AppColors.white,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text("Verify your email 📩",
                      style: AppTextStyles.pageTitle,
                      textAlign: TextAlign.center),

                  const SizedBox(height: 15),

                  Text(
                    "A verification email has been sent to your inbox.\nPlease click on the link to activate your account.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 40),

                  // ✅ Bouton "I've verified my email"
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<RegisterBloc>().add(CheckEmailVerified());
                      },
                      style: AppButtonStyles.outline,
                      icon: const Icon(Icons.check_circle_outline,
                          color: AppColors.primary),
                      label: const Text(
                        "I’ve verified my email",
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔁 Bouton "Resend"
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
                      style: AppButtonStyles.primary,
                      icon: const Icon(Icons.refresh, color: AppColors.white),
                      label: Text(
                        _isSending
                            ? "Wait ($_remainingSeconds s)"
                            : "Resend Verification Email",
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ❌ Cancel & delete account
                  TextButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(DeleteAccountEvent());
                    },
                    icon: Icon(Icons.logout, color: AppColors.red),
                    label: Text(
                      "Cancel & delete account",
                      style: AppTextStyles.error,
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
}

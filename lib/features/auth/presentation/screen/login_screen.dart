import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/core/theme/app_colors.dart';
import 'package:quizduel/core/theme/app_text_styles.dart';
import 'package:quizduel/core/theme/app_button_styles.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/login_event.dart';
import 'package:quizduel/features/auth/presentation/screen/register_screen.dart';
import 'package:quizduel/features/auth/presentation/widget/custom_text_field.dart';
import 'package:quizduel/features/room/presentation/screen/room_home_screen.dart';
import '../../../../routes/route_names.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_state.dart';
import 'forget_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  void _navigateWithAnimation(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => page,
        transitionsBuilder: (_, animation, __, child) {
          final offset = Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) async {
        if (state.status.isSuccess) {
          context.read<AuthBloc>().add(LoggedIn());
          await Future.delayed(const Duration(milliseconds: 400));
          Navigator.pushReplacementNamed(context, RouteNames.home);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 🔹 Logo
                        Image.asset(
                          "assets/icon/icon.png",
                          height: 100,
                          width: 100,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.quiz,
                              size: 100,
                              color: AppColors.primary,
                            );
                          },
                        ),

                        const SizedBox(height: 10),
                        const Text("Welcome Back!", style: AppTextStyles.pageTitle),
                        const SizedBox(height: 30),

                        // ✨ Login form card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowStrong,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (state.status.isFailure)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.red.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.error, color: AppColors.white),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Invalid email or password",
                                            style: AppTextStyles.buttonSmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 20),

                                const Text("Email", style: AppTextStyles.inputLabel),
                                const SizedBox(height: 6),
                                CustomTextField(
                                  controller: _emailController,
                                  hintText: "Enter your email",
                                  keyboardType: TextInputType.emailAddress,
                                  iconData: CupertinoIcons.mail,
                                  obsureText: false,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter your email";
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return "Invalid email";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                const Text("Password", style: AppTextStyles.inputLabel),
                                const SizedBox(height: 6),
                                CustomTextField(
                                  controller: _passwordController,
                                  hintText: "Enter your password",
                                  keyboardType: TextInputType.visiblePassword,
                                  iconData: CupertinoIcons.lock,
                                  onTap: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                  obsureText: _obscureText,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter your password";
                                    }
                                    if (value.length < 6) {
                                      return "At least 6 characters";
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 10),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      //forgot password screen
                                      Navigator.pushNamed(context, RouteNames.passwordReset);
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style: AppTextStyles.link,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // 🚀 Login button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: state.status.isLoading
                                        ? null
                                        : () {
                                      if (formKey.currentState!.validate()) {
                                        context.read<LoginBloc>().add(
                                          LoginButtonPressed(
                                            email: _emailController.text,
                                            password:
                                            _passwordController.text,
                                          ),
                                        );
                                      }
                                    },
                                    style: AppButtonStyles.primary,
                                    child: state.status.isLoading
                                        ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: AppColors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                        : const Text("Login"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // 🔗 Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: AppTextStyles.subtitle,
                            ),
                            GestureDetector(
                              onTap: () {
                                _navigateWithAnimation(
                                  context,
                                  const RegisterScreen(),
                                );
                              },
                              child: Text(
                                "Register",
                                style: AppTextStyles.link,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

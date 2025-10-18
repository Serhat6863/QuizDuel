import 'dart:ui';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/core/theme/app_colors.dart';
import 'package:quizduel/core/theme/app_text_styles.dart';
import 'package:quizduel/core/theme/app_button_styles.dart';
import 'package:quizduel/features/auth/presentation/bloc/register_event.dart';
import 'package:quizduel/features/auth/presentation/screen/login_screen.dart';
import 'package:quizduel/features/auth/presentation/screen/verification_email_screen.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_state.dart';
import '../widget/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  final formKey = GlobalKey<FormState>();

  void _navigateWithAnimation(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => page,
        transitionsBuilder: (_, animation, __, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          _showSnack(
            context,
            title: "Success",
            message: "Account created! Please verify your email.",
            type: ContentType.success,
          );
          _navigateWithAnimation(context, const VerificationEmailScreen());
        }else if(state.status.isFailure){
          _showSnack(
            context,
            title: "Error",
            message: state.failure ?? "An error occurred during register",
            type: ContentType.failure,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🔹 Logo
                  Image.asset(
                    'assets/icon/icon.png',
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.quiz,
                        size: 100,
                        color: AppColors.primary,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text("Create Account", style: AppTextStyles.pageTitle),
                  const SizedBox(height: 30),

                  // ✨ Form card
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
                                      "This email already exists",
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

                          const Text("Username", style: AppTextStyles.inputLabel),
                          const SizedBox(height: 6),
                          CustomTextField(
                            controller: _usernameController,
                            hintText: "Enter your username",
                            keyboardType: TextInputType.text,
                            iconData: CupertinoIcons.person,
                            obsureText: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your username";
                              }
                              if (value.length < 3) {
                                return "At least 3 characters";
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
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            obsureText: _obscurePassword,
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
                          const SizedBox(height: 20),

                          const Text("Confirm Password",
                              style: AppTextStyles.inputLabel),
                          const SizedBox(height: 6),
                          CustomTextField(
                            controller: _confirmationController,
                            hintText: "Confirm your password",
                            keyboardType: TextInputType.visiblePassword,
                            iconData: CupertinoIcons.lock,
                            onTap: () {
                              setState(() {
                                _obscureConfirmation = !_obscureConfirmation;
                              });
                            },
                            obsureText: _obscureConfirmation,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please confirm your password";
                              }
                              if (value != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),

                          // 🚀 Register button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.status.isLoading
                                  ? null
                                  : () {
                                if (formKey.currentState!.validate()) {
                                  context.read<RegisterBloc>().add(
                                    RegisterButtonPressed(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      username: _usernameController.text,
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
                                  : const Text("Register"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🔗 Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: AppTextStyles.subtitle,
                      ),
                      GestureDetector(
                        onTap: () {
                          _navigateWithAnimation(
                            context,
                            const LoginScreen(),
                          );
                        },
                        child: Text(
                          "Login",
                          style: AppTextStyles.link,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

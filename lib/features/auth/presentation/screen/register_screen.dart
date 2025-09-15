import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/register_event.dart';
import 'package:quizduel/features/auth/presentation/screen/login_screen.dart';

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
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Column(
                    children: [
                      //image quiz
                      const SizedBox(height: 30),

                      Image.asset(
                        "assets/images/quiz.png",
                        height: 300,
                        width: 300,
                      ),

                      const SizedBox(height: 20),

                      //form field email
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              if (state.status.isFailure)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade300,
                                    borderRadius: BorderRadius.circular(8),
                                  ),

                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Erreur lors de l'inscription,",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (state.status.isFailure)
                                const SizedBox(height: 15),

                              //form field email
                              CustomTextField(
                                controller: _emailController,
                                hintText: "Email",
                                iconData: Icons.email,
                                obsureText: false,

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your email";
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}',
                                  ).hasMatch(value)) {
                                    return "Please enter a valid email";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              CustomTextField(
                                controller: _usernameController,
                                hintText: "Username",
                                iconData: Icons.person,
                                obsureText: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your username";
                                  }
                                  if (value.length < 3) {
                                    return "Username must be at least 3 characters";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              //form field password
                              CustomTextField(
                                controller: _passwordController,
                                hintText: "Password",
                                iconData: Icons.lock,
                                obsureText: false,

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your password";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 35),

                              //button login
                              ElevatedButton(
                                onPressed: state.status.isLoading
                                    ? null
                                    : () {
                                        final form = formKey.currentState;
                                        if (form != null && form.validate()) {
                                          // continue with registration
                                          context.read<RegisterBloc>().add(
                                            RegisterButtonPressed(
                                              email: _emailController.text,
                                              password:
                                                  _passwordController.text,
                                              username:
                                                  _usernameController.text,
                                            ),
                                          );
                                        }
                                      },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade800,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 115,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),

                                child: state.status.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                    : Text(
                                        "Register",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      //text don't have account? register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(fontSize: 16),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

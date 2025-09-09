import 'package:flutter/material.dart';
import 'package:quizduel/features/auth/presentation/widget/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

                          //form field password
                          CustomTextField(
                            controller: _passwordController,
                            hintText: "Password",
                            iconData: Icons.lock,
                            obsureText: true,

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password";
                              }
                              if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 35),

                          //button login
                          ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {}
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

                            child: Text(
                              "Login",
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
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          "Register",
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
  }
}

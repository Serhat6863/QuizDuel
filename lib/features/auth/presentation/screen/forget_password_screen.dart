import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_state.dart';
import 'package:quizduel/features/auth/presentation/widget/custom_text_field.dart';

import '../bloc/auth_event.dart';
import 'login_screen.dart';
class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {

  final TextEditingController _emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  int _remainingSeconds = 30;
  bool _isSending = false;
  Timer? _timer;


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
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
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
    // TODO: implement dispose
    _emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state){
        if(state.status.isFailure){
          _showSnack(
            context,
            title: "Erreur",
            message: state.failure ?? "Une erreur est survenue",
            type: ContentType.failure,
          );
        } else if(state.status.isPasswordResetEmailSent){
          _showSnack(
            context,
            title: "Succès",
            message: "Email de réinitialisation envoyé ! Vérifiez votre boîte de réception.",
            type: ContentType.success,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5E6C4),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: (){
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  CupertinoIcons.back,
                                  color: Colors.deepPurple,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),



                  const SizedBox(height: 50),
                  const Icon(
                   CupertinoIcons.lock_open,
                    color: Colors.black87,
                    size: 100,
                  ),

                  const SizedBox(height: 20),


                  const Text(
                    'Password Reset 🔒',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height: 20),


                  Text(
                    "Please enter your email address to receive a password reset link.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            iconData: Icons.email,
                            obsureText: false,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),


                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSending
                              ? null
                              : (){
                                if(formKey.currentState!.validate()){
                                  context.read<AuthBloc>().add(
                                    SendPasswordResetEmailEvent(
                                      _emailController.text.trim(),
                                    ),
                                  );
                                  _startTimer();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.deepPurple.shade500,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              child: Text(
                                _isSending ?
                                "Please wait ($_remainingSeconds s)"
                                    : "Send Reset Link",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        ],
                      )
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

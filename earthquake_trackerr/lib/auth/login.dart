import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  static String route = 'login-page';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  bool _emailTouched = false;
  bool _passwordTouched = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {
        _emailTouched = true;
        _validateEmail();
      });
    });
    _passwordController.addListener(() {
      setState(() {
        _passwordTouched = true;
        _validatePassword();
      });
    });

    GetStorage.init();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
    if (_emailTouched) {
      if (email.isEmpty) {
        setState(() {
          _emailError = 'Please enter your email';
        });
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        setState(() {
          _emailError = 'Please enter a valid email address';
        });
      } else {
        setState(() {
          _emailError = null;
        });
      }
    }
  }

  void _validatePassword() {
    final password = _passwordController.text;
    if (_passwordTouched) {
      if (password.isEmpty) {
        setState(() {
          _passwordError = 'Please enter your password';
        });
      } else if (password.length < 6) {
        setState(() {
          _passwordError = 'Password must be at least 6 characters long';
        });
      } else {
        setState(() {
          _passwordError = null;
        });
      }
    }
  }

  bool get _isFormValid {
    return _emailError == null &&
        _passwordError == null &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

Future<void> _signIn() async {
    if (_isFormValid) {
      setState(() {
        _isLoading = true; 
      });
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Store email in GetStorage
        final box = GetStorage();
        box.write('user_email', _emailController.text.trim());
       Get.snackbar(
          'Login Successful',
          'You have logged in successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
        );

        Get.toNamed('mainscreen-page');
      } on FirebaseAuthException catch (e) {
        String errorMessage =
            'The email or password is invalid or check your internet connection';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for this email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password.';
        }
        Get.snackbar('Login Error', errorMessage,
            snackPosition: SnackPosition.BOTTOM,
             margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
        );
      } finally {
        setState(() {
          _isLoading = false; 
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Text(
                                        'Welcome to ',
                                        style: GoogleFonts.poppins(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.blue,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Earthquake\nTracker',
                                        style: GoogleFonts.poppins(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Hello there, Login to continue',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      height: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Stack(
                                    children: [
                                      TextFormField(
                                        controller: _emailController,
                                        decoration: InputDecoration(
                                          labelText: null,
                                          hintStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 25, horizontal: 10),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: Color.fromARGB(
                                                  255, 227, 227, 227),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: Colors.blue,
                                              width: 2.0,
                                            ),
                                          ),
                                          errorText: _emailError,
                                        ),
                                        onChanged: (value) {
                                          _validateEmail();
                                        },
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      Positioned(
                                        left: 10,
                                        top: 8,
                                        child: Text(
                                          'Email Address',
                                          style: TextStyle(
                                            color: _emailController.text.isEmpty
                                                ? Colors.black
                                                : Colors.blue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Stack(
                                    children: [
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        decoration: InputDecoration(
                                          labelText: null,
                                          errorText: _passwordError,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 25, horizontal: 10),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: Colors.blue,
                                              width: 2.0,
                                            ),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                          ),
                                        ),
                                        onChanged: (value) {
                                          _validatePassword();
                                        },
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      Positioned(
                                        left: 10,
                                        top: 8,
                                        child: Text(
                                          'Password',
                                          style: TextStyle(
                                            color:
                                                _passwordController.text.isEmpty
                                                    ? Colors.black
                                                    : Colors.blue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  GestureDetector(
                                    onTap:   _isFormValid && !_isLoading ? _signIn : null,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: _isFormValid && !_isLoading
                                            ? Colors.blue
                                            : Colors.grey,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(18.0),
                                          child: _isLoading
                                              ? CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                )
                                              : Text(
                                                  'Login',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Create one',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Get.toNamed('signup-page');
                                      }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

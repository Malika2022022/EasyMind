import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testdrive/  textfield.dart';
import 'package:testdrive/createacc_page.dart';
import 'package:testdrive/forgotpassword.dart';
import 'package:testdrive/section_page.dart';
import 'package:testdrive/my_button.dart';
import 'package:flutter/gestures.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formkey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
              child: Text(
                "Login successful!",
                style: TextStyle(fontFamily: 'Inter', fontSize: 16),
              ),
            ),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SectionPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-credential':
          message = 'Invalid email or password. Please try again.';
          break;
        case 'wrong-password':
          message = 'Wrong password. Please try again.';
          break;
        case 'user-not-found':
          message = 'No account found with this email. Please create an account.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;
        default:
          message = 'Login failed: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Center(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
              ),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Center(
              child: Text(
                'Error: ${e.toString()}',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> googleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
              child: Text(
                "Google Sign-In successful!",
                style: TextStyle(fontFamily: 'Inter', fontSize: 16),
              ),
            ),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SectionPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Google Sign-In failed: ${e.toString()}',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFFFFF0),
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                const SizedBox(height: 130),
                const Text(
                  'EasyMind',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 30,
                  ),
                ),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: 'Create an account',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateaccPage(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                MyTextField(
                  controller: emailController,
                  hintText: "email@domain.com",
                  obscureText: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                  suffix: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPassword(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12,
                      ),
                      child: Text(
                        'Forgot?',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: Color(0xFF828282),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF373737),
                          ),
                        ),
                      )
                    : MyButton(
                        buttontext: 'Continue',
                        buttonColor: const Color(0xFF373737),
                        textColor: const Color(0xFFEEE8AA),
                        onPressed: login,
                      ),
                const SizedBox(height: 16),
                MyButton(
                  icon: Image.asset('lib/images/Logo.png'),
                  buttontext: 'Continue with Google',
                  buttonColor: const Color(0xFFEEE8AA),
                  textColor: const Color(0xFF373737),
                  onPressed: _isLoading ? () {} : googleSignIn,
                ),
                const SizedBox(height: 16),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
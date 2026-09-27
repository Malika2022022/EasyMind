import 'package:flutter/material.dart';
import 'package:testdrive/%C2%A0%C2%A0textfield.dart';
import 'package:testdrive/login_page.dart';
import 'package:testdrive/section_page.dart';
import 'package:testdrive/my_button.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateaccPage extends StatefulWidget {
  const CreateaccPage({super.key});

  @override
  State<CreateaccPage> createState() => _CreateaccPageState();
}

class _CreateaccPageState extends State<CreateaccPage> {
  final usernameController=TextEditingController();
  final passwordController=TextEditingController();
  final infoController=TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;


 Future<void> registration() async {
    if (!_formkey.currentState!.validate()) {
      return;
    }
    setState(() {
     _isLoading = true;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: infoController.text.trim(), 
            password: passwordController.text.trim()
          );  
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully!",
          textAlign: TextAlign.center),
          duration: Duration(seconds: 2),
        )
      );
      
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const SectionPage())
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'Password should be at least 6 characters.';
      } else if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else {
        message = e.message ?? 'Registration failed';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(message,
          textAlign: TextAlign.center),
        )
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
    
  @override 
  Widget build(BuildContext context){
    return Scaffold(
     backgroundColor:Color(0xFFFFFFF0),
      body:SafeArea(
          child: SingleChildScrollView(
            child:Form(
              key:_formkey,
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height:130),
                  const Text('EasyMind',
                  style: TextStyle(
                    fontFamily:'Inter',
                    fontWeight:FontWeight.w600,
                    fontSize:30,
                    
                  ),
                 ),
                 Text("Create an account",
                 style:TextStyle(
                  fontFamily: 'Inter',
                  fontWeight:FontWeight.w600,
                  fontSize:16,
                  color:Color(0xFF373737))),
                 const SizedBox(height: 8),
                 RichText(
                  text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF373737)
                  ),
                  children: [
                    const TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: 'Login',
                      style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                             context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                         );
                       },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height:24),
                MyTextField(
                  controller: usernameController,
                  hintText:'Name',
                  obscureText: false,
                  validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      if (value.length < 4) {
                        return 'Name must be at least 4 characters';
                      }
                      return null;
                  },
                ),
                const SizedBox(height: 16,),
                MyTextField(
                  controller: infoController,
                  hintText: 'Email',
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
                      onPressed: registration,
                    ),
              ],
            )
          )
        )
        )
      ) ;
  }
}

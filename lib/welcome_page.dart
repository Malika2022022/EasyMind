import 'package:flutter/material.dart';
import 'package:testdrive/login_page.dart';
import 'package:testdrive/my_button.dart';
import 'package:testdrive/createacc_page.dart';
import 'package:flutter/gestures.dart';
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xFFFFFFF0) ,
      body:SafeArea(
        child:Center(
          child:Column(
            children:[
              const SizedBox(height:130),
              const Text('Welcome =]',
              style:TextStyle(
                fontFamily:'Inter',
                fontWeight:FontWeight.w600,
                fontSize:30,
                color:Color(0xFF373737)
                ),
              ),
              const Text(
                'Hi there!\nWe’re here to help you learn and improve new skills.\nThe choice is yours:',
                textAlign: TextAlign.center,
                style:TextStyle(
                  fontFamily:'Inter',
                  fontWeight:FontWeight.w400,
                  fontSize:14,
                  color:Color(0xFF373737)
                )
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF373737),
                  ),
                  children: [  
                    TextSpan(
                      text: 'Log in',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                       ..onTap = () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>  LoginPage()),
                            );
                          },
                      ),
                    const TextSpan(
                      text: ' or ',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: 'create an account',
                      style: const TextStyle(
                      fontWeight: FontWeight.w600
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>  CreateaccPage()),
                            );
                        },
                    ),
                    const TextSpan(
                      text: '.',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              Image.asset(
                'lib/images/welcome.png',
                width:189,
                height: 236,
              ),
              const SizedBox(height:24),
              MyButton(
                buttontext: 'Create Account ', 
                buttonColor:Color(0xFFEEE8AA), 
                textColor: Color(0xFF373737),
                onPressed:(){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  CreateaccPage()),
                  );
                },
              ), 
              const SizedBox(height:16),
              MyButton(
                buttontext: 'Log in', 
                buttonColor: Color(0xFF373737), 
                textColor: Color(0xFFEEE8AA), 
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=>LoginPage())
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
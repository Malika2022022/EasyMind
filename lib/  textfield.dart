import 'package:flutter/material.dart';
class MyTextField extends StatelessWidget{
  final controller;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffix;
  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.validator,
    this.suffix});
  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:24.0),
      child:TextField(
        controller: controller,
        obscureText: obscureText,
        decoration:InputDecoration(
           enabledBorder: OutlineInputBorder(
              borderSide:BorderSide(color:Colors.white,),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:BorderSide(color:Colors.grey),
              borderRadius: BorderRadius.circular(10)
            ),
            fillColor: const Color(0xFFEEE8AA),
            filled:true,
            hintText: hintText,
            hintStyle:TextStyle(
              color:Color(0xFF828282),
            ),
            contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          suffixIcon: suffix
        ),
      ),
   );
  }
}
import 'package:flutter/material.dart';
class MyButton extends StatelessWidget{
  final String buttontext;
  final Color textColor;
  final Color buttonColor;
  final VoidCallback onPressed;
  final Widget? icon; 
  final double? iconSize;
  MyButton({super.key,
  required this.buttontext,
  required this.buttonColor,
  required this.textColor,
  required this.onPressed,
  this.icon,
  this.iconSize});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onPressed,
       child:Container(
        margin:EdgeInsets.symmetric(horizontal: 24.0),
        padding:const EdgeInsets.symmetric( 
          horizontal: 20,
          vertical: 12, 
        ) ,
        decoration: BoxDecoration(
          color:buttonColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 10),
            ],
            Text(
              buttontext,
              style: TextStyle(
                color: textColor,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ), 
      ),
    );
  }
}
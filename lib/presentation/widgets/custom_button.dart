import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double? width;
  final double? height;
  
  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: Colors.blue,
      minWidth: width ?? double.infinity,
      height: height ?? 50,
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }
}

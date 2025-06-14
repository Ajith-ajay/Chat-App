// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;

  MyButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Ink(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12)
        ),
        child: InkWell(
          child: Center(
            child: Text(text,
            style:TextStyle(
              color:Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16
            )
            ),
          ),
        ),
      ),
    );
  }
}

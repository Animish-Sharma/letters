// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final Color btn_color;
  final Widget? icon;
  final void Function()? onTap;
  const CustomButton(
      {super.key,
      required this.buttonText,
      this.icon,
      this.onTap,
      required this.btn_color});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width / 2.04,
        decoration: BoxDecoration(
          color: btn_color,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Center(
          child: Column(
            children: [
              Text(
                buttonText.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

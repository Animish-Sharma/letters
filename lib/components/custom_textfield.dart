import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final bool isPass;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Widget? icon;
  final Widget? suffix;
  final String? placeholderText;
  const CustomTextField({
    super.key,
    this.focusNode,
    required this.hintText,
    this.icon,
    this.suffix,
    this.placeholderText,
    required this.isPass,
    required this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool visible = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        focusNode: widget.focusNode,
        decoration: InputDecoration(
            hintText: widget.placeholderText,
            prefixIcon: widget.icon,
            iconColor: Theme.of(context).colorScheme.inversePrimary,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            fillColor: Theme.of(context).colorScheme.secondary,
            filled: true,
            label: Text(widget.hintText),
            suffixIcon: widget.isPass
                ? InkWell(
                    onTap: () {
                      setState(() {
                        visible = !visible;
                      });
                    },
                    child: Icon(
                      !visible ? Icons.visibility : Icons.visibility_off,
                    ))
                : widget.suffix,
            suffixIconColor: Theme.of(context).colorScheme.inversePrimary,
            floatingLabelStyle:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.w400)),
        obscureText: widget.isPass && !visible ? true : false,
        controller: widget.controller,
      ),
    );
  }
}

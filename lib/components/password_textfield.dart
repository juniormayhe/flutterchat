import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class PasswordTextField extends StatelessWidget {
  final Function onChanged;

  PasswordTextField({this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
        obscureText: true,
        onChanged: this.onChanged,
        decoration:
            kTextInputDecoration.copyWith(hintText: 'Enter your password'));
  }
}

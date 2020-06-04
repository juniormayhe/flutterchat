import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class EmailTextField extends StatelessWidget {
  final Function onChanged;

  EmailTextField({this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
        keyboardType: TextInputType.emailAddress,
        onChanged: this.onChanged,
        decoration:
            kTextInputDecoration.copyWith(hintText: 'Enter your email'));
  }
}

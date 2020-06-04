/*
* Allow read/write access on all documents to any user signed in to the application at
* https://console.firebase.google.com/project/fastchat-xxxx/database/firestore/rules
* and paste:
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth.uid != null;
    }
  }
}
* */
import 'package:flash_chat/components/email_textfield.dart';
import 'package:flash_chat/components/password_textfield.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              //resize hero when keyboard is on
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              EmailTextField(onChanged: (value) {
                //Do something with the user input.

                this.email = value.trim();
              }),
              SizedBox(
                height: 8.0,
              ),
              PasswordTextField(onChanged: (value) {
                //Do something with the user input.
                this.password = value;
              }),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                  backgroundColor: Colors.lightBlueAccent,
                  text: 'Log In',
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });

                    try {
                      final user = await _auth.signInWithEmailAndPassword(
                          email: email, password: password);
                      if (user != null) {
                        print('$email signed in!');
                        Navigator.pushNamed(context, ChatScreen.id);
                      } else {
                        print('$email NOT signed in!');
                      }
                    } catch (e) {
                      print(e);
                    } finally {
                      setState(() {
                        showSpinner = false;
                      });
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

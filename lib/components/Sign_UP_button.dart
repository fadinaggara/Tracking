import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hadil_project/Screens/Register.dart';



class signup extends StatefulWidget {
  const signup({Key? key}) : super(key: key);

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  @override
  Widget build(BuildContext context) {
    return Align(
        child: Container(
            alignment: Alignment.centerLeft,
            child: MaterialButton(
                onPressed: () => print("Sign Up"),
                padding: EdgeInsets.only(right: 0),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: "     Don't have account? ",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                        text: "Sign UP",
                        style: TextStyle(
                            color: Colors.red,fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Register())
                            );
                          }),
                  ]),
                ))));
  }
}

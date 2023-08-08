import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hadil_project/Screens/forgot_password.dart';
import 'package:hadil_project/components/Sign_UP_button.dart';
import 'package:hadil_project/components/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({key}) : super(key: key);

  @override
  State<LoginPage> createState() => _HomeState();
}

class _HomeState extends State<LoginPage> {

  bool visible = false;
  bool showProgress = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  bool _isObscure3 = true;




  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size size = mediaQuery.size;
    return Scaffold(


      body: Stack(
        children: [
          //Login forme
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 Form(
                   key: _formkey,
                     child: SingleChildScrollView(
                       child: Column(
                         children: [
                           Text(
                             'Bracelet',
                             style: TextStyle(
                                 color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
                           ),
                           SizedBox(
                             height: size.height*0.2 ,
                           ),
                           Padding(
                             padding: const EdgeInsets.all(10.0),
                             child: TextFormField(
                               controller: emailController,
                               decoration: InputDecoration(
                                 prefixIcon: Icon(
                                   Icons.mail,
                                   color: Colors.amber,
                                 ),
                                 filled: true,
                                 fillColor: Colors.white70,
                                 hintText: 'Email',
                                 enabled: true,
                                 focusedBorder: OutlineInputBorder(
                                   borderSide: BorderSide(color: Colors.amber),
                                   borderRadius: BorderRadius.circular(20),
                                 ),
                                 enabledBorder: UnderlineInputBorder(
                                   borderSide: BorderSide(color: Colors.amber),
                                   borderRadius: BorderRadius.circular(20),
                                 ),
                               ),
                               textInputAction: TextInputAction.done,
                               validator: (value) {
                                 if (value!.length == 0) {
                                   return "Email cannot be empty";
                                 }
                                 if (!RegExp(
                                     "^[a-zA-Z0-9.a-zA-Z0-9.!#%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                     .hasMatch(value)) {
                                   return ("Please enter a valid email");
                                 } else {
                                   return null;
                                 }
                               },
                               onChanged: (value) {},
                               keyboardType: TextInputType.emailAddress,
                             ),
                           ),
                           SizedBox(
                             height: 10,
                           ),
                           Padding(
                             padding: const EdgeInsets.all(10.0),
                             child: TextFormField(
                               controller: passwordController,
                               obscureText: _isObscure3,
                               decoration: InputDecoration(
                                 prefixIcon: Icon(
                                   Icons.lock,
                                   color: Colors.amber,
                                 ),
                                 suffixIcon: IconButton(
                                     icon: Icon(_isObscure3
                                         ? Icons.visibility
                                         : Icons.visibility_off),
                                     onPressed: () {
                                       setState(() {
                                         _isObscure3 = !_isObscure3;
                                       });
                                     }),
                                 filled: true,
                                 fillColor: Colors.white70,
                                 hintText: 'Password',
                                 enabled: true,
                                 focusedBorder: OutlineInputBorder(
                                   borderSide: BorderSide(color: Colors.amber),
                                   borderRadius: BorderRadius.circular(20),
                                 ),
                                 enabledBorder: UnderlineInputBorder(
                                   borderSide: BorderSide(color: Colors.amber),
                                   borderRadius: BorderRadius.circular(20),
                                 ),
                               ),
                               validator: (value) {
                                 RegExp regex = new RegExp(r'^.{6,}$');
                                 if (value!.isEmpty) {
                                   return "Password cannot be empty";
                                 }
                                 if (!regex.hasMatch(value)) {
                                   return ("please enter valid password min. 6 character");
                                 } else {
                                   return null;
                                 }
                               },
                               onChanged: (value) {},
                               onSaved: (value) {
                                 passwordController.text = value!;
                               },
                               keyboardType: TextInputType.emailAddress,
                             ),
                           ),

                         ],
                       ),
                     )),

                  Container(
                    alignment: Alignment.centerRight,
                    child: MaterialButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => forgotpass()));
                        },
                        padding: EdgeInsets.only(right: 0),
                        child: Text(
                          "Forgot Password ?  ",
                          style: TextStyle(color: Colors.black),
                        )),
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(20.0))),
                    elevation: 5.0,
                    height: 40,
                    onPressed: () {
                      setState(() {

                        visible = true;
                        showProgress = true;
                      });
                      signIn(emailController.text, passwordController.text,_formkey,context);

                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  signup(),
                  SizedBox(
                    height: 10,
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//autovalidateMode: AutovalidateMode.onUserInteraction,

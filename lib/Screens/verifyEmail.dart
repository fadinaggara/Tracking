import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Login.dart';

class VerifyScreen extends StatefulWidget {

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}
class _VerifyScreenState extends State<VerifyScreen> {

  final _auth = FirebaseAuth.instance;
   User? user = FirebaseAuth.instance.currentUser;

  Timer timer =Timer.periodic(Duration(seconds: 5), (timer){});

  Future<void> checkEmailVerified() async {

    user = _auth.currentUser;
    setState((){});

    await user!.reload();
    if(user!=null){
      if (user!.emailVerified) {
        timer.cancel();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage(),
          ),
        );
      }

    }
  }

  @override
  void initState() {
    user = _auth.currentUser;
    setState((){});

    user!.sendEmailVerification();
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Image.asset('assets/images/logofinal.png',
          height: 50,
          width: 250,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.black,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 80,
                      ),
                      Container(

                        //padding: EdgeInsets.all(40.0),
                        //padding: EdgeInsets.only(right : 10.0,top: 30,bottom: 30),
                          padding: EdgeInsets.all(0),
                          child: Text('An email has been sent to ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 18,
                                //height: 5,
                                color: Colors.white.withOpacity(0.8)
                            ),

                          )
                      ),

                      Container(

                          padding: EdgeInsets.all(30),
                          child: Text('${user!.email}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 25,
                                //height: 5,

                                color: Colors.white.withOpacity(0.8)
                            ),

                          )
                      ),
                      Container(

                          padding: EdgeInsets.all(0),
                          child: Text('Please Verify ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 18,
                                //height: 5,
                                color: Colors.white.withOpacity(0.8)
                            ),

                          )
                      ),
                    ],
                  ),

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}


import 'package:flutter/material.dart';
import 'package:hadil_project/Screens/ContactScreen.dart';
import 'package:hadil_project/Screens/first_screen.dart';
import 'package:hadil_project/Screens/health.dart';
import 'package:hadil_project/Screens/osm.dart';
import 'package:hadil_project/Screens/position.dart';
import 'package:hadil_project/components/container.dart';

class homepage extends StatefulWidget {
  const homepage({Key? key}) : super(key: key);

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size size = mediaQuery.size;


    List<Widget> pageList = [
      const first_screen(),
      const ContactScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  top: size.height * 0.1, right: size.width * 0.5),
              child: Text("HEllo Hedil",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey)),
            ),
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.05,right: size.width * 0.3),
              child: Text("What are you doing?",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.1),
              child: Menu(
                image: "images/location2.png",
                title: "Track Position",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OSM1()),
                  );
                },
              ),
            ),
            Menu(
              image: "images/Health-Tracking-apps.jpg",
              title: "Track Health",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => health()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

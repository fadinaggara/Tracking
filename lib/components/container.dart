import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  final String? title;

  final VoidCallback? onTap;
  final String? image;

  Menu({Key? key, required this.title, this.onTap, this.image})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size size = mediaQuery.size;


    return Column(

      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(image: DecorationImage(
                    image: AssetImage(image.toString()),
                    fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 15.0, // soften the shadow
                        spreadRadius: 5.0, //extend the shadow
                        offset: Offset(
                          5.0, // Move to right 5  horizontally
                          5.0, // Move to bottom 5 Vertically
                        ),
                      )
                    ]),
                width: size.width * 1,
                height: size.height * 0.19,
                child: Center(
                  child: Text(
                    title.toString(),
                    style: TextStyle(color: Colors.black, fontSize: 20,fontWeight: FontWeight.bold),
                  ),
                ),
              )),
        ),
      ],
    );
  }
}

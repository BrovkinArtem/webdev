import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:tiatia/main.dart';
import 'package:tiatia/utils/colors.dart';
import 'package:tiatia/utils/constants.dart';
import 'package:tiatia/utils/styles.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: MobileNavBar(),
      desktop: desktopNavBar(),
    );
  }



//=========== MOBILE ============



  Widget MobileNavBar(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.menu),
          navLogo() 
      ]),
    );
  }



//========= DESKTOP ============ 



  Widget desktopNavBar(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      height: 140,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          navLogo(),
          Row(
            children: [
              navButton('Who are we?'),
              navButton('Who is`s for?'),
              navButton('How it works?'),
              navButton('More'),
            ],
          ),
          Container(
            height: 45,
            child: ElevatedButton(
              style: borderedButtonStyle,
              onPressed: (){},
              child: Text('Autorization', style: TextStyle(color: AppColors.primary),),
            ),
          )

        ],
      ),

    );
  }
  Widget navButton(String text) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: TextButton(onPressed: (){}, child: Text(text, 
      style: TextStyle(
        color: Colors.black,
        fontSize: 18
      ),))
    );
  }

  Widget navLogo(){
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(logo), fit: BoxFit.cover)),
    );
  }
}
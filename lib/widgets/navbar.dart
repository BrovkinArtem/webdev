import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:tiatia/main.dart';
import 'package:tiatia/utils/colors.dart';
import 'package:tiatia/utils/constants.dart';
import 'package:tiatia/utils/styles.dart';
import 'package:tiatia/pages/Authorization/SignUp.dart';
import 'package:tiatia/pages/Authorization/SignIn.dart';

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
          navLogo(),
          Container(
            height: 45,
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [ 
              ElevatedButton(
              style: borderedButtonStyle2,
              onPressed: (){Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignIn()),
                          );},
              child: Text('Sign in', style: TextStyle(color: AppColors.primary),),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              style: borderedButtonStyle,
              onPressed: (){Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUp()),
                          );},
              child: Text('Sign up', style: TextStyle(color: AppColors.primary),),
          )])
          ),
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
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [ 
              ElevatedButton(
              style: borderedButtonStyle2,
              onPressed: (){Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignIn()),
                          );},
              child: Text('Sign in', style: TextStyle(color: AppColors.primary),),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              style: borderedButtonStyle,
              onPressed: (){Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUp()),
                          );},
              child: Text('Sign up', style: TextStyle(color: AppColors.primary),),
          )])
          ),
        ],
    ));
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
        image: DecorationImage(image: AssetImage(logo))),
    );
  }
}
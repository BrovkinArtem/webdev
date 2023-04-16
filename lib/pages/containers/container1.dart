import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:tiatia/utils/colors.dart';

import '../../utils/constants.dart';


class Container1 extends StatefulWidget {
  const Container1({Key? key}) : super(key: key);

  @override
  State<Container1> createState() => _Container1State();
}

class _Container1State extends State<Container1> {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: DesktopContainer1(),
      desktop: DesktopContainer1(),
      
    );
  }

  Widget DesktopContainer1(){
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TURTLE \nINVEST \nADVISOR',
                style: TextStyle(
                  fontSize: w!/20,
                  fontWeight: FontWeight.bold,
                  height: 1.2
                ),),
                SizedBox(height: 20,),
                Text('   web-application  -  \n   for automating purchases of securities \n   on the stock market using an averaging algorithm',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16
                ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Container(
                      height: 45,
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(AppColors.primary)
                        ),
                        onPressed: (){}, 
                        icon: Icon(Icons.arrow_drop_down),
                        label: Text('Telegram bot'))
                    ),
                    SizedBox(width: 20,),
                    Text('— Same functionality, different platform', style: TextStyle(color: Colors.grey.shade400, fontSize: 16))
                  ],
                )
              ],
            ),
          )),
          Expanded(child: Container(
            height: 530,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(illustration1),
              fit: BoxFit.contain)
            ),
          ))
        ],
      ),
    );
  }
}
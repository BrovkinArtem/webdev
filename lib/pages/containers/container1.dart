import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:tiatia/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

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
      mobile: MobileContainer1(),
      desktop: DesktopContainer1(),
    );
  }

//=========== MOBILE ============

  Widget MobileContainer1() {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: w!/10, vertical: 20),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: w! / 1.08,
            width: w! / 1.08,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(illustration4), fit: BoxFit.contain)),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'TURTLE \nINVEST \nADVISOR',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: w! / 10, fontWeight: FontWeight.bold, height: 1.2),
          ),
          SizedBox(height: 5),
          Text(
            '   веб-приложение  -  \n   с автоматизацией ценных бумаг \n   через фондовый рынок по стратегии усреднения',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
              height: 45,
              child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(AppColors.primary)),
                  onPressed: () {},
                  icon: Icon(Icons.arrow_drop_down),
                  label: Text('Telegram bot'))),
          SizedBox(
            height: 20,
          ),
          Text('— Тот же функционал, другая платформа',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
          SizedBox(height: 30)
        ],
      ),
    );
  }

//========= DESKTOP ============

  Widget DesktopContainer1() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: w! / 10, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
              child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TURTLE \nINVEST \nADVISOR',
                  style: TextStyle(
                      fontSize: w! / 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2),
                ),
                SizedBox(height: 5),
                Text(
                  '   веб-приложение  -  \n   с автоматизацией ценных бумаг \n   через фондовый рынок по стратегии усреднения',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 20),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Container(
                        height: 45,
                        child: ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    AppColors.primary)),
                            onPressed: () async {
                              const url =
                                  'https://web.telegram.org/k/#@AveragingInvestor_bot';
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              } else {
                                throw 'Не удалось открыть страницу $url';
                              }
                              ;
                            },
                            icon: Icon(Icons.arrow_drop_down),
                            label: Text('Telegram bot'))),
                    SizedBox(width: 20),
                    Text('— Тот же функционал, другая платформа',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 20))
                  ],
                )
              ],
            ),
          )),
          Expanded(
              child: Container(
            height: 550,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(illustration4), fit: BoxFit.contain)),
          ))
        ],
      ),
    );
  }
}

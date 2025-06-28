import 'package:ecommerce_int2/screens/splash_page.dart';
import 'package:flutter/material.dart';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eCommerce int2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        canvasColor: Colors.transparent,
        primarySwatch: MaterialColor(0xff9ddf00, {
          50: Color(0xfff0f9e6),
          100: Color(0xffd9f0b3),
          200: Color(0xffc0e680),
          300: Color(0xffa7dc4d),
          400: Color(0xff94d426),
          500: Color(0xff9ddf00),
          600: Color(0xff8cdb00),
          700: Color(0xff78d700),
          800: Color(0xff64d300),
          900: Color(0xff42cb00),
        }),
        fontFamily: "Montserrat",
      ),
      home: SplashScreen(),
    );
  }
}

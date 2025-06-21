import 'package:ecommerce_int2/api_service.dart';
import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/screens/auth/welcome_back_page.dart';
import 'package:ecommerce_int2/screens/main/main_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> opacity;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 2500),
      vsync: this,
    );
    opacity = Tween<double>(begin: 1.0, end: 0.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });

    controller.forward().then((_) {
      navigationPage();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void navigationPage() async {
    final token = await ApiService.getToken();
    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => WelcomeBackPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(color: transparentYellow),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Opacity(
                    opacity: opacity.value,
                    child: Image.asset('assets/logo.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(text: 'Powered by '),
                        TextSpan(
                          text: 'int2.io',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:ecommerce_int2/screens/complaint/add_complaint_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomBar extends StatelessWidget {
  final TabController controller;

  const CustomBottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: SvgPicture.asset('assets/icons/home_icon.svg'),
            onPressed: () => controller.animateTo(0),
          ),
          IconButton(
            icon: Image.asset('assets/icons/category_icon.png'),
            onPressed: () => controller.animateTo(1),
          ),
          IconButton(
            icon: SvgPicture.asset(
                'assets/icons/complaint_icon.svg'), // Use your complaint SVG/icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddComplaintScreen()),
              );
            },
          ),
          IconButton(
            icon: Image.asset('assets/icons/profile_icon.png'),
            onPressed: () => controller.animateTo(3),
          ),
        ],
      ),
    );
  }
}

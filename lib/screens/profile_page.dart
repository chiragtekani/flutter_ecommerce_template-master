import 'dart:convert';

import 'package:ecommerce_int2/api_service.dart';
import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/screens/complaint/my_complaints.dart';
import 'package:ecommerce_int2/screens/settings/settings_page.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'Loading...';
  String email = '';
  String phone = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await ApiService.getCustomerProfile();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        data = data['data']['customer'];
        setState(() {
          userName = data['name'] ?? 'Unknown';
          email = data['email'] ?? '';
          phone = data['phone'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          userName = 'Failed to load';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userName = 'Failed to load';
        isLoading = false;
      });
    }
  }

  void navigateToSettings() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => SettingsPage(profile: {
                'name': userName,
                'email': email,
                'phone': phone,
              })),
  );
    if (result == true) {
      fetchUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.only(left: 16.0, right: 16.0, top: kToolbarHeight),
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  maxRadius: 48,
                  backgroundImage: AssetImage('assets/background.jpg'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Column(
                          children: [
                            Text(
                              userName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(email, style: TextStyle(color: Colors.grey)),
                            Text(phone, style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
                // ListTile(
                //   title: Text('Settings'),
                //   subtitle: Text('Privacy and logout'),
                //   leading: Image.asset('assets/icons/settings_icon.png',
                //       fit: BoxFit.scaleDown, width: 30, height: 30),
                //   trailing: Icon(Icons.chevron_right, color: yellow),
                //   onTap: navigateToSettings,
                // ),
                // Divider(),
                // ListTile(
                //   title: Text('Help & Support'),
                //   subtitle: Text('Help center and legal support'),
                //   leading: Image.asset('assets/icons/support.png'),
                //   trailing: Icon(Icons.chevron_right, color: yellow),
                // ),
                // Divider(),
                ListTile(
                  title: Text('My Complaints'),
                  subtitle: Text('View your submitted complaints'),
                  leading: Icon(Icons.report_problem, color: Colors.orange),
                  trailing: Icon(Icons.chevron_right, color: yellow),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MyComplaintsPage()),
                    );
                  },
                ),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

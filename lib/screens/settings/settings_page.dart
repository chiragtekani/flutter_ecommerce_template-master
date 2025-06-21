import 'package:ecommerce_int2/api_service.dart';
import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/screens/auth/welcome_back_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  final Map<String, dynamic> profile;

  const SettingsPage({Key? key, required this.profile}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await ApiService.removeToken();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );

    // Navigate to WelcomeBackPage and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => WelcomeBackPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        title: Text('Settings', style: TextStyle(color: Colors.black)),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/background.jpg'),
            ),
            SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    profile['name'] ?? 'Unknown',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Text(profile['email'] ?? '',
                      style: TextStyle(color: Colors.grey)),
                  Text(profile['phone'] ?? '',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            SizedBox(height: 32),
            ListTile(
              title: Text('Account Information'),
              subtitle: Text('Update your profile details'),
              leading: Icon(Icons.person, color: yellow),
              trailing: Icon(Icons.chevron_right, color: yellow),
              onTap: () {
                // Navigate to edit page (optional)
              },
            ),
            Divider(),
            ListTile(
              title: Text('Notifications'),
              subtitle: Text('Manage push notifications'),
              leading: Icon(Icons.notifications, color: yellow),
              trailing: Icon(Icons.chevron_right, color: yellow),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              title: Text('Language'),
              subtitle: Text('Choose app language'),
              leading: Icon(Icons.language, color: yellow),
              trailing: Icon(Icons.chevron_right, color: yellow),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              title: Text('Logout'),
              subtitle: Text('Sign out of your account'),
              leading: Icon(Icons.logout, color: Colors.red),
              trailing: Icon(Icons.chevron_right, color: Colors.red),
              onTap: () => _logout(context),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}

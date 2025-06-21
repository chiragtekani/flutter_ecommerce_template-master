import 'dart:convert';
import 'package:ecommerce_int2/api_service.dart';
import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/screens/main/main_page.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController name = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  bool isLoading = false;

  List<dynamic> districts = [];
  List<dynamic> talukas = [];
  List<dynamic> villages = [];

  int? selectedDistrict;
  int? selectedTaluka;
  int? selectedVillage;

  @override
  void initState() {
    super.initState();
    fetchDistricts();
  }

  Future<void> fetchDistricts() async {
    final response = await ApiService.getDistricts();
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      setState(() => districts = decoded['data']);
    } else {
      // Handle error gracefully
      print('Failed to load districts: ${response.statusCode}');
    }
  }

  Future<void> fetchTalukas(int districtId) async {
    final response = await ApiService.getTalukas(districtId);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      setState(() => talukas = decoded['data']['talukas']);
    } else {
      print('Failed to load talukas: ${response.statusCode}');
    }
  }

  Future<void> fetchVillages(int talukaId) async {
    final response = await ApiService.getVillages(talukaId);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      setState(() => talukas = decoded['data']['villages']);
    } else {
      print('Failed to load villages: ${response.statusCode}');
    }
  }

  void _registerUser() async {
    if ([
      name.text,
      username.text,
      email.text,
      phone.text,
      password.text,
      confirmPassword.text,
    ].any((field) => field.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    if (password.text != confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (selectedDistrict == null ||
        selectedTaluka == null ||
        selectedVillage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select district, taluka, and village')),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await ApiService.customerRegister({
      'name': name.text.trim(),
      'username': username.text.trim(),
      'email': email.text.trim(),
      'phone': phone.text.trim(),
      'password': password.text.trim(),
      'password_confirmation': confirmPassword.text.trim(),
      'district_id': selectedDistrict,
      'taluka_id': selectedTaluka,
      'village_id': selectedVillage,
    });

    setState(() => isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainPage()),
      );
    } else {
      final body = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(body['message'] ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover),
            ),
          ),
          Container(color: transparentYellow),
          Padding(
            padding: const EdgeInsets.only(left: 28.0, right: 28.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 80),
                  Text(
                    'Glad To Meet You',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 5),
                          blurRadius: 10,
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your new account for future uses.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0.85),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _buildTextField(name, 'Name'),
                        _buildTextField(username, 'Username'),
                        _buildTextField(email, 'Email'),
                        _buildTextField(phone, 'Phone'),
                        _buildTextField(password, 'Password', obscure: true),
                        _buildTextField(confirmPassword, 'Confirm Password',
                            obscure: true),
                        DropdownButtonFormField<int>(
                          value: selectedDistrict,
                          hint: Text('Select District'),
                          items: districts
                              .map<DropdownMenuItem<int>>((d) =>
                                  DropdownMenuItem<int>(
                                      value: d['id'], child: Text(d['name'])))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedDistrict = val;
                              selectedTaluka = null;
                              selectedVillage = null;
                              talukas = [];
                              villages = [];
                            });
                            fetchTalukas(val!);
                          },
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          value: selectedTaluka,
                          hint: Text('Select Taluka'),
                          items: talukas
                              .map<DropdownMenuItem<int>>((t) =>
                                  DropdownMenuItem<int>(
                                      value: t['id'], child: Text(t['name'])))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedTaluka = val;
                              selectedVillage = null;
                              villages = [];
                            });
                            fetchVillages(val!);
                          },
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          value: selectedVillage,
                          hint: Text('Select Village'),
                          items: villages
                              .map<DropdownMenuItem<int>>((v) =>
                                  DropdownMenuItem<int>(
                                      value: v['id'], child: Text(v['name'])))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => selectedVillage = val),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 60, vertical: 16),
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              Text('Register', style: TextStyle(fontSize: 18)),
                        ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Positioned(
            top: 35,
            left: 5,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
    );
  }
}

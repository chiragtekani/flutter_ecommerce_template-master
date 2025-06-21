import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ecommerce_int2/api_service.dart';

class MyComplaintsPage extends StatefulWidget {
  @override
  _MyComplaintsPageState createState() => _MyComplaintsPageState();
}

class _MyComplaintsPageState extends State<MyComplaintsPage> {
  List complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadComplaints();
  }

  Future<void> loadComplaints() async {
    try {
      final profileResponse = await ApiService.getCustomerProfile();
      if (profileResponse.statusCode == 200) {
        var profileData = jsonDecode(profileResponse.body);
        profileData = profileData['data']['customer'];
        final customerId = profileData['id'];

        final complaintsResponse =
            await ApiService.getCustomerComplaints(customerId);
        if (complaintsResponse.statusCode == 200) {
          var complaintList = jsonDecode(complaintsResponse.body);
          complaintList = complaintList['data']['complaints'];
          setState(() {
            complaints = complaintList;
            isLoading = false;
          });
        } else {
          throw Exception("Failed to load complaints");
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading complaints")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Complaints')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : complaints.isEmpty
              ? Center(child: Text("No complaints found."))
              : ListView.builder(
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final item = complaints[index];
                    return ListTile(
                      leading: Icon(Icons.report_problem, color: Colors.red),
                      title: Text(item['complaint'] ?? ''),
                      subtitle: Text(item['shop_name'] ?? ''),
                      trailing: Text(item['pin_code'] ?? ''),
                    );
                  },
                ),
    );
  }
}

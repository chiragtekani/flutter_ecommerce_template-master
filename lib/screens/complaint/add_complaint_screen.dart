import 'dart:convert';
import 'package:ecommerce_int2/api_service.dart';
import 'package:flutter/material.dart';

class AddComplaintScreen extends StatefulWidget {
  @override
  _AddComplaintScreenState createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController shopController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController complaintController = TextEditingController();

  bool isLoading = false;

  List<dynamic> villages = [];
  int? selectedVillage;

  @override
  void initState() {
    super.initState();
    // fetchVillages(); // Replace with actual taluka ID if needed
  }

  Future<void> fetchVillages(int talukaId) async {
    final response = await ApiService.getVillages(talukaId);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      setState(() => villages = decoded['data']['villages']);
    } else {
      print('Failed to load villages: ${response.statusCode}');
    }
  }

  void _submitComplaint() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (selectedVillage == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please select a village"),
          backgroundColor: Colors.red,
        ));
        return;
      }

      setState(() => isLoading = true);

      final body = {
        "customer_name": nameController.text,
        "village_id": selectedVillage,
        "shop_name": shopController.text,
        "pin_code": pinController.text,
        "address": addressController.text,
        "complaint": complaintController.text,
      };

      final response = await ApiService.addComplaint(body);

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Complaint submitted successfully!"),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to submit complaint"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Complaint")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Customer Name"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selectedVillage,
                hint: Text("Select Village"),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                items: villages
                    .map((v) => DropdownMenuItem<int>(
                          value: v['id'] as int,
                          child: Text(v['name'] as String),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedVillage = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Please select a village" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: shopController,
                decoration: InputDecoration(labelText: "Shop Name"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: pinController,
                decoration: InputDecoration(labelText: "Pin Code"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: "Address"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: complaintController,
                decoration: InputDecoration(labelText: "Complaint"),
                maxLines: 3,
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _submitComplaint,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

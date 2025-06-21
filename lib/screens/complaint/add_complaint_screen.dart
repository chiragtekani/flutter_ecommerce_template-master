import 'package:ecommerce_int2/api_service.dart';
import 'package:flutter/material.dart';

class AddComplaintScreen extends StatefulWidget {
  @override
  _AddComplaintScreenState createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController villageController = TextEditingController();
  final TextEditingController shopController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController complaintController = TextEditingController();

  bool isLoading = false;

  void _submitComplaint() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);

      final body = {
        "customer_name": nameController.text,
        "village_id": int.tryParse(villageController.text) ?? 0,
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
                  validator: (val) => val!.isEmpty ? "Required" : null),
              TextFormField(
                  controller: villageController,
                  decoration: InputDecoration(labelText: "Village ID"),
                  validator: (val) => val!.isEmpty ? "Required" : null),
              TextFormField(
                  controller: shopController,
                  decoration: InputDecoration(labelText: "Shop Name"),
                  validator: (val) => val!.isEmpty ? "Required" : null),
              TextFormField(
                  controller: pinController,
                  decoration: InputDecoration(labelText: "Pin Code"),
                  validator: (val) => val!.isEmpty ? "Required" : null),
              TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: "Address"),
                  validator: (val) => val!.isEmpty ? "Required" : null),
              TextFormField(
                  controller: complaintController,
                  decoration: InputDecoration(labelText: "Complaint"),
                  maxLines: 3,
                  validator: (val) => val!.isEmpty ? "Required" : null),
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

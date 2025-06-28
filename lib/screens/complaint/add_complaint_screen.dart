import 'dart:convert';
import 'dart:io';
import 'package:ecommerce_int2/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddComplaintScreen extends StatefulWidget {
  @override
  _AddComplaintScreenState createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final pinController = TextEditingController();
  final addressController = TextEditingController();
  final complaintController = TextEditingController();
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  List<dynamic> districts = [];
  List<dynamic> talukas = [];
  List<dynamic> villages = [];
  List<dynamic> shops = [];

  int? selectedDistrict;
  int? selectedTaluka;
  int? selectedVillage;
  int? selectedShop;

  bool isLoading = false;

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
    }
  }

  Future<void> fetchTalukas(int districtId) async {
    final response = await ApiService.getTalukas(districtId);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      setState(() => talukas = decoded['data']['talukas']);
    }
  }

  Future<void> fetchVillages(int talukaId) async {
    final response = await ApiService.getVillages(talukaId);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      setState(() => villages = decoded['data']['villages']);
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> fetchShops(int villageId) async {
    final response = await ApiService.getShopsByVillage(villageId);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      setState(() => shops = decoded['data']['vendors']);
    }
  }

  void _submitComplaint() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (selectedVillage == null || selectedShop == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please select village and shop"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() => isLoading = true);

    final Map<String, String> body = {
      "customer_name": nameController.text,
      "village_id": selectedVillage.toString(),
      "district_id": selectedDistrict.toString(),
      "vendor_id": selectedShop.toString(),
      "taluka_id": selectedTaluka.toString(),
      "shop_name":
          shops.firstWhere((shop) => shop['id'] == selectedShop)['name'],
      "pin_code": pinController.text,
      "address": addressController.text,
      "complaint": complaintController.text,
    };

    var request = await ApiService.buildMultipartRequest("complaint/add", body);

    if (selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', selectedImage!.path),
      );
    }

    final response = await ApiService.sendMultipartRequest(request);

    setState(() => isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
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
              _buildTextField(nameController, "Customer Name"),
              SizedBox(height: 12),
              _buildDropdown<int>(
                label: "Select District",
                value: selectedDistrict,
                items: districts,
                itemLabel: 'name',
                onChanged: (val) {
                  setState(() {
                    selectedDistrict = val;
                    selectedTaluka = null;
                    selectedVillage = null;
                    selectedShop = null;
                    talukas = [];
                    villages = [];
                    shops = [];
                  });
                  fetchTalukas(val!);
                },
              ),
              SizedBox(height: 12),
              _buildDropdown<int>(
                label: "Select Taluka",
                value: selectedTaluka,
                items: talukas,
                itemLabel: 'name',
                onChanged: selectedDistrict == null
                    ? null
                    : (val) {
                        setState(() {
                          selectedTaluka = val;
                          selectedVillage = null;
                          selectedShop = null;
                          villages = [];
                          shops = [];
                        });
                        fetchVillages(val!);
                      },
              ),
              SizedBox(height: 12),
              _buildDropdown<int>(
                label: "Select Village",
                value: selectedVillage,
                items: villages,
                itemLabel: 'name',
                onChanged: selectedTaluka == null
                    ? null
                    : (val) {
                        setState(() {
                          selectedVillage = val;
                          selectedShop = null;
                          shops = [];
                        });
                        fetchShops(val!);
                      },
              ),
              SizedBox(height: 12),
              _buildDropdown<int>(
                label: "Select Shop",
                value: selectedShop,
                items: shops,
                itemLabel: 'name',
                onChanged: selectedVillage == null
                    ? null
                    : (val) {
                        setState(() {
                          selectedShop = val;
                        });
                      },
              ),
              SizedBox(height: 12),
              _buildTextField(pinController, "Pin Code"),
              _buildTextField(addressController, "Address"),
              _buildTextField(complaintController, "Complaint", maxLines: 3),
              SizedBox(height: 12),
              Text("Attach Image (optional)",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.photo),
                    label: Text("Pick Image"),
                    onPressed: pickImage,
                  ),
                  SizedBox(width: 16),
                  if (selectedImage != null)
                    Expanded(
                      child: Image.file(
                        selectedImage!,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
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

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (val) => val!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<dynamic> items,
    required String itemLabel,
    required void Function(T?)? onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(label),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
      ),
      items: items
          .map<DropdownMenuItem<T>>((item) => DropdownMenuItem<T>(
                value: item['id'] as T,
                child: Text(item[itemLabel]),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "Required" : null,
    );
  }
}

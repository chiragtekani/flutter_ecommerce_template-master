import 'dart:convert';
import 'package:ecommerce_int2/api_service.dart';
import 'package:ecommerce_int2/app_properties.dart';
import 'package:ecommerce_int2/models/product.dart';
import 'package:ecommerce_int2/screens/main/components/product_list.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<dynamic> districts = [];
  List<dynamic> talukas = [];
  List<dynamic> villages = [];
  List<dynamic> shops = [];

  int? selectedDistrict;
  int? selectedTaluka;
  int? selectedVillage;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDistricts();
  }

  Future<void> fetchDistricts() async {
    final response = await ApiService.getDistricts();
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        districts = data['data'];
        isLoading = false;
      });
    }
  }

  Future<void> fetchTalukas(int districtId) async {
    final response = await ApiService.getTalukas(districtId);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        talukas = data['data'];
      });
    }
  }

  Future<void> fetchVillages(int talukaId) async {
    final response = await ApiService.getVillages(talukaId);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        villages = data['data'];
      });
    }
  }

  Future<void> fetchShops(int villageId) async {
    final response = await ApiService.getShopsByVillage(villageId);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        shops = data['data'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shop Locator"),
        backgroundColor: darkGrey,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedDistrict,
                    hint: Text("Select District"),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: districts
                        .map((d) => DropdownMenuItem<int>(
                              value: d['id'] as int,
                              child: Text(d['name'] as String),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDistrict = value;
                        selectedTaluka = null;
                        selectedVillage = null;
                        talukas = [];
                        villages = [];
                        shops = [];
                      });
                      if (value != null) fetchTalukas(value);
                    },
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedTaluka,
                    hint: Text("Select Taluka"),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: talukas
                        .map((t) => DropdownMenuItem<int>(
                              value: t['id'] as int,
                              child: Text(t['name'] as String),
                            ))
                        .toList(),
                    onChanged: selectedDistrict == null
                        ? null
                        : (value) {
                            setState(() {
                              selectedTaluka = value;
                              selectedVillage = null;
                              villages = [];
                              shops = [];
                            });
                            if (value != null) fetchVillages(value);
                          },
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
                    onChanged: selectedTaluka == null
                        ? null
                        : (value) {
                            setState(() {
                              selectedVillage = value;
                              shops = [];
                            });
                            if (value != null) fetchShops(value);
                          },
                  ),
                  SizedBox(height: 20),
                  shops.isEmpty
                      ? Text("No shops to display")
                      : Expanded(
                          child: ListView.builder(
                            itemCount: shops.length,
                            itemBuilder: (context, index) {
                              final shop = shops[index];
                              return Card(
                                child: ListTile(
                                  title: Text(shop['name'] as String),
                                  subtitle: Text(shop['address'] as String),
                                  onTap: () async {
                                    final response =
                                        await ApiService.getProductsByShop(
                                            shop['id'] as int);
                                    if (response.statusCode == 200) {
                                      final data = jsonDecode(response.body);
                                      final productList = (data['data'] as List)
                                          .map((item) => Product(
                                                item[
                                                    'image_url'], // Adjust key if needed
                                                item['name'],
                                                item['description'],
                                                double.tryParse(item['price']
                                                        .toString()) ??
                                                    0.0,
                                              ))
                                          .toList();

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductList(
                                              products: productList),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Failed to load products")),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}

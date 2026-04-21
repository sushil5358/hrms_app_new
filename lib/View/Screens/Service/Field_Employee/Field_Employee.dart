import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/colers.dart';
import 'Client_Visit.dart';
import 'Comlete_Tsak.dart';

class FieldEmployee extends StatefulWidget {
  const FieldEmployee({super.key});

  @override
  State<FieldEmployee> createState() => _FieldEmployeeState();
}

class _FieldEmployeeState extends State<FieldEmployee> {


  final List<Map<String, dynamic>> FildOptions = [
    {
      'title': 'Client Visit',
      'icon': Icons.business,
      'color': Colors.blue,
      'description': 'Mark your client visits and track meetings',
      'route' : (){
        Get.to(()=>  ClientVisit());
      }
    },
    {
      'title': 'Complete Task Report Upload',
      'icon': Icons.upload_file,
      'color': Colors.green,
      'description': 'Upload task completion reports with photos',
      'route' : (){
        Get.to(()=> ComleteTsak());
      }
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Field Employee"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: Column(
          children: [
            // Leave Options Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: FildOptions.length,
                  itemBuilder: (context, index) {
                    final option = FildOptions[index];
                    return _builddocumentOptionsOptionsOptionsCard(option);
                  },
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
  Widget _builddocumentOptionsOptionsOptionsCard(Map<String, dynamic> option) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // _handleNavigation(option['title']);
          option['route']();

        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: option['color'].withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: option['color'].withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  option['icon'],
                  size: 35,
                  color: option['color'],
                ),
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                option['title'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: option['color'],
                ),
              ),
              const SizedBox(height: 4),
              // Description
              Text(
                option['description'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

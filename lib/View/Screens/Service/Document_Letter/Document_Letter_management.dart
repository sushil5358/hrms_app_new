import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/colers.dart';
import 'Document_Letter_Request.dart';
import 'HR_Policy.dart';
import 'Tax_Declaration.dart';

class DocumentLetterManagement extends StatefulWidget {
  const DocumentLetterManagement({super.key});

  @override
  State<DocumentLetterManagement> createState() => _DocumentLetterManagementState();
}

class _DocumentLetterManagementState extends State<DocumentLetterManagement> {

  final List<Map<String, dynamic>> documentOptions = [
    {
      'title': 'Certificate & Letter Request',
      'icon': Icons.description,
      'color': Colors.blue,
      'description': 'View and download official certificates & letters',
      'route' : (){
        Get.to(()=> DocumentLetterRequest());
      }
    },
    {
      'title': 'HR Policy',
      'icon': Icons.policy,
      'color': Colors.green,
      'description': 'View company HR policies and guidelines',
      'route' : (){
        Get.to(()=> HrPolicy());
      }
    },
    // {
    //   'title': 'Tax Declaration',
    //   'icon': Icons.receipt,
    //   'color': Colors.orange,
    //   'description': 'Submit tax declaration and view tax details',
    //   'route' : (){
    //     Get.to(()=> TaxDeclaration());
    //   }
    // },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document & Letter"),
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
                  itemCount: documentOptions.length,
                  itemBuilder: (context, index) {
                    final option = documentOptions[index];
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

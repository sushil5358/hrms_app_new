import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/colers.dart';
import 'Request_attendance_correction.dart';
import 'WorkFlow.dart';

class Regularization extends StatefulWidget {
  const Regularization({super.key});

  @override
  State<Regularization> createState() => _RegularizationState();
}

class _RegularizationState extends State<Regularization> {

  final List<Map<String, dynamic>> RegularizationOptions = [
    {
      'title': 'Request attendance correction',
      'icon': Icons.edit_calendar,
      'color': Colors.blue,
      'description': 'Request correction for attendance records',
      'route' : (){
        Get.to(()=>  RequestAttendanceCorrection());
      }
    },
    // {
    //   'title': 'Manager approval workflow',
    //   'icon': Icons.approval,
    //   'color': Colors.green,
    //   'description': 'Track approval status of your requests',
    //   'route' : (){
    //     Get.to(()=>  Workflow());
    //   }
    // },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Regularization"),
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
                  itemCount: RegularizationOptions.length,
                  itemBuilder: (context, index) {
                    final option = RegularizationOptions[index];
                    return _buildRegularizationOptionsOptionsOptionsOptionsCard(option);
                  },
                ),
              ),
            ),
          ],
        ),
      ),


    );
  }
  Widget _buildRegularizationOptionsOptionsOptionsOptionsCard(Map<String, dynamic> option) {
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

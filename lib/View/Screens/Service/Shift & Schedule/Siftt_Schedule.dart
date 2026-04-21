import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/colers.dart';
import 'Holiday_list.dart';
import 'SirtSchedule_Change_ReQuset.dart';

class SifttSchedule extends StatefulWidget {
  const SifttSchedule({super.key});

  @override
  State<SifttSchedule> createState() => _SifttScheduleState();
}

class _SifttScheduleState extends State<SifttSchedule> {
  final List<Map<String, dynamic>> shiftOptions = [
    {
      'title': 'Shift Schedule & Change Request',
      'icon': Icons.schedule,
      'color': Colors.blue,
      'description': 'View shift schedule and request changes',
      'route': () {
        Get.to(() =>  SirtscheduleChangeRequset());
      }
    },
    {
      'title': 'Holiday List',
      'icon': Icons.card_giftcard,
      'color': Colors.green,
      'description': 'View upcoming holidays and festivals',
      'route': () {
        Get.to(() =>  HolidayList());
      }
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shift & Schedule"),
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
                itemCount: shiftOptions.length,
                itemBuilder: (context, index) {
                  final option = shiftOptions[index];
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

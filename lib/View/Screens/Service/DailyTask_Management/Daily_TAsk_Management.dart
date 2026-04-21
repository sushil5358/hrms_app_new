import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/colers.dart';
import 'Task.dart';
import 'Upload_Task.dart' hide DailyTask;

class DailyTaskManagement extends StatefulWidget {
  const DailyTaskManagement({super.key});

  @override
  State<DailyTaskManagement> createState() => _DailyTaskManagementState();
}

class _DailyTaskManagementState extends State<DailyTaskManagement> {

  final List<Map<String, dynamic>> TaskManagementOptions = [
    {
      'title': 'Daily Task',
      'icon': Icons.task_alt,
      'color': Colors.blue,
      'description': 'View and manage your daily tasks',
      'route': () {
        Get.to(() => DailyTask());
      }
    },
    {
      'title': 'Review Completed Task',
      'icon': Icons.rate_review, // Changed icon
      'color': Colors.green,
      'description': 'Review and verify submitted task reports', // Changed description
      'route': () {
        Get.to(() => UploadTask());
      }
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        title: const Text("Daily Task & Management"),
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
                    childAspectRatio: 0.8,
                  ),
                  itemCount: TaskManagementOptions.length,
                  itemBuilder: (context, index) {
                    final option = TaskManagementOptions[index];
                    return _buildTaskManagementOptionsCard(option);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTaskManagementOptionsCard(Map<String, dynamic> option) {
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

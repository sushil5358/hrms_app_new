import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/colers.dart';
import 'ApplyLeave.dart';
import 'Leave_Balance.dart';
import 'Leave_Cancle.dart';
import 'Leave_History.dart';

class Leave extends StatefulWidget {
  const Leave({super.key});

  @override
  State<Leave> createState() => _LeaveState();
}

class _LeaveState extends State<Leave> {

  final List<Map<String, dynamic>> leaveOptions = [
    {
      'title': 'Apply Leave',
      'icon': Icons.add_circle_outline,
      'color': Colors.blue,
      'description': 'Request for new leave',
      'route' : (){
        Get.to(()=>Applyleave());
      }
    },
    {
      'title': 'Leave Balance',
      'icon': Icons.account_balance_wallet_outlined,
      'color': Colors.green,
      'description': 'Check your remaining leaves',
      'route' : (){
        Get.to(()=>LeaveBalance());
      }
    },
    {
      'title': 'Leave History',
      'icon': Icons.history,
      'color': Colors.orange,
      'description': 'View all your leave records',
      'route' : (){
        Get.to(()=>LeaveHistory());
      }
    },
    {
      'title': 'Leave Cancel',
      'icon': Icons.cancel_outlined,
      'color': Colors.red,
      'description': 'Cancel applied leave',
      'route' : (){
        Get.to(()=>LeaveCancle());
      }
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        title: const Text("Leave Management"),
        elevation: 0,
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
                    childAspectRatio: 0.9,
                  ),
                  itemCount: leaveOptions.length,
                  itemBuilder: (context, index) {
                    final option = leaveOptions[index];
                    return _buildLeaveCard(option);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveCard(Map<String, dynamic> option) {
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
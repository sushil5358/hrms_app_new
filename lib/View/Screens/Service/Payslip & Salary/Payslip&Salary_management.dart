import 'package:employee_app/utils/colers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Crrent_salary_view.dart';
import 'Download_Payslips.dart';
import 'ReimburementClaim&Suubmission.dart';
import 'Salary_BreahupView.dart';

class Payslip extends StatefulWidget {
  const Payslip({super.key});

  @override
  State<Payslip> createState() => _PayslipState();
}

class _PayslipState extends State<Payslip> {

  final List<Map<String, dynamic>> PayslipOptions = [
    {
      'title': 'Download Payslips',
      'icon': Icons.download,
      'color': Colors.blue,
      'description': 'View and download your monthly payslips',
      'route' : (){
        Get.to(()=> DownloadPayslips());
      }
    },
    {
      'title': 'Salary Breakup View',
      'icon': Icons.pie_chart,
      'color': Colors.green,
      'description': 'View detailed salary structure',
      'route' : (){
        Get.to(()=>  SalaryBreahupview());
      }
    },
    {
      'title': 'Current Month Salary View',
      'icon': Icons.receipt,
      'color': Colors.orange,
      'description': 'Quickly view your current month salary summary and details',
      'route' : (){
        Get.to(()=>  CrrentSalaryView());
      }
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payroll & Salary"),
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
                  itemCount: PayslipOptions.length,
                  itemBuilder: (context, index) {
                    final option = PayslipOptions[index];
                    return _buildPayslipOptionsOptionsCard(option);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPayslipOptionsOptionsCard(Map<String, dynamic> option) {
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

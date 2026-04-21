import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/colers.dart';
import 'LoanBalanceTracking.dart';
import 'SalaryadvanceRequest.dart';

class LoanAdvance extends StatefulWidget {
  const LoanAdvance({super.key});

  @override
  State<LoanAdvance> createState() => _LoanAdvanceState();
}

class _LoanAdvanceState extends State<LoanAdvance> {
  final List<Map<String, dynamic>> LoanOptions = [
    {
      'title': 'Salary Advance Request',
      'icon': Icons.attach_money,
      'color': Colors.blue,
      'description': 'Request and track your salary advance',
      'route': () {
        // Navigate to Salary Advance Request Screen
        Get.to(() =>  Salaryadvancerequest());
      },
    },
    {
      'title': 'Loan Balance Tracking',
      'icon': Icons.trending_up,
      'color': Colors.green,
      'description': 'Track your loan balance and payments',
      'route': () {
        // Navigate to Loan Balance Tracking Screen
        Get.to(() => Loanbalancetracking ());
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Loan Advance"),
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
                  itemCount: LoanOptions.length,
                  itemBuilder: (context, index) {
                    final option = LoanOptions[index];
                    return _buildLoanOptionsOptionsOptionsOptionsCard(option);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLoanOptionsOptionsOptionsOptionsCard(Map<String, dynamic> option) {
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colers.dart';
import 'DailyTask_Management/Daily_TAsk_Management.dart';
import 'Document_Letter/Document_Letter_management.dart';
import 'Expense & Reimbursement/Expense_Reimbursement.dart';
import 'Field_Employee/Client_Visit.dart';
import 'Field_Employee/Field_Employee.dart';
import 'Leave/Leave_Managemen.dart';
import 'Loan & Advance/Loan_Advance.dart';
import 'Payslip & Salary/Payslip&Salary_management.dart';
import 'Regularization/Regularization.dart';
import 'Shift & Schedule/Siftt_Schedule.dart';

class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {

  final List<Map<String, dynamic>> allServices = [
    // {'title': 'Leave', 'icon': Icons.calendar_month, 'color': Colors.blue},
    {'title': 'Daily Task & Management', 'icon': Icons.task, 'color': Colors.green},
    // {'title': 'Payroll & Salary', 'icon': Icons.receipt, 'color': Colors.orange},
    // {'title': 'Expense & Reimbursement', 'icon': Icons.receipt_long, 'color': Colors.red},
    // {'title': 'Documents & Letters', 'icon': Icons.description, 'color': Colors.teal},
    {'title': 'Field Employee', 'icon': Icons.person_pin_circle, 'color': Colors.brown},
    // {'title': 'Regularization', 'icon': Icons.update, 'color': Colors.indigo},
    // {'title': 'Loan & Advance', 'icon': Icons.account_balance, 'color': Colors.purple},
    // {'title': 'Shift & Schedule', 'icon': Icons.schedule, 'color': Colors.pink},
  ];

  late List<Map<String, dynamic>> filteredServices;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredServices = allServices;
    searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterServices);
    searchController.dispose();
    super.dispose();
  }

  void _filterServices() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredServices = allServices;
      } else {
        filteredServices = allServices.where((service) {
          return service['title'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        title: const Text("My Work"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Search Container
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Work...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        searchController.clear();
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              // Services Grid
              filteredServices.isEmpty
                  ? Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No services found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemCount: filteredServices.length,
                itemBuilder: (context, index) {
                  final item = filteredServices[index];
                  return Card(
                    elevation: 5,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        if(item['title'] == 'Daily Task & Management'){
                          Get.to(()=>DailyTaskManagement());
                        }else if (item['title'] == 'Field Employee'){
                          Get.to(()=>ClientVisit());

                        // }else if (item['title'] == 'Payroll & Salary'){
                        //   Get.to(()=>Payslip());
                        // } else if (item['title'] == 'Expense & Reimbursement'){
                        //   Get.to(()=>ExpenseReimbursement());
                        // } else if (item['title'] == 'Documents & Letters'){
                        //   Get.to(()=>DocumentLetterManagement());
                        // } else if (item['title'] == 'Field Employee'){
                        //   Get.to(()=>FieldEmployee());
                        // } else if (item['title'] == 'Regularization'){
                        //   Get.to(()=>Regularization());
                        // } else if (item['title'] == 'Loan & Advance'){
                        //   Get.to(()=>LoanAdvance());
                        // } else if (item['title'] == 'Shift & Schedule'){
                        //   Get.to(()=>SifttSchedule());
                        }
                        // Add navigation or functionality here
                        print('${filteredServices[index]['title']} tapped');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: filteredServices[index]['color'].withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                filteredServices[index]['icon'],
                                size: 35,
                                color: filteredServices[index]['color'],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              filteredServices[index]['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
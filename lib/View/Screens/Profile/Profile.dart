import 'package:employee_app/View/Screens/Profile/perfomance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Controller/Employee_profile_data_controller.dart';
import '../../../Controller/Signup_controller.dart';
import '../../../utils/colers.dart';
import 'package:intl/intl.dart';
import '../Login_page.dart';
import '../Service/Document_Letter/Document_Letter_management.dart';
import '../Service/Expense & Reimbursement/Expense_Reimbursement.dart';
import '../Service/Leave/Leave_Managemen.dart';
import '../Service/Loan & Advance/Loan_Advance.dart';
import '../Service/Payslip & Salary/Payslip&Salary_management.dart';
import '../Service/Regularization/Regularization.dart';
import '../Service/Shift & Schedule/Siftt_Schedule.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final LoginController aouthController = Get.put(LoginController());
  final EmployeeprofileData controller = Get.put(EmployeeprofileData());

  // Date format
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  final List<Map<String, dynamic>> allServices = [
    {
      'title': 'Performance ',
      'icon': Icons.assessment,
      'color': Colors.redAccent
    },
    {'title': 'Leave',
      'icon': Icons.calendar_month,
      'color': Colors.blue
    },
    {
      'title': 'Payroll & Salary',
      'icon': Icons.receipt,
      'color': Colors.orange
    },
    {
      'title': 'Expense & Reimbursement',
      'icon': Icons.receipt_long,
      'color': Colors.red
    },
    {
      'title': 'Documents & Letters',
      'icon': Icons.description,
      'color': Colors.teal
    },
    {
      'title': 'Attendance Regularization',
      'icon': Icons.update,
      'color': Colors.indigo
    },
    {
      'title': 'Loan & Advance',
      'icon': Icons.account_balance,
      'color': Colors.purple
    },
    {'title': 'Shift & Schedule',
      'icon': Icons.schedule,
      'color': Colors.pink
    },
  ];

  // EmployeeprofileData controller = EmployeeprofileData();

  @override
  void initState() {
    super.initState();
    getID();
    print("fgdgjdflkkk");
  }

  getID() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String id = sp.getString("user_id") ?? "";

    if (id.isNotEmpty) {
      controller.userId.value = id; // વેલ્યુ અપડેટ કરો
      await controller.fetchEmployeeProfileData(); // ડેટા ફેચ કરો
    }
  }

  void _navigateToService(String title) {
    switch (title) {
      case 'Performance ':
        Get.to(() => const Perfomance());
        break;
      case 'Leave':
        Get.to(() => const Leave());
        break;
      case 'Payroll & Salary':
        Get.to(() => const Payslip());
        break;
      case 'Expense & Reimbursement':
        Get.to(() => const ExpenseReimbursement());
        break;
      case 'Documents & Letters':
        Get.to(() => const DocumentLetterManagement());
        break;
      case 'Attendance Regularization':
        Get.to(() => const Regularization());
        break;
      case 'Loan & Advance':
        Get.to(() => const LoanAdvance());
        break;
      case 'Shift & Schedule':
        Get.to(() => const SifttSchedule());
        break;
      default:
        Get.snackbar(
          'Coming Soon',
          'This feature is under development',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
    }
  }

  void _showProfileDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Divider(color: Colors.grey.shade200, thickness: 1),
              // Content
              Expanded(
                child: Obx(() {
                  var empData = controller.employeeprofiledata.isNotEmpty
                      ? controller.employeeprofiledata[0]
                      : {};
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Personal Information Section
                        _buildDetailSection(
                          title: 'Personal Information',
                          icon: Icons.person_outline,
                          color: Colors.blue,
                          children: [
                            _buildInfoRow('Full Name', controller.username.value , Icons.person),
                            // _buildInfoRow('Date of Birth', _formatDate(empData["dob"]), Icons.cake),
                            // _buildInfoRow('Gender', empData["gender"] ?? "N/A", Icons.wc),
                            // _buildInfoRow('Blood Group', empData["blood_group"] ?? "N/A", Icons.bloodtype),
                            _buildInfoRow('PAN Number', controller.pan.value, Icons.credit_card),
                            _buildInfoRow('Aadhar Number', controller.aadhar.value, Icons.card_membership),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Contact Information Section
                        _buildDetailSection(
                          title: 'Contact Information',
                          icon: Icons.contact_phone_outlined,
                          color: Colors.green,
                          children: [
                            _buildInfoRow('Email',controller.email.value, Icons.email),
                            _buildInfoRow('Mobile', controller.mobile.value, Icons.phone),
                            // _buildInfoRow('Alternate', empData["alternate_phone"] ?? "N/A", Icons.phone_android),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Employment Details Section
                        _buildDetailSection(
                          title: 'Employment Details',
                          icon: Icons.work_outline,
                          color: Colors.orange,
                          children: [
                            _buildInfoRow('Employee ID', controller.employee_code.value , Icons.badge),
                            _buildInfoRow('Designation', controller.designation.value, Icons.work),
                            _buildInfoRow('Department', controller.department.value, Icons.business),
                            _buildInfoRow('Employee Type', controller.employment_type.value, Icons.timelapse_outlined),
                            // _buildInfoRow('Date of Joining', _formatDate(empData["date_of_joining"]), Icons.calendar_today),
                            // _buildInfoRow('UAN Number', empData["uan_number"] ?? "N/A", Icons.numbers),
                            // _buildInfoRow('ESI Number', empData["esi_number"] ?? "N/A", Icons.numbers),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Bank Details Section
                        _buildDetailSection(
                          title: 'Bank Details',
                          icon: Icons.account_balance_outlined,
                          color: Colors.purple,
                          children: [
                            _buildInfoRow('Bank Name', controller.bank_name.value, Icons.account_balance),
                            _buildInfoRow('Account Number', controller.account_no.value, Icons.credit_card),
                            _buildInfoRow('IFSC Code', controller.ifsc.value, Icons.code),
                            // _buildInfoRow('Branch', empData["branch"] ?? "N/A", Icons.location_on),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Bank Details Section
                        _buildDetailSection(
                          title: 'Salary Details',
                          icon: Icons.account_balance_outlined,
                          color: Colors.purple,
                          children: [
                            _buildInfoRow('Total Gross Salary', controller.total_gross_salary.value , Icons.money),
                            _buildInfoRow('Net Salary', controller.net_salary.value, Icons.money),
                            _buildInfoRow('Basic Salary', controller.basic_salary.value, Icons.money),
                            // _buildInfoRow('Branch', empData["branch"] ?? "N/A", Icons.location_on),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Emergency Contact Section
                        _buildDetailSection(
                          title: 'Emergency Contact',
                          icon: Icons.emergency_outlined,
                          color: Colors.red,
                          children: [
                            _buildInfoRow('Name', empData["emergency_name"] ?? "N/A", Icons.person),
                            _buildInfoRow('Relation', empData["emergency_relation"] ?? "N/A", Icons.family_restroom),
                            _buildInfoRow('Contact', empData["emergency_phone"] ?? "N/A", Icons.phone),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Address Section
                        _buildDetailSection(
                          title: 'Address',
                          icon: Icons.location_on_outlined,
                          color: Colors.teal,
                          children: [
                            _buildInfoRow('Current Address', empData["current_address"] ?? "N/A", Icons.home, maxLines: 2),
                            _buildInfoRow('Permanent Address', empData["permanent_address"] ?? "N/A", Icons.home_work, maxLines: 2),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Education & Experience Section
                        _buildDetailSection(
                          title: 'Education & Experience',
                          icon: Icons.school_outlined,
                          color: Colors.indigo,
                          children: [
                            _buildInfoRow('Qualification', empData["qualification"] ?? "N/A", Icons.school),
                            _buildInfoRow('Experience', empData["experience"] ?? "N/A", Icons.timeline),
                            _buildInfoRow('Previous Company', empData["previous_company"] ?? "N/A", Icons.business_center),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(icon, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return "N/A";
    if (dateValue is DateTime) {
      return _dateFormat.format(dateValue);
    }
    if (dateValue is String) {
      try {
        DateTime parsedDate = DateTime.parse(dateValue);
        return _dateFormat.format(parsedDate);
      } catch (e) {
        return dateValue;
      }
    }
    return "N/A";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              aouthController.logout();
            },
            child: Row(
              children: [
                const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Obx(() {
        if(controller.isLoading.value){
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: primary_color,
              size: 80,
            ),);
        }
        else {
          return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Profile Header with Avatar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: _showProfileDetails,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Avatar
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primary_color,
                                  width: 3,
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage(
                                    'assets/images/Employee_logo.png'),
                                backgroundColor: Colors.grey,
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Name and Designation
                        Text(
                          controller.username.value,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: primary_color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                           controller.designation.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: primary_color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Employee ID and Department
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.badge, size: 12,
                                      color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    controller.employee_code.value,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.business, size: 12,
                                      color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    controller.department.value,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // View Details Indicator
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primary_color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Tap to view full details',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick Actions Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Services ListView - Vertical
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allServices.length,
                        itemBuilder: (context, index) {
                          final service = allServices[index];
                          return _buildVerticalServiceCard(service);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
        }
      }),
    );
  }

  Widget _buildVerticalServiceCard(Map<String, dynamic> service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _navigateToService(service['title']);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: service['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  service['icon'],
                  color: service['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: service['color'],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Access your ${service['title'].toLowerCase()} module',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: service['color'],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
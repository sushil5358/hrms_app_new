import 'package:flutter/material.dart';
import '../../../../utils/colers.dart';
import 'package:intl/intl.dart';

class SalaryBreahupview extends StatefulWidget {
  const SalaryBreahupview({super.key});

  @override
  State<SalaryBreahupview> createState() => _SalaryBreahupviewState();
}

class _SalaryBreahupviewState extends State<SalaryBreahupview> {
  // User information
  final String _userName = "Rahul Sharma";
  final String _employeeId = "EMP001";
  final String _designation = "Senior Software Engineer";
  final String _department = "IT Development";
  final String _panNumber = "ABCDE1234F";
  final String _bankAccount = "****1234";
  final String _ifscCode = "HDFC0001234";

  // Selected month and year - make nullable
  int? _selectedYear;
  int? _selectedMonth;

  // Available years - updated to include current and future years
  final List<int> _availableYears = [2026, 2025, 2024, 2023, 2022];

  // Month names
  final List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Salary components
  final Map<String, dynamic> _salaryDetails = {
    'month': 'March 2024',
    'netSalary': 75000.00,
    'grossSalary': 85000.00,
    'totalDeductions': 10000.00,
    'earnings': [
      {'component': 'Basic Salary', 'amount': 35000.00, 'type': 'earning'},
      {'component': 'House Rent Allowance (HRA)', 'amount': 17500.00, 'type': 'earning'},
      {'component': 'Conveyance Allowance', 'amount': 2500.00, 'type': 'earning'},
      {'component': 'Medical Allowance', 'amount': 1250.00, 'type': 'earning'},
      {'component': 'Special Allowance', 'amount': 18750.00, 'type': 'earning'},
      {'component': 'Leave Travel Allowance', 'amount': 5000.00, 'type': 'earning'},
      {'component': 'Performance Bonus', 'amount': 5000.00, 'type': 'earning'},
    ],
    'deductions': [
      {'component': 'Provident Fund (PF)', 'amount': 4200.00, 'type': 'deduction'},
      {'component': 'Professional Tax', 'amount': 200.00, 'type': 'deduction'},
      {'component': 'Income Tax (TDS)', 'amount': 4800.00, 'type': 'deduction'},
      {'component': 'Health Insurance', 'amount': 800.00, 'type': 'deduction'},
    ],
  };

  // Date formatting
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    // Set default values that exist in the lists
    _selectedYear = 2024;
    _selectedMonth = 3; // March
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Salary Breakup View"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(

        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Month Selection
              _buildMonthSelector(),

              // Employee Info Card
              _buildEmployeeInfoCard(),

              // Salary Summary Card
              _buildSalarySummaryCard(),

              // Salary Breakup Tabs
              Container(
                height: 500, // Fixed height for tab section
                margin: const EdgeInsets.only(bottom: 20),
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: primary_color,
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey,
                          tabs: const [
                            Padding(
                              padding: EdgeInsets.only(right: 8.0,left: 8),
                              child: Tab(text: 'Earnings'),
                            ),
                            Padding(
                              padding: EdgeInsets.only( right: 8.0,left: 8),
                              child: Tab(text: 'Deductions'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildEarningsList(),
                            _buildDeductionsList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              value: _selectedMonth,
              items: List.generate(12, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(_monthNames[index]),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value;
                });
              },
              hint: "Select Month",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdown(
              value: _selectedYear,
              items: _availableYears.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value;
                });
              },
              hint: "Select Year",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required dynamic value,
    required List<DropdownMenuItem> items,
    required Function(dynamic) onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          value: value,
          items: items,
          onChanged: onChanged,
          hint: Text(
            hint,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          isExpanded: true,
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmployeeInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade500,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _employeeId,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(Icons.work, 'Designation', _designation),
              ),
              Expanded(
                child: _buildInfoItem(Icons.business, 'Department', _department),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(Icons.credit_card, 'PAN', _panNumber),
              ),
              Expanded(
                child: _buildInfoItem(Icons.account_balance, 'Bank', _bankAccount),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalarySummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Salary Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primary_color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _salaryDetails['month'],
                  style: TextStyle(
                    color: primary_color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                label: 'Gross Salary',
                amount: _salaryDetails['grossSalary'],
                color: Colors.blue,
                icon: Icons.trending_up,
              ),
              _buildSummaryItem(
                label: 'Deductions',
                amount: _salaryDetails['totalDeductions'],
                color: Colors.red,
                icon: Icons.trending_down,
              ),
              _buildSummaryItem(
                label: 'Net Salary',
                amount: _salaryDetails['netSalary'],
                color: Colors.green,
                icon: Icons.account_balance_wallet,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Take Home Salary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _currencyFormat.format(_salaryDetails['netSalary']),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _salaryDetails['earnings'].length,
      itemBuilder: (context, index) {
        final item = _salaryDetails['earnings'][index];
        return _buildSalaryComponentCard(item);
      },
    );
  }

  Widget _buildDeductionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _salaryDetails['deductions'].length,
      itemBuilder: (context, index) {
        final item = _salaryDetails['deductions'][index];
        return _buildSalaryComponentCard(item);
      },
    );
  }

  Widget _buildSalaryComponentCard(Map<String, dynamic> item) {
    bool isEarning = item['type'] == 'earning';
    Color color = isEarning ? Colors.green : Colors.red;
    IconData icon = isEarning ? Icons.add_circle : Icons.remove_circle;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.05),
              Colors.white,
            ],
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
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['component'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEarning ? 'Earning' : 'Deduction',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _currencyFormat.format(item['amount']),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
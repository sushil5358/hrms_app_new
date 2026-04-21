import 'package:flutter/material.dart';
import '../../../../utils/colers.dart';
import 'package:intl/intl.dart';

class DownloadPayslips extends StatefulWidget {
  const DownloadPayslips({super.key});

  @override
  State<DownloadPayslips> createState() => _DownloadPayslipsState();
}

class _DownloadPayslipsState extends State<DownloadPayslips> {
  // User information
  final String _userName = "Rahul Sharma";
  final String _employeeId = "EMP001";
  final String _designation = "Senior Software Engineer";
  final String _department = "IT Development";

  // Selected year and month for filtering
  int? _selectedYear;
  int? _selectedMonth;

  // Available years for dropdown - Updated to include current and future years
  final List<int> _availableYears = [2026, 2025, 2024, 2023, 2022, 2021, 2020];

  // Month names
  final List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Sample payslip data
  final List<Map<String, dynamic>> _payslips = [
    {
      'id': 'PSL001',
      'month': 3,
      'year': 2024,
      'monthName': 'March 2024',
      'netSalary': 75000.00,
      'grossSalary': 85000.00,
      'deductions': 10000.00,
      'downloadDate': DateTime(2024, 3, 1),
      'status': 'Available',
      'pdfUrl': 'payslip_mar_2024.pdf',
    },
    {
      'id': 'PSL002',
      'month': 2,
      'year': 2024,
      'monthName': 'February 2024',
      'netSalary': 75000.00,
      'grossSalary': 85000.00,
      'deductions': 10000.00,
      'downloadDate': DateTime(2024, 2, 1),
      'status': 'Available',
      'pdfUrl': 'payslip_feb_2024.pdf',
    },
    {
      'id': 'PSL003',
      'month': 1,
      'year': 2024,
      'monthName': 'January 2024',
      'netSalary': 72000.00,
      'grossSalary': 82000.00,
      'deductions': 10000.00,
      'downloadDate': DateTime(2024, 1, 1),
      'status': 'Available',
      'pdfUrl': 'payslip_jan_2024.pdf',
    },
    {
      'id': 'PSL004',
      'month': 12,
      'year': 2023,
      'monthName': 'December 2023',
      'netSalary': 72000.00,
      'grossSalary': 82000.00,
      'deductions': 10000.00,
      'downloadDate': DateTime(2023, 12, 1),
      'status': 'Available',
      'pdfUrl': 'payslip_dec_2023.pdf',
    },
    {
      'id': 'PSL005',
      'month': 11,
      'year': 2023,
      'monthName': 'November 2023',
      'netSalary': 72000.00,
      'grossSalary': 82000.00,
      'deductions': 10000.00,
      'downloadDate': DateTime(2023, 11, 1),
      'status': 'Available',
      'pdfUrl': 'payslip_nov_2023.pdf',
    },
    {
      'id': 'PSL006',
      'month': 10,
      'year': 2023,
      'monthName': 'October 2023',
      'netSalary': 68000.00,
      'grossSalary': 78000.00,
      'deductions': 10000.00,
      'downloadDate': DateTime(2023, 10, 1),
      'status': 'Available',
      'pdfUrl': 'payslip_oct_2023.pdf',
    },
    {
      'id': 'PSL007',
      'month': 4,
      'year': 2024,
      'monthName': 'April 2024',
      'netSalary': 0,
      'grossSalary': 0,
      'deductions': 0,
      'downloadDate': null,
      'status': 'Pending',
      'pdfUrl': null,
    },
  ];

  // Get filtered payslips based on selected year and month
  List<Map<String, dynamic>> get _filteredPayslips {
    return _payslips.where((payslip) {
      if (_selectedYear != null && payslip['year'] != _selectedYear) {
        return false;
      }
      if (_selectedMonth != null && payslip['month'] != _selectedMonth) {
        return false;
      }
      return true;
    }).toList();
  }

  // Date formatting
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Download Payslips"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
        ),
        child: Column(
          children: [
            // User Information Card
            _buildUserInfoCard(),

            // Filter Section
            _buildFilterSection(),

            // Payslips List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Available Payslips",
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
                      '${_filteredPayslips.length} found',
                      style: TextStyle(
                        color: primary_color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Payslips List
            Expanded(
              child: _filteredPayslips.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No payslips found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try selecting a different month or year',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredPayslips.length,
                itemBuilder: (context, index) {
                  final payslip = _filteredPayslips[index];
                  return _buildPayslipCard(payslip);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
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

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Filter by Date",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
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
              const SizedBox(width: 12),
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
            ],
          ),
          if (_selectedYear != null || _selectedMonth != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedYear = null;
                        _selectedMonth = null;
                      });
                    },
                    child: const Text("Clear Filters"),
                  ),
                ],
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
        child: DropdownButton(
          value: value,
          items: items,
          onChanged: onChanged,
          hint: Text(hint),
          isExpanded: true,
          // Add this to handle null value properly
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPayslipCard(Map<String, dynamic> payslip) {
    bool isAvailable = payslip['status'] == 'Available';
    Color statusColor = isAvailable ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isAvailable ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: isAvailable ? () => _downloadPayslip(payslip) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: white,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt,
                      color: isAvailable ? Colors.green : Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payslip['monthName'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            payslip['status'],
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAvailable)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.download, color: Colors.green),
                        onPressed: () => _downloadPayslip(payslip),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Salary Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSalaryItem(
                    label: 'Gross',
                    value: _currencyFormat.format(payslip['grossSalary']),
                    color: Colors.blue,
                  ),
                  _buildSalaryItem(
                    label: 'Deductions',
                    value: _currencyFormat.format(payslip['deductions']),
                    color: Colors.red,
                  ),
                  _buildSalaryItem(
                    label: 'Net',
                    value: _currencyFormat.format(payslip['netSalary']),
                    color: Colors.green,
                  ),
                ],
              ),

              if (payslip['downloadDate'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Generated: ${_dateFormat.format(payslip['downloadDate'])}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _downloadPayslip(Map<String, dynamic> payslip) {
    // Simulate download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${payslip['monthName']} payslip...'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'Open',
          textColor: Colors.white,
          onPressed: () {
            // Open downloaded file
          },
        ),
      ),
    );
  }
}
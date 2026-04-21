import 'package:flutter/material.dart';
import '../../../../utils/colers.dart';
import 'package:intl/intl.dart';

// Move enum outside the class - at top level
enum AttendanceStatus { present, absent, halfDay, late }

class CrrentSalaryView extends StatefulWidget {
  const CrrentSalaryView({super.key});

  @override
  State<CrrentSalaryView> createState() => _CrrentSalaryViewState();
}

class _CrrentSalaryViewState extends State<CrrentSalaryView> {
  // Employee basic salary details
  final double _basicSalary = 18000.00;
  final int _totalWorkingDays = 26;

  // Current month days
  int _presentDays = 0;
  int _absentDays = 0;
  int _halfDays = 0;
  int _lateDays = 0;

  // Calculated values
  double _perDaySalary = 0;
  double _salaryForPresentDays = 0;
  double _halfDayDeduction = 0;
  double _lateDeduction = 0;
  double _netSalary = 0;

  // Month selection
  DateTime _selectedMonth = DateTime.now();
  final DateFormat _monthFormat = DateFormat('MMMM yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  // Calendar data
  late List<DateTime> _daysInMonth;
  late Map<DateTime, AttendanceStatus> _attendanceData;

  @override
  void initState() {
    super.initState();
    _calculatePerDaySalary();
    _loadMonthData();
  }

  void _calculatePerDaySalary() {
    _perDaySalary = _basicSalary / _totalWorkingDays;
  }

  void _loadMonthData() {
    _daysInMonth = [];
    _attendanceData = {};

    DateTime firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    DateTime lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    DateTime today = DateTime.now();

    // Generate all days up to today for current month, or all days for past months
    for (int i = 1; i <= lastDay.day; i++) {
      DateTime currentDate = DateTime(_selectedMonth.year, _selectedMonth.month, i);

      // For current month, only show days up to today
      if (_selectedMonth.year == today.year &&
          _selectedMonth.month == today.month &&
          currentDate.isAfter(today)) {
        break;
      }

      _daysInMonth.add(currentDate);

      // Initialize attendance (all present by default)
      _attendanceData[currentDate] = AttendanceStatus.present;
    }

    _calculateAttendanceStats();
  }

  void _calculateAttendanceStats() {
    _presentDays = 0;
    _absentDays = 0;
    _halfDays = 0;
    _lateDays = 0;

    for (var day in _daysInMonth) {
      final status = _attendanceData[day];
      // Add null check
      if (status == null) continue;

      switch (status) {
        case AttendanceStatus.present:
          _presentDays++;
          break;
        case AttendanceStatus.absent:
          _absentDays++;
          break;
        case AttendanceStatus.halfDay:
          _halfDays++;
          break;
        case AttendanceStatus.late:
          _lateDays++;
          break;
      }
    }

    _calculateSalary();
  }

  void _calculateSalary() {
    // Calculate salary for present days
    _salaryForPresentDays = _perDaySalary * _presentDays;

    // Calculate deductions
    _halfDayDeduction = (_perDaySalary / 2) * _halfDays;
    _lateDeduction = (_perDaySalary / 4) * _lateDays;

    // Net salary
    _netSalary = _salaryForPresentDays - _halfDayDeduction - _lateDeduction;

    // Ensure salary is not negative
    if (_netSalary < 0) _netSalary = 0;
  }

  void _toggleAttendanceStatus(DateTime date, AttendanceStatus currentStatus) {
    setState(() {
      // Cycle through statuses
      switch (currentStatus) {
        case AttendanceStatus.present:
          _attendanceData[date] = AttendanceStatus.absent;
          break;
        case AttendanceStatus.absent:
          _attendanceData[date] = AttendanceStatus.halfDay;
          break;
        case AttendanceStatus.halfDay:
          _attendanceData[date] = AttendanceStatus.late;
          break;
        case AttendanceStatus.late:
          _attendanceData[date] = AttendanceStatus.present;
          break;
      }
      _calculateAttendanceStats();
    });
  }

  Future<void> _selectMonth() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2024, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
        _loadMonthData();
      });
    }
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'P';
      case AttendanceStatus.absent:
        return 'A';
      case AttendanceStatus.halfDay:
        return 'H';
      case AttendanceStatus.late:
        return 'L';
    }
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.halfDay:
        return Colors.orange;
      case AttendanceStatus.late:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.halfDay:
        return Icons.warning;
      case AttendanceStatus.late:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Current Salary"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectMonth,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primary_color.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade500],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _monthFormat.format(_selectedMonth),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Live Salary Tracker',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Net Salary Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade700, Colors.green.shade500],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Current Month Salary',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currencyFormat.format(_netSalary),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Based on $_presentDays days worked',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Attendance Summary Card
              Container(
                padding: const EdgeInsets.all(16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Attendance Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAttendanceItem(
                          label: 'Present',
                          value: '$_presentDays',
                          color: Colors.green,
                          icon: Icons.check_circle,
                          subValue: 'days',
                        ),
                        _buildAttendanceItem(
                          label: 'Absent',
                          value: '$_absentDays',
                          color: Colors.red,
                          icon: Icons.cancel,
                          subValue: 'days',
                        ),
                        _buildAttendanceItem(
                          label: 'Half Day',
                          value: '$_halfDays',
                          color: Colors.orange,
                          icon: Icons.warning,
                          subValue: 'days',
                        ),
                        _buildAttendanceItem(
                          label: 'Late',
                          value: '$_lateDays',
                          color: Colors.purple,
                          icon: Icons.access_time,
                          subValue: 'days',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Calendar View
              Container(
                padding: const EdgeInsets.all(16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calendar_view_month, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Day by Day Attendance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Weekday headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text('S', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('M', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('T', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('W', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('T', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('F', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('S', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Calendar days
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _daysInMonth.length,
                      itemBuilder: (context, index) {
                        final day = _daysInMonth[index];
                        final status = _attendanceData[day] ?? AttendanceStatus.present;
                        final isToday = day.year == DateTime.now().year &&
                            day.month == DateTime.now().month &&
                            day.day == DateTime.now().day;

                        return GestureDetector(
                          onTap: () {
                            // Allow editing only for current month
                            if (_selectedMonth.year == DateTime.now().year &&
                                _selectedMonth.month == DateTime.now().month) {
                              _toggleAttendanceStatus(day, status);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: isToday ? Border.all(color: primary_color, width: 2) : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                    color: isToday ? primary_color : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  _getStatusIcon(status),
                                  size: 16,
                                  color: _getStatusColor(status),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Legend
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _buildLegendItem('Present', Colors.green),
                        _buildLegendItem('Absent', Colors.red),
                        _buildLegendItem('Half Day', Colors.orange),
                        _buildLegendItem('Late', Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Salary Calculation Card
              Container(
                padding: const EdgeInsets.all(16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calculate, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Salary Calculation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    _buildCalculationRow('Basic Monthly Salary', _currencyFormat.format(_basicSalary)),
                    _buildCalculationRow('Total Working Days', '$_totalWorkingDays days'),
                    _buildCalculationRow('Per Day Salary', _currencyFormat.format(_perDaySalary)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildCalculationRow(
                            'Salary for $_presentDays Days',
                            _currencyFormat.format(_salaryForPresentDays),
                            isBold: true,
                            color: Colors.green,
                          ),
                          if (_halfDays > 0)
                            _buildCalculationRow(
                              'Less: Half Day Deduction ($_halfDays days)',
                              '- ${_currencyFormat.format(_halfDayDeduction)}',
                              color: Colors.orange,
                            ),
                          if (_lateDays > 0)
                            _buildCalculationRow(
                              'Less: Late Deduction ($_lateDays days)',
                              '- ${_currencyFormat.format(_lateDeduction)}',
                              color: Colors.purple,
                            ),
                          const Divider(),
                          _buildCalculationRow(
                            'Net Salary',
                            _currencyFormat.format(_netSalary),
                            isBold: true,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    required String subValue,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          subValue,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildCalculationRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? (isBold ? Colors.green.shade700 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
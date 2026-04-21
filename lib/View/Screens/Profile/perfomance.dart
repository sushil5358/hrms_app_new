import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../utils/colers.dart';
import 'package:intl/intl.dart';

class Perfomance extends StatefulWidget {
  const Perfomance({super.key});

  @override
  State<Perfomance> createState() => _PerfomanceState();
}

class _PerfomanceState extends State<Perfomance> {
  // Filter variables
  String _selectedFilter = 'Month'; // Default filter
  final List<String> _filterOptions = ['Day', 'Week', 'Month'];

  // Dashboard data for different time periods
  final Map<String, dynamic> _attendanceData = {
    'day': {
      'arrivalTime': '9:41 AM',
      'timeAtWork': '8h 41m',
      'totalWorkDays': 1,
    },
    'week': {
      'arrivalTime': '9:45 AM',
      'timeAtWork': '42h 30m',
      'totalWorkDays': 5,
    },
    'month': {
      'arrivalTime': '9:41 AM',
      'timeAtWork': '8h 41m',
      'totalWorkDays': 21,
    },
  };

  final Map<String, dynamic> _leavesData = {
    'day': {
      'leavesTaken': 0,
      'leavesRemaining': 12,
      'sickLeaves': 0,
    },
    'week': {
      'leavesTaken': 1,
      'leavesRemaining': 11,
      'sickLeaves': 0,
    },
    'month': {
      'leavesTaken': 2,
      'leavesRemaining': 10,
      'sickLeaves': 1,
    },
  };

  final Map<String, dynamic> _performanceData = {
    'day': {
      'overdueTasks': 1,
      'efficiencyScore': 85.5,
      'teamRank': 2,
      'teamSize': 15,
    },
    'week': {
      'overdueTasks': 2,
      'efficiencyScore': 78.3,
      'teamRank': 3,
      'teamSize': 15,
    },
    'month': {
      'overdueTasks': 3,
      'efficiencyScore': 6.6,
      'teamRank': 1,
      'teamSize': 15,
    },
  };

  final Map<String, dynamic> _productivityData = {
    'day': {
      'productivity': 92.5,
      'avgBreakTime': 1.2,
      'monthlyBreakTime': 1.2,
    },
    'week': {
      'productivity': 84.3,
      'avgBreakTime': 1.4,
      'monthlyBreakTime': 7.0,
    },
    'month': {
      'productivity': 77.06,
      'avgBreakTime': 1.5,
      'monthlyBreakTime': 42,
    },
  };

  // Date format
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  // Get current data based on selected filter
  Map<String, dynamic> get _currentAttendance => _attendanceData[_selectedFilter.toLowerCase()];
  Map<String, dynamic> get _currentLeaves => _leavesData[_selectedFilter.toLowerCase()];
  Map<String, dynamic> get _currentPerformance => _performanceData[_selectedFilter.toLowerCase()];
  Map<String, dynamic> get _currentProductivity => _productivityData[_selectedFilter.toLowerCase()];

  String _getPeriodLabel() {
    switch (_selectedFilter) {
      case 'Day':
        return 'Today';
      case 'Week':
        return 'This Week';
      case 'Month':
        return 'This Month';
      default:
        return '';
    }
  }

  String slidingfilter = "Day";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Performance Dashboard"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
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
            children: [
              // Header with Filter
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Track your attendance, leaves, and productivity metrics',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter Chips
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: _filterOptions.map((filter) {
                                bool isSelected = _selectedFilter == filter;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedFilter = filter;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(23),
                                      ),
                                      child: Center(
                                        child: Text(
                                          filter,
                                          style: TextStyle(
                                            color: isSelected ? Colors.blue.shade700 : Colors.white,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: CupertinoSlidingSegmentedControl(
                    //         proportionalWidth: false,
                    //         padding: EdgeInsetsGeometry.all(8),
                    //           backgroundColor: Colors.white30,
                    //         groupValue: slidingfilter,
                    //         children: {"Day" :Text("Day"),"Week":Text("Week"),"Month":Text("Month")},
                    //         onValueChanged: (value) {
                    //       setState(() {
                    //         slidingfilter = value!;
                    //       });
                    //       },),
                    //     ),
                    //   ],
                    // ),

                    // Period Indicator
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _selectedFilter == 'Day' ? Icons.today :
                            _selectedFilter == 'Week' ? Icons.date_range :
                            Icons.calendar_month,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getPeriodLabel(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Attendance & Time Card
              _buildDashboardCard(
                title: 'Attendance & Time',
                icon: Icons.access_time,
                iconColor: Colors.blue,
                period: _getPeriodLabel(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(
                      icon: Icons.login,
                      label: 'Arrival Time',
                      value: _currentAttendance['arrivalTime'],
                      color: Colors.green,
                    ),
                    _buildMetricItem(
                      icon: Icons.timer,
                      label: 'Time at Work',
                      value: _currentAttendance['timeAtWork'],
                      color: Colors.orange,
                    ),
                    _buildMetricItem(
                      icon: Icons.calendar_today,
                      label: 'Work Days',
                      value: '${_currentAttendance['totalWorkDays']}',
                      subValue: _getPeriodLabel(),
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Leaves & Time Off Card
              _buildDashboardCard(
                title: 'Leaves & Time Off',
                icon: Icons.beach_access,
                iconColor: Colors.green,
                period: _getPeriodLabel(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(
                      icon: Icons.event_busy,
                      label: 'Leaves Taken',
                      value: '${_currentLeaves['leavesTaken']}',
                      subValue: _getPeriodLabel(),
                      color: Colors.red,
                    ),
                    _buildMetricItem(
                      icon: Icons.event_available,
                      label: 'Leaves Remaining',
                      value: '${_currentLeaves['leavesRemaining']}',
                      subValue: 'Annual Balance',
                      color: Colors.green,
                    ),
                    _buildMetricItem(
                      icon: Icons.local_hospital,
                      label: 'Sick Leaves',
                      value: '${_currentLeaves['sickLeaves']}',
                      subValue: _getPeriodLabel(),
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Performance Metrics Card
              _buildDashboardCard(
                title: 'Performance Metrics',
                icon: Icons.assessment,
                iconColor: Colors.purple,
                period: _getPeriodLabel(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(
                      icon: Icons.warning,
                      label: 'Overdue Tasks',
                      value: '${_currentPerformance['overdueTasks']}',
                      subValue: 'Currently Pending',
                      color: Colors.red,
                    ),
                    _buildMetricItem(
                      icon: Icons.speed,
                      label: 'Efficiency Score',
                      value: '${_currentPerformance['efficiencyScore']}%',
                      subValue: _getPeriodLabel(),
                      color: Colors.blue,
                    ),
                    _buildMetricItem(
                      icon: Icons.emoji_events,
                      label: 'Team Rank',
                      value: _getRankString(_currentPerformance['teamRank']),
                      subValue: 'Out of ${_currentPerformance['teamSize']} members',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Productivity & Break Time Card
              _buildDashboardCard(
                title: 'Productivity & Break Time',
                icon: Icons.trending_up,
                iconColor: Colors.teal,
                period: _getPeriodLabel(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(
                      icon: Icons.pie_chart,
                      label: 'Productivity',
                      value: '${_currentProductivity['productivity']}%',
                      subValue: 'Completion Rate',
                      color: Colors.green,
                    ),
                    _buildMetricItem(
                      icon: Icons.free_breakfast,
                      label: 'Avg. Break Time',
                      value: '${_currentProductivity['avgBreakTime']}h',
                      subValue: 'Daily Average',
                      color: Colors.orange,
                    ),
                    _buildMetricItem(
                      icon: Icons.coffee,
                      label: 'Total Break',
                      value: '${_currentProductivity['monthlyBreakTime']}${_selectedFilter == 'Month' ? 'h' : 'h'}',
                      subValue: _getPeriodLabel(),
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Summary Card
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Performance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSummaryMessage(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getSummaryIcon(),
                        color: Colors.white,
                        size: 30,
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

  String _getRankString(int rank) {
    if (rank == 1) return '1st';
    if (rank == 2) return '2nd';
    if (rank == 3) return '3rd';
    return '${rank}th';
  }

  IconData _getSummaryIcon() {
    double productivity = _currentProductivity['productivity'];
    if (productivity >= 80) return Icons.thumb_up;
    if (productivity >= 60) return Icons.trending_up;
    return Icons.trending_down;
  }

  String _getSummaryMessage() {
    double productivity = _currentProductivity['productivity'];
    if (productivity >= 80) {
      return 'Excellent performance! Keep it up!';
    } else if (productivity >= 60) {
      return 'Good progress. Room for improvement.';
    } else {
      return 'Need to improve productivity.';
    }
  }

  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String period,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 11,
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          child,
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
    required Color color,
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
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          if (subValue != null)
            Text(
              subValue,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
    );
  }
}
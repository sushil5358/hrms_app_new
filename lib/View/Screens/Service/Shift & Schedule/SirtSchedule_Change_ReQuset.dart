import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Controller/Sgift_schedule_Change_Request_controller.dart';
import '../../../../utils/colers.dart';

class SirtscheduleChangeRequset extends StatefulWidget {
  const SirtscheduleChangeRequset({super.key});

  @override
  State<SirtscheduleChangeRequset> createState() => _SirtscheduleChangeRequsetState();
}

class _SirtscheduleChangeRequsetState extends State<SirtscheduleChangeRequset> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  ShiftscheduleController controller = ShiftscheduleController();

  // Sample shift data
  final List<Map<String, dynamic>> currentSchedule = [
    {
      'date': '2024-03-01',
      'day': 'Monday',
      'shiftType': 'Morning',
      'shiftTime': '06:00 AM - 02:00 PM',
      'status': 'Completed',
      'color': Colors.green,
    },
    {
      'date': '2024-03-02',
      'day': 'Tuesday',
      'shiftType': 'Morning',
      'shiftTime': '06:00 AM - 02:00 PM',
      'status': 'Completed',
      'color': Colors.green,
    },
    {
      'date': '2024-03-03',
      'day': 'Wednesday',
      'shiftType': 'Morning',
      'shiftTime': '06:00 AM - 02:00 PM',
      'status': 'Completed',
      'color': Colors.green,
    },
    {
      'date': '2024-03-04',
      'day': 'Thursday',
      'shiftType': 'Afternoon',
      'shiftTime': '02:00 PM - 10:00 PM',
      'status': 'Ongoing',
      'color': Colors.orange,
    },
    {
      'date': '2024-03-05',
      'day': 'Friday',
      'shiftType': 'Afternoon',
      'shiftTime': '02:00 PM - 10:00 PM',
      'status': 'Upcoming',
      'color': Colors.blue,
    },
    {
      'date': '2024-03-06',
      'day': 'Saturday',
      'shiftType': 'Night',
      'shiftTime': '10:00 PM - 06:00 AM',
      'status': 'Upcoming',
      'color': Colors.purple,
    },
    {
      'date': '2024-03-07',
      'day': 'Sunday',
      'shiftType': 'Off',
      'shiftTime': 'Weekly Off',
      'status': 'Holiday',
      'color': Colors.red,
    },
  ];

  final List<Map<String, dynamic>> changeRequests = [
    {
      'id': 'REQ001',
      'date': '2024-03-10',
      'currentShift': 'Morning (06:00 - 14:00)',
      'requestedShift': 'Afternoon (14:00 - 22:00)',
      'reason': 'Personal work',
      'status': 'Pending',
      'requestDate': '2024-03-01',
      'color': Colors.orange,
    },
    {
      'id': 'REQ002',
      'date': '2024-03-15',
      'currentShift': 'Afternoon (14:00 - 22:00)',
      'requestedShift': 'Morning (06:00 - 14:00)',
      'reason': 'Medical appointment',
      'status': 'Approved',
      'requestDate': '2024-03-02',
      'color': Colors.green,
    },
    {
      'id': 'REQ003',
      'date': '2024-03-20',
      'currentShift': 'Night (22:00 - 06:00)',
      'requestedShift': 'Morning (06:00 - 14:00)',
      'reason': 'Family function',
      'status': 'Rejected',
      'requestDate': '2024-03-03',
      'color': Colors.red,
    },
  ];

  final List<Map<String, dynamic>> availableShifts = [
    {
      'type': 'Morning Shift',
      'time': '06:00 AM - 02:00 PM',
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
    },
    {
      'type': 'Afternoon Shift',
      'time': '02:00 PM - 10:00 PM',
      'icon': Icons.wb_twilight,
      'color': Colors.amber,
    },
    {
      'type': 'Night Shift',
      'time': '10:00 PM - 06:00 AM',
      'icon': Icons.nightlight_round,
      'color': Colors.indigo,
    },
    {
      'type': 'General Shift',
      'time': '09:00 AM - 06:00 PM',
      'icon': Icons.access_time,
      'color': Colors.teal,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    controller.SiftSchecduleChangetype();
    getID();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  getID() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    controller.userId = await sp.getString("user_id") ?? "";
    print("user id ===> ${controller.userId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shift Schedule & Change Request"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Schedule', icon: Icon(Icons.calendar_month)),
            Tab(text: 'Requests', icon: Icon(Icons.pending_actions)),
            Tab(text: 'New Request', icon: Icon(Icons.add_circle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScheduleTab(),
          _buildRequestsTab(),
          _buildNewRequestTab(),
        ],
      ),

    );
  }

  // Schedule Tab
  Widget _buildScheduleTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          // Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary_color, primary_color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primary_color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('This Week', '5', 'Working Days'),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildSummaryItem('Next Shift', 'Afternoon', '02:00 PM'),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildSummaryItem('Total Hours', '40', 'This Week'),
              ],
            ),
          ),

          // Schedule List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: currentSchedule.length,
              itemBuilder: (context, index) {
                final schedule = currentSchedule[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: schedule['color'].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          schedule['day'][0],
                          style: TextStyle(
                            color: schedule['color'],
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      schedule['day'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${schedule['shiftType']} Shift',
                          style: TextStyle(
                            color: schedule['color'],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          schedule['shiftTime'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: schedule['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        schedule['status'],
                        style: TextStyle(
                          color: schedule['color'],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Requests Tab
  Widget _buildRequestsTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          // Request Stats
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRequestStat('Pending', '1', Colors.orange),
                _buildRequestStat('Approved', '1', Colors.green),
                _buildRequestStat('Rejected', '1', Colors.red),
              ],
            ),
          ),

          // Requests List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: changeRequests.length,
              itemBuilder: (context, index) {
                final request = changeRequests[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
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
                          Text(
                            'Request #${request['id']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: request['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              request['status'],
                              style: TextStyle(
                                color: request['color'],
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: ${_formatDate(request['date'])}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Current: ${request['currentShift']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Requested: ${request['requestedShift']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: primary_color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.note,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                request['reason'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Requested on: ${_formatDate(request['requestDate'])}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // New Request Tab
  Widget _buildNewRequestTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Shifts
            const Text(
              'Available Shifts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // // Shift Options
            // ...availableShifts.map((shift) => _buildShiftOption(shift)).toList(),-
            Obx(() {
              return DropdownButtonFormField<String>(
                value: controller.SelectedSift,
                decoration: InputDecoration(
                  hintText: "Choose Sift type",
                  prefixIcon: const Icon(Icons.access_time_filled),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: controller.sifttype.map((e) {
                  return DropdownMenuItem<String>(
                    child: Text(e["add_shift"],),
                    value: e["add_shift"],
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    controller.SelectedSift = value!;
                    print("=========>SelectedSift ${controller.SelectedSift}");
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select SelectedSift type';
                  }
                  return null;
                },
              );
            }),

            const SizedBox(height: 24),

            // Request Form
            const Text(
              'Request Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Date Selection
            Obx(() {
              return TextFormField(
                controller: TextEditingController(text: controller.DateText),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await selectDate();
                  if (pickedDate != null) {
                    controller.date.value = pickedDate;
                  }
                },
                decoration: _buildInputDecoration(
                    "Select date", Icons.calendar_today,
                    suffixIcon: Icons.arrow_drop_down),
              );
            }),
            const SizedBox(height: 12),

            // Reason Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller.reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason for change',
                  hintText: 'Enter your reason here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Additional Notes
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller.additionalnoteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  hintText: 'Any additional information...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (){
                  controller.ShiftScheduleChangeRequest(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary_color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  'Submit Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _selectedShift;
  String? _selectedDate;

  Widget _buildShiftOption(Map<String, dynamic> shift) {
    bool isSelected = _selectedShift == shift['type'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedShift = shift['type'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? shift['color'].withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? shift['color'] : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: shift['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                shift['icon'],
                color: shift['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shift['type'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shift['time'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: shift['color'],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String subtext) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtext,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<DateTime?> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primary_color,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;


    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon,
      {IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey.shade500),
      suffixIcon: suffixIcon != null ? Icon(
          suffixIcon, color: Colors.grey.shade500) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primary_color, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  void _submitRequest() {
    if (_selectedShift == null) {
      _showErrorSnackBar('Please select a shift');
      return;
    }
    if (_selectedDate == null) {
      _showErrorSnackBar('Please select a date');
      return;
    }

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Your shift change request has been submitted successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _tabController.animateTo(1); // Go to requests tab
            },
            style: TextButton.styleFrom(
              foregroundColor: primary_color,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
import 'package:flutter/material.dart';
import '../../../../utils/colers.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class RequestAttendanceCorrection extends StatefulWidget {
  const RequestAttendanceCorrection({super.key});

  @override
  State<RequestAttendanceCorrection> createState() => _RequestAttendanceCorrectionState();
}

class _RequestAttendanceCorrectionState extends State<RequestAttendanceCorrection> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // User information
  final String _userName = "Rahul Sharma";
  final String _employeeId = "EMP001";
  final String _department = "IT Development";

  // Request type selection
  String? _selectedRequestType;
  final List<String> _requestTypes = ['Missed Punch', 'Wrong Timing', 'Wrong Date', 'Others'];

  // Form controllers
  final _dateController = TextEditingController();
  final _checkInTimeController = TextEditingController();
  final _checkOutTimeController = TextEditingController();
  final _correctCheckInController = TextEditingController();
  final _correctCheckOutController = TextEditingController();
  final _reasonController = TextEditingController();
  final _commentsController = TextEditingController();

  // Date and time
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedCheckIn;
  TimeOfDay? _selectedCheckOut;
  TimeOfDay? _selectedCorrectCheckIn;
  TimeOfDay? _selectedCorrectCheckOut;

  // File attachments
  List<Map<String, dynamic>> _attachedFiles = [];
  bool _isUploading = false;

  // Sample request history
  final List<Map<String, dynamic>> _requestHistory = [
    {
      'id': 'REQ001',
      'type': 'Missed Punch',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Approved',
      'statusColor': Colors.green,
      'reason': 'Forgot to check-in',
      'attachments': 1,
    },
    {
      'id': 'REQ002',
      'type': 'Wrong Timing',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'status': 'Pending',
      'statusColor': Colors.orange,
      'reason': 'System error',
      'attachments': 0,
    },
    {
      'id': 'REQ003',
      'type': 'Wrong Date',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'status': 'Rejected',
      'statusColor': Colors.red,
      'reason': 'Invalid request',
      'attachments': 2,
    },
    {
      'id': 'REQ004',
      'type': 'Missed Punch',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'status': 'Approved',
      'statusColor': Colors.green,
      'reason': 'Technical issue',
      'attachments': 1,
    },
  ];

  // Date format
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _timeFormat = DateFormat('hh:mm a');
  final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _dateController.text = _dateFormat.format(DateTime.now());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dateController.dispose();
    _checkInTimeController.dispose();
    _checkOutTimeController.dispose();
    _correctCheckInController.dispose();
    _correctCheckOutController.dispose();
    _reasonController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
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

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller, TimeOfDay? selectedTime, Function(TimeOfDay) onSelected) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      onSelected(picked);
      controller.text = picked.format(context);
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          _isUploading = true;
        });

        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          for (var file in result.files) {
            _attachedFiles.add({
              'name': file.name,
              'size': file.size,
              'path': file.path,
              'extension': file.extension,
            });
          }
          _isUploading = false;
        });

        _showSnackBar('${result.files.length} file(s) attached', Colors.green);
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _submitRequest() {
    if (_selectedRequestType == null) {
      _showSnackBar('Please select request type', Colors.orange);
      return;
    }

    if (_reasonController.text.isEmpty) {
      _showSnackBar('Please provide a reason', Colors.orange);
      return;
    }

    _showSnackBar('Attendance correction request submitted', Colors.green);

    // Clear form
    setState(() {
      _selectedRequestType = null;
      _checkInTimeController.clear();
      _checkOutTimeController.clear();
      _correctCheckInController.clear();
      _correctCheckOutController.clear();
      _reasonController.clear();
      _commentsController.clear();
      _attachedFiles.clear();
      _selectedCheckIn = null;
      _selectedCheckOut = null;
      _selectedCorrectCheckIn = null;
      _selectedCorrectCheckOut = null;
      _selectedDate = DateTime.now();
      _dateController.text = _dateFormat.format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Correction"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: "New Request", icon: Icon(Icons.add_circle)),
            Tab(text: "History", icon: Icon(Icons.history)),
          ],
          indicatorColor: Colors.white,
          indicatorWeight: 3,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(

        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildNewRequestTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  // Tab 1: New Request
  Widget _buildNewRequestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Information Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue,
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
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.business, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _department,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Request Form
          Card(
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Correction Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Request Type Selection
                  _buildLabel("Request Type *", Icons.category),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _requestTypes.map((type) {
                      return ChoiceChip(
                        label: Text(type),
                        selected: _selectedRequestType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedRequestType = type;
                          });
                        },
                        selectedColor: Colors.blue.withOpacity(0.2),
                        backgroundColor: Colors.grey.shade100,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Date Selection
                  _buildLabel("Date *", Icons.calendar_today),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade500),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _dateController.text,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Original Timings (if available)
                  if (_selectedRequestType == 'Wrong Timing') ...[
                    _buildLabel("Original Timings", Icons.access_time),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(
                              _checkInTimeController,
                              _selectedCheckIn,
                                  (time) => _selectedCheckIn = time,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.login, size: 16, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _checkInTimeController.text.isEmpty
                                          ? "Check In"
                                          : _checkInTimeController.text,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _checkInTimeController.text.isEmpty
                                            ? Colors.grey.shade500
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(
                              _checkOutTimeController,
                              _selectedCheckOut,
                                  (time) => _selectedCheckOut = time,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.logout, size: 16, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _checkOutTimeController.text.isEmpty
                                          ? "Check Out"
                                          : _checkOutTimeController.text,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _checkOutTimeController.text.isEmpty
                                            ? Colors.grey.shade500
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Correct Timings
                  _buildLabel("Correct Timings", Icons.access_time),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(
                            _correctCheckInController,
                            _selectedCorrectCheckIn,
                                (time) => _selectedCorrectCheckIn = time,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.login, size: 16, color: Colors.green.shade500),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _correctCheckInController.text.isEmpty
                                        ? "Correct Check In"
                                        : _correctCheckInController.text,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _correctCheckInController.text.isEmpty
                                          ? Colors.grey.shade500
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(
                            _correctCheckOutController,
                            _selectedCorrectCheckOut,
                                (time) => _selectedCorrectCheckOut = time,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.logout, size: 16, color: Colors.green.shade500),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _correctCheckOutController.text.isEmpty
                                        ? "Correct Check Out"
                                        : _correctCheckOutController.text,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _correctCheckOutController.text.isEmpty
                                          ? Colors.grey.shade500
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Reason
                  _buildLabel("Reason *", Icons.account_circle_outlined),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Explain why correction is needed",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Attachment Section
                  _buildLabel("Supporting Documents", Icons.attach_file),
                  const SizedBox(height: 8),
                  _buildFileAttachmentSection(),

                  const SizedBox(height: 16),

                  // Additional Comments
                  _buildLabel("Additional Comments", Icons.comment),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _commentsController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Any additional information",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Submit Request",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 2: History
  Widget _buildHistoryTab() {
    return Column(
      children: [
        // Filter Chips
        Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', true),
                _buildFilterChip('Pending', false),
                _buildFilterChip('Approved', false),
                _buildFilterChip('Rejected', false),
              ],
            ),
          ),
        ),

        Expanded(
          child: _requestHistory.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No correction requests found',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _requestHistory.length,
            itemBuilder: (context, index) {
              final request = _requestHistory[index];
              return _buildRequestHistoryCard(request);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {},
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildRequestHistoryCard(Map<String, dynamic> request) {
    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: request['statusColor'].withOpacity(0.3)),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: request['statusColor'].withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            request['type'] == 'Missed Punch' ? Icons.fingerprint : Icons.access_time,
            color: request['statusColor'],
          ),
        ),
        title: Text(
          request['type'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${request['id']}'),
            Text(
              _dateFormat.format(request['date']),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: request['statusColor'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: request['statusColor']),
          ),
          child: Text(
            request['status'],
            style: TextStyle(
              color: request['statusColor'],
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHistoryDetailRow(Icons.account_circle_outlined, 'Reason', request['reason']),
                _buildHistoryDetailRow(Icons.attach_file, 'Attachments', '${request['attachments']} files'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _showSnackBar('View details', Colors.blue);
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // Common Widgets
  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: primary_color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildFileAttachmentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          if (_attachedFiles.isEmpty)
            InkWell(
              onTap: _pickFiles,
              child: Column(
                children: [
                  Icon(Icons.cloud_upload, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text("Tap to upload documents", style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text("PDF, DOC, JPG, PNG", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                ],
              ),
            ),
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  LinearProgressIndicator(),
                  SizedBox(height: 8),
                  Text("Uploading..."),
                ],
              ),
            ),
          if (_attachedFiles.isNotEmpty)
            Column(
              children: [
                ..._attachedFiles.asMap().entries.map((entry) {
                  return ListTile(
                    leading: Icon(
                      _getFileIcon(entry.value['name']),
                      color: _getFileColor(entry.value['name']),
                    ),
                    title: Text(entry.value['name'], maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(_formatFileSize(entry.value['size'])),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => _removeFile(entry.key),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.add),
                  label: const Text("Add More"),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
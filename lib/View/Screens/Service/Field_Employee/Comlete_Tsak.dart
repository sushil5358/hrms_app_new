import 'package:flutter/material.dart';
import '../../../../utils/colers.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ComleteTsak extends StatefulWidget {
  const ComleteTsak({super.key});

  @override
  State<ComleteTsak> createState() => _ComleteTsakState();
}

class _ComleteTsakState extends State<ComleteTsak> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // Form controllers
  final _taskTitleController = TextEditingController();
  final _taskDescriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _challengesController = TextEditingController();
  final _learningsController = TextEditingController();

  // Date and time
  DateTime _taskDate = DateTime.now();
  TimeOfDay _taskTime = TimeOfDay.now();

  // File attachments
  List<Map<String, dynamic>> _taskPhotos = [];
  List<Map<String, dynamic>> _taskDocuments = [];
  bool _isUploading = false;

  // Task categories
  String? _selectedCategory;
  final List<String> _taskCategories = [
    'Site Visit',
    'Installation',
    'Maintenance',
    'Repair',
    'Inspection',
    'Delivery',
    'Training',
    'Consultation',
    'Other',
  ];

  // Task priority
  String? _selectedPriority;
  final List<String> _taskPriorities = ['Low', 'Medium', 'High', 'Urgent'];

  // Sample completed tasks
  final List<Map<String, dynamic>> _completedTasks = [
    {
      'id': 'TSK001',
      'title': 'AC Installation at Client Site',
      'category': 'Installation',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'Completed',
      'statusColor': Colors.green,
      'photos': 3,
      'documents': 1,
      'location': 'ABC Corporation, Andheri East',
    },
    {
      'id': 'TSK002',
      'title': 'Machine Maintenance',
      'category': 'Maintenance',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Completed',
      'statusColor': Colors.green,
      'photos': 5,
      'documents': 0,
      'location': 'XYZ Industries, Powai',
    },
    {
      'id': 'TSK003',
      'title': 'Equipment Repair',
      'category': 'Repair',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'Pending Approval',
      'statusColor': Colors.orange,
      'photos': 2,
      'documents': 2,
      'location': 'Tech Park, Vikhroli',
    },
    {
      'id': 'TSK004',
      'title': 'Site Inspection',
      'category': 'Inspection',
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'status': 'Rejected',
      'statusColor': Colors.red,
      'photos': 4,
      'documents': 1,
      'location': 'New Project Site, Goregaon',
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _challengesController.dispose();
    _learningsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _taskDate,
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
        _taskDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _taskTime,
    );

    if (picked != null) {
      setState(() {
        _taskTime = picked;
      });
    }
  }

  Future<void> _pickFiles(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: type == 'photos'
            ? ['jpg', 'jpeg', 'png']
            : ['pdf', 'doc', 'docx', 'txt'],
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
            Map<String, dynamic> fileData = {
              'name': file.name,
              'size': file.size,
              'path': file.path,
              'extension': file.extension,
              'type': type,
            };
            if (type == 'photos') {
              _taskPhotos.add(fileData);
            } else {
              _taskDocuments.add(fileData);
            }
          }
          _isUploading = false;
        });

        _showSnackBar('${result.files.length} file(s) uploaded', Colors.green);
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  void _removeFile(String type, int index) {
    setState(() {
      if (type == 'photos') {
        _taskPhotos.removeAt(index);
      } else {
        _taskDocuments.removeAt(index);
      }
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

  void _submitTaskReport() {
    if (_taskTitleController.text.isNotEmpty &&
        _taskDescriptionController.text.isNotEmpty &&
        _selectedCategory != null) {

      if (_taskPhotos.isEmpty) {
        _showSnackBar('Please upload at least one photo', Colors.orange);
        return;
      }

      _showSnackBar('Task report submitted successfully', Colors.green);

      // Clear form
      _taskTitleController.clear();
      _taskDescriptionController.clear();
      _locationController.clear();
      _notesController.clear();
      _challengesController.clear();
      _learningsController.clear();
      _taskPhotos.clear();
      _taskDocuments.clear();
      setState(() {
        _selectedCategory = null;
        _selectedPriority = null;
        _taskDate = DateTime.now();
        _taskTime = TimeOfDay.now();
      });
    } else {
      _showSnackBar('Please fill required fields', Colors.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Task Report"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: "Upload Report", icon: Icon(Icons.upload_file)),
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
            _buildUploadReportTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  // Tab 1: Upload Report
  Widget _buildUploadReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade500],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.task_alt, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Task Completion Report",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Upload details and photos of completed tasks",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Report Form
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
                    "Task Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Task Title
                  _buildLabel("Task Title *", Icons.title),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _taskTitleController,
                    decoration: _buildInputDecoration("Enter task title", Icons.title),
                  ),

                  const SizedBox(height: 16),

                  // Category and Priority
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Category *", Icons.category),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: _buildInputDecoration("Select", Icons.category),
                              items: _taskCategories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),


                    ],
                  ),

                  const SizedBox(height: 16),

                  // Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Date *", Icons.calendar_today),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade500),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _dateFormat.format(_taskDate),
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Time", Icons.access_time),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _taskTime.format(context),
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Location
                  _buildLabel("Location", Icons.location_on),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _locationController,
                    decoration: _buildInputDecoration("Where was the task completed", Icons.location_on),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  _buildLabel("Task Description *", Icons.description),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _taskDescriptionController,
                    maxLines: 3,
                    decoration: _buildInputDecoration("Describe what was done", Icons.description),
                  ),

                  const SizedBox(height: 16),

                  // Challenges Faced
                  _buildLabel("Challenges Faced", Icons.warning),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _challengesController,
                    maxLines: 2,
                    decoration: _buildInputDecoration("Any difficulties encountered", Icons.warning),
                  ),

                  const SizedBox(height: 16),

                  // Key Learnings
                  _buildLabel("Key Learnings", Icons.school),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _learningsController,
                    maxLines: 2,
                    decoration: _buildInputDecoration("What you learned from this task", Icons.school),
                  ),

                  const SizedBox(height: 20),

                  // Photo Upload Section
                  _buildLabel("Task Photos *", Icons.photo_camera),
                  const SizedBox(height: 8),
                  _buildFileUploadSection(
                    title: "Upload Photos",
                    files: _taskPhotos,
                    onPick: () => _pickFiles('photos'),
                    onRemove: (index) => _removeFile('photos', index),
                    icon: Icons.image,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 16),

                  // Document Upload Section
                  _buildLabel("Supporting Documents", Icons.description),
                  const SizedBox(height: 8),
                  _buildFileUploadSection(
                    title: "Upload Documents",
                    files: _taskDocuments,
                    onPick: () => _pickFiles('documents'),
                    onRemove: (index) => _removeFile('documents', index),
                    icon: Icons.insert_drive_file,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 16),

                  // Additional Notes
                  _buildLabel("Additional Notes", Icons.note),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: _buildInputDecoration("Any other information", Icons.note),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitTaskReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Submit Task Report",
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
          child: _completedTasks.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No task reports found',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _completedTasks.length,
            itemBuilder: (context, index) {
              final task = _completedTasks[index];
              return _buildTaskHistoryCard(task);
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

  Widget _buildTaskHistoryCard(Map<String, dynamic> task) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: task['statusColor'].withOpacity(0.3)),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: task['statusColor'].withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.task, color: task['statusColor']),
        ),
        title: Text(
          task['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task['category']),
            Text(
              _dateFormat.format(task['date']),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: task['statusColor'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: task['statusColor']),
          ),
          child: Text(
            task['status'],
            style: TextStyle(
              color: task['statusColor'],
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
                _buildHistoryDetailRow(Icons.location_on, 'Location', task['location']),
                _buildHistoryDetailRow(Icons.photo, 'Photos', '${task['photos']} photos'),
                if (task['documents'] > 0)
                  _buildHistoryDetailRow(Icons.description, 'Documents', '${task['documents']} files'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _showSnackBar('View report details', Colors.blue);
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Report'),
                    ),
                    const SizedBox(width: 8),
                    if (task['status'] == 'Completed')
                      ElevatedButton.icon(
                        onPressed: () {
                          _showSnackBar('Downloading report', Colors.green);
                        },
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Download'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
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
            width: 70,
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

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 18),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildFileUploadSection({
    required String title,
    required List<Map<String, dynamic>> files,
    required VoidCallback onPick,
    required Function(int) onRemove,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          if (files.isEmpty)
            InkWell(
              onTap: onPick,
              child: Column(
                children: [
                  Icon(icon, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(title, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text(
                    title == "Upload Photos" ? "JPG, PNG" : "PDF, DOC, TXT",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
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
          if (files.isNotEmpty)
            Column(
              children: [
                ...files.asMap().entries.map((entry) {
                  return ListTile(
                    leading: Icon(
                      _getFileIcon(entry.value['name']),
                      color: _getFileColor(entry.value['name']),
                    ),
                    title: Text(entry.value['name'], maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(_formatFileSize(entry.value['size'])),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => onRemove(entry.key),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onPick,
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
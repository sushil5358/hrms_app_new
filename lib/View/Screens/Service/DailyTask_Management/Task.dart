import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import '../../../../Controller/Daily_Task_controller.dart';
import '../../../../utils/colers.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DailyTask extends StatefulWidget {
  const DailyTask({super.key});

  @override
  State<DailyTask> createState() => _DailyTaskState();
}

class _DailyTaskState extends State<DailyTask> {
  Daily_Task_Controller controller = Get.put(Daily_Task_Controller());

  // Selected date for filtering
  DateTime _selectedDate = DateTime.now();

  // Filter options
  String _selectedFilter = 'All'; // All, Pending, Completed, In Progress

  // Category filter
  String _selectedCategory = 'All Categories';

  // Priority filter
  String _selectedPriority = 'All Priorities';

  // Search query
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Get unique categories for filter
  List<String> get categories {
    Set<String> cats = {'All Categories'};
    if (controller.Tasks.isNotEmpty) {
      cats.addAll(
          controller.Tasks.map((task) => task['category'] as String).toSet());
    }
    return cats.toList();
  }

  // Get unique priorities for filter
  List<String> get priorities {
    Set<String> prios = {'All Priorities'};
    if (controller.Tasks.isNotEmpty) {
      prios.addAll(
          controller.Tasks.map((task) => task['priority'] as String).toSet());
    }
    return prios.toList();
  }

  // Get filtered tasks based on search query
  List<dynamic> get filteredTasks {
    if (_searchQuery.isEmpty) {
      return controller.Tasks;
    }

    final query = _searchQuery.toLowerCase();
    return controller.Tasks.where((task) {
      return task['task_title'].toString().toLowerCase().contains(query) ||
          task['task_description'].toString().toLowerCase().contains(query) ||
          task['id'].toString().toLowerCase().contains(query) ||
          task['category'].toString().toLowerCase().contains(query) ||
          task['priority'].toString().toLowerCase().contains(query);
    }).toList();
  }

  // Task statistics
  Map<String, int> get taskStats {
    int total = filteredTasks.length;
    int completed = filteredTasks
        .where((t) => t['status'] == 'Completed')
        .length;
    int pending = filteredTasks
        .where((t) => t['status'] == 'Pending')
        .length;
    int inProgress = filteredTasks
        .where((t) => t['status'] == 'In Progress')
        .length;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'inProgress': inProgress,
    };
  }

  // Date formatting
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void dispose() {
    _searchController.dispose();
    _workNoteController.dispose();
    super.dispose();
  }

  // Helper method to format date
  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is DateTime) {
      return _dateFormat.format(date);
    }
    if (date is String) {
      try {
        return _dateFormat.format(DateTime.parse(date));
      } catch (e) {
        return date;
      }
    }
    return date.toString();
  }

  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  // Controllers for complete task dialog
  final TextEditingController _workNoteController = TextEditingController();
  List<Map<String, dynamic>> _attachedFiles = [];
  bool _isUploading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // File picker method
  Future<void> _pickFiles(StateSetter setState) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'
        ],
        allowCompression: true,
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
              'bytes': file.bytes,
              'extension': file.extension,
            });
          }
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.length} file(s) selected successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking files: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Format file size
  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  // Method to show complete task dialog
  void _showCompleteTaskDialog(Map<String, dynamic> task) {
    _workNoteController.clear();
    _attachedFiles.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Icon(Icons.task_alt, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  const Text('Complete Task'),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Title
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Task',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              task['task_title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              task['id'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Work Description Note Field
                      Text(
                        'Work Description Note',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _workNoteController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Describe the work completed...',
                            border: InputBorder.none,
                            fillColor: primary_color,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Attach File Section
                      Text(
                        'Attach Files',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Attach File Button
                      OutlinedButton.icon(
                        onPressed: _isUploading
                            ? null
                            : () => _pickFiles(setState),
                        icon: Icon(
                          Icons.attach_file,
                          color: _isUploading ? Colors.grey : Colors.blue,
                        ),
                        label: Text(
                          _isUploading ? 'Uploading...' : 'Choose Files',
                          style: TextStyle(
                            color: _isUploading ? Colors.grey : Colors.blue,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _isUploading ? Colors.grey.shade400 : Colors.blue,
                          ),
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),

                      // Show attached files
                      if (_attachedFiles.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle, size: 16,
                                      color: Colors.green.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_attachedFiles.length} File(s) Selected',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ..._attachedFiles.asMap().entries.map((entry) {
                                int index = entry.key;
                                var file = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.green.shade100),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: _getFileIconColor(file['extension']).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Icon(
                                            _getFileIcon(file['extension']),
                                            size: 16,
                                            color: _getFileIconColor(file['extension']),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                file['name'],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                _formatFileSize(file['size']),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 16),
                                          onPressed: () {
                                            setState(() {
                                              _attachedFiles.removeAt(index);
                                            });
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          color: Colors.grey.shade600,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),

                      if (_isUploading)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: _isUploading
                      ? null
                      : () => _submitCompletedTask(task, context),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Get file icon based on extension
  IconData _getFileIcon(String? extension) {
    if (extension == null) return Icons.insert_drive_file;

    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Get file icon color based on extension
  Color _getFileIconColor(String? extension) {
    if (extension == null) return Colors.grey;

    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      case 'txt':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Submit completed task
  void _submitCompletedTask(Map<String, dynamic> task, BuildContext dialogContext) {
    if (_workNoteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add work description note'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Close the dialog
    Navigator.pop(dialogContext);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Task "${task['task_title']}" completed successfully! ${_attachedFiles.isNotEmpty ? '${_attachedFiles.length} file(s) uploaded.' : ''}',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    // Here you would typically update the task in your backend
    // For demo, we'll update the local task
    setState(() {
      task['status'] = 'Completed';
      task['statusColor'] = Colors.green;
      task['completedDate'] = DateTime.now();
      task['progress'] = 100;
      task['workNote'] = _workNoteController.text;
      task['uploadedFiles'] = _attachedFiles.map((file) => file['name']).toList();
      task['uploadedFilesDetails'] = List.from(_attachedFiles);
    });

    // Clear controllers
    _workNoteController.clear();
    _attachedFiles.clear();
  }

  // Clear all filters
  void _clearAllFilters() {
    setState(() {
      _selectedFilter = 'All';
      _selectedCategory = 'All Categories';
      _selectedPriority = 'All Priorities';
      _searchController.clear();
      _searchQuery = '';
    });
  }

  // NEW METHOD: Download and open file from API
  Future<void> _downloadAndOpenFile(String fileUrl, String fileName) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
        const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Download file
      final http.Response response = await http.get(Uri.parse(fileUrl));

      if (response.statusCode == 200) {
        // Get the application documents directory
        final Directory directory = await getApplicationDocumentsDirectory();
        final String filePath = '${directory.path}/$fileName';

        // Save the file
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Close loading dialog
        Navigator.pop(context);

        // Open the file
        final result = await OpenFile.open(filePath);

        if (result.type != ResultType.done) {
          // Show error if file couldn't be opened
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open file: ${result.message}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Close loading dialog
        Navigator.pop(context);

        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download file: ${response.statusCode}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading file: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Helper method to parse file details from API response
  List<Map<String, dynamic>> _parseFileDetails(dynamic fileData) {
    List<Map<String, dynamic>> files = [];

    if (fileData is String && fileData.isNotEmpty) {
      // If it's a JSON string, parse it
      try {
        // Assuming fileData is a JSON string like: [{"name":"file.pdf","url":"http://..."}]
        List<dynamic> parsed = jsonDecode(fileData);
        for (var item in parsed) {
          files.add({
            'name': item['name'] ?? 'Unknown',
            'url': item['url'] ?? item['path'] ?? '',
            'size': item['size'] ?? 0,
            'extension': item['name']?.split('.').last ?? '',
          });
        }
      } catch (e) {
        // If it's just a single file path
        files.add({
          'name': fileData.split('/').last,
          'url': fileData,
          'size': 0,
          'extension': fileData.split('.').last,
        });
      }
    } else if (fileData is List) {
      // If it's already a list
      for (var item in fileData) {
        files.add({
          'name': item['name'] ?? 'Unknown',
          'url': item['url'] ?? item['path'] ?? '',
          'size': item['size'] ?? 0,
          'extension': item['name']?.split('.').last ?? '',
        });
      }
    }

    return files;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        title: const Text("Daily Task"),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tasks by title, description, ID, category...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Search result count
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Found ${filteredTasks.length} result(s) for "$_searchQuery"',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: const Text('Clear Search'),
                    ),
                  ],
                ),
              ),



            // Task List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: primary_color,
                      size: 80,
                    ),
                  );
                } else if (filteredTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No tasks found for "$_searchQuery"'
                              : 'No tasks available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: const Text('Clear Search'),
                          ),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(filteredTasks[index]);
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChipInDialog(String label, bool isSelected, StateSetter setState) {
    Color getColor() {
      if (label == 'Pending') return Colors.orange;
      if (label == 'Completed') return Colors.green;
      if (label == 'In Progress') return Colors.purple;
      return Colors.blue;
    }
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: getColor().withOpacity(0.2),
      checkmarkColor: getColor(),
      labelStyle: TextStyle(
        color: isSelected ? getColor() : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    DateTime dueDate = _parseDate(task['due_date']);
    bool isOverdue = dueDate.isBefore(DateTime.now()) && task['status'] != 'Completed';
    // Parse attached files from API
    List<Map<String, dynamic>> attachedFiles = [];
    if (task['attachment_path'] != null && task['attachment_path'].isNotEmpty) {
      attachedFiles = _parseFileDetails(task['attachment_path']);
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isOverdue ? Colors.red.withOpacity(0.3) : Colors.grey.shade200,
          width: isOverdue ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showTaskDetails(task),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "Task Id :- ${task['id']}",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Header with ID and Priority
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task['task_title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task['priority']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getPriorityColor(task['priority'])),
                    ),
                    child: Text(
                      task['priority'],
                      style: TextStyle(
                        color: _getPriorityColor(task['priority']),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Category and Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task['category'],
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor(task['status'])),
                    ),
                    child: Text(
                      task['status'],
                      style: TextStyle(
                        color: _getStatusColor(task['status']),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.description, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      task['task_description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Due Date and Assigned By
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isOverdue ? Colors.red : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${_formatDate(task['due_date'])}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isOverdue ? Colors.red : Colors.grey.shade600,
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  if (task['completedDate'] != null)
                    Row(
                      children: [
                        Icon(Icons.check_circle, size: 12, color: Colors.green.shade400),
                        const SizedBox(width: 4),
                        Text(
                          'Completed: ${_dateFormat.format(task['completedDate'])}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Footer with Attachments
              if (attachedFiles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: attachedFiles.map((file) {
                      return GestureDetector(
                        onTap: () => _downloadAndOpenFile(file['url'], file['name']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getFileIconColor(file['extension']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getFileIconColor(file['extension'])),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getFileIcon(file['extension']),
                                size: 12,
                                color: _getFileIconColor(file['extension']),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                file['name'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getFileIconColor(file['extension']),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Complete Button for non-completed tasks
              if (task['status'] != 'Completed')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showCompleteTaskDialog(task);
                          },
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text('Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      case 'critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showTaskDetails(Map<String, dynamic> task) {
    // Parse attached files from API
    List<Map<String, dynamic>> attachedFiles = [];
    if (task['attachment_path'] != null && task['attachment_path'].isNotEmpty) {
      attachedFiles = _parseFileDetails(task['attachment_path']);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(task['priority']).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.task_alt,
                          color: _getPriorityColor(task['priority']),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task['task_title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Task Id ${task['id']} • ${task['category']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Details
                  _buildDetailSection('Description', task['task_description']),

                  const SizedBox(height: 16),

                  _buildInfoRow('Assigned Date', _formatDate(task['created_at'])),
                  _buildInfoRow('Due Date', _formatDate(task['due_date'])),
                  if (task['completedDate'] != null)
                    _buildInfoRow('Completed Date', _formatDate(task['completedDate'])),
                  _buildInfoRow('Priority', task['priority'],
                      color: _getPriorityColor(task['priority'])),
                  _buildInfoRow('Status', task['status'],
                      color: _getStatusColor(task['status'])),

                  // Show attachments section
                  if (attachedFiles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.attach_file, size: 16, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Attachments (${attachedFiles.length})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...attachedFiles.map((file) =>
                              GestureDetector(
                                onTap: () => _downloadAndOpenFile(file['url'], file['name']),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.blue.shade100),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: _getFileIconColor(file['extension']).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Icon(
                                          _getFileIcon(file['extension']),
                                          size: 20,
                                          color: _getFileIconColor(file['extension']),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              file['name'],
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (file['size'] > 0)
                                              Text(
                                                _formatFileSize(file['size']),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.download,
                                        size: 20,
                                        color: Colors.blue.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                              )).toList(),
                        ],
                      ),
                    ),
                  ],

                  // Show work note if available (for completed tasks)
                  if (task['workNote'] != null) ...[
                    const SizedBox(height: 16),
                    _buildDetailSection('Work Description Note', task['workNote']),
                  ],

                  // Show uploaded files if available
                  if (task['uploadedFiles'] != null && task['uploadedFiles'].isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.upload_file, size: 16, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Uploaded Files (${task['uploadedFiles'].length})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...task['uploadedFiles'].map((file) =>
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.insert_drive_file, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        file,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                        ],
                      ),
                    ),
                  ],

                  // Complete Button in details for non-completed tasks
                  if (task['status'] != 'Completed')
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showCompleteTaskDialog(task);
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Complete Task'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
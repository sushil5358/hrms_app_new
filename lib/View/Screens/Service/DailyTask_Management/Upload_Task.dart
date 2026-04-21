import 'dart:developer';
import 'dart:math';
import 'package:employee_app/utils/colers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../../../../Controller/ReviewTask_controller.dart';

class UploadTask extends StatefulWidget {
  const UploadTask({super.key});

  @override
  State<UploadTask> createState() => _UploadTaskState();
}

class _UploadTaskState extends State<UploadTask> {

  ReviewtaskController controller = Get.put(ReviewtaskController());
  // Filter options
  String _selectedStatusFilter = 'All'; // All, Pending Review, Approved, Rejected, Changes Requested, In Progress

  // Priority filter
  String _selectedPriorityFilter = 'All Priorities'; // All Priorities, Critical, High, Medium, Low

  // Search query
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Rating controller
  double _selectedRating = 0.0;

  // File attachment variables for resubmit dialog
  List<Map<String, dynamic>> _resubmitAttachments = [];
  bool _isUploading = false;

  // Sample completed tasks waiting for review
  List<Map<String, dynamic>> _completedTasks = [
    {
      'id': 'TASK003',
      'title': 'Database Optimization',
      'description': 'Optimize database queries and indexing',
      'assignedBy': 'Priya Sharma',
      'assignedDate': DateTime(2024, 3, 10),
      'completedDate': DateTime(2024, 3, 15),
      'dueDate': DateTime(2024, 3, 16),
      'priority': 'High',
      'priorityColor': Colors.red,
      'workNote': 'Optimized 15 slow queries, added proper indexes, and implemented query caching. Reduced average response time by 60%.',
      'attachments': [
        {'name': 'query_optimization_report.pdf', 'size': 2500000, 'type': 'pdf'},
        {'name': 'performance_metrics.xlsx', 'size': 1800000, 'type': 'xlsx'},
      ],
      'status': 'Approved',
      'statusColor': Colors.green,
      'rating': 5.0,
      'feedback': 'Outstanding performance improvement! Database is now running smoothly.',
      'reviewedBy': 'Database Architect',
      'reviewedDate': DateTime(2024, 3, 16),
    },

    // TASK004
    {
      'id': 'TASK004',
      'title': 'User Documentation',
      'description': 'Create user manual for new feature',
      'assignedBy': 'Rahul Mehta',
      'assignedDate': DateTime(2024, 3, 12),
      'completedDate': DateTime(2024, 3, 16),
      'dueDate': DateTime(2024, 3, 18),
      'priority': 'Medium',
      'priorityColor': Colors.orange,
      'workNote': 'Created comprehensive user documentation including step-by-step guides, screenshots, and troubleshooting sections.',
      'attachments': [
        {'name': 'user_manual_v2.1.pdf', 'size': 4200000, 'type': 'pdf'},
        {'name': 'screenshots.zip', 'size': 8900000, 'type': 'zip'},
      ],
      'status': 'Rejected',
      'statusColor': Colors.red,
      'rating': 2.0,
      'feedback': 'Documentation lacks technical depth and missing API references. Need complete rewrite.',
      'reviewedBy': 'Technical Writer',
      'reviewedDate': DateTime(2024, 3, 17),
    },

    // TASK005
    {
      'id': 'TASK005',
      'title': 'API Integration',
      'description': 'Integrate payment gateway API',
      'assignedBy': 'Neha Gupta',
      'assignedDate': DateTime(2024, 3, 8),
      'completedDate': DateTime(2024, 3, 14),
      'dueDate': DateTime(2024, 3, 15),
      'priority': 'Critical',
      'priorityColor': Colors.purple,
      'workNote': 'Successfully integrated Razorpay payment gateway. Implemented webhooks for payment confirmation and error handling.',
      'attachments': [
        {'name': 'api_documentation.pdf', 'size': 1800000, 'type': 'pdf'},
        {'name': 'integration_code.zip', 'size': 3500000, 'type': 'zip'},
      ],
      'status': 'Rejected',
      'statusColor': Colors.red,
      'rating': 1.5,
      'feedback': 'Payment confirmation webhook not working properly. Refund functionality missing. Multiple security concerns.',
      'reviewedBy': 'Tech Lead',
      'reviewedDate': DateTime(2024, 3, 15),
    },

    // TASK006
    {
      'id': 'TASK006',
      'title': 'UI Redesign',
      'description': 'Redesign dashboard layout',
      'assignedBy': 'Arjun Nair',
      'assignedDate': DateTime(2024, 3, 5),
      'completedDate': DateTime(2024, 3, 12),
      'dueDate': DateTime(2024, 3, 20),
      'priority': 'Low',
      'priorityColor': Colors.green,
      'workNote': 'Redesigned dashboard with modern UI elements, responsive layout, and dark mode support. Implemented new color scheme and typography.',
      'attachments': [
        {'name': 'dashboard_mockups.fig', 'size': 15200000, 'type': 'fig'},
        {'name': 'design_guidelines.pdf', 'size': 3200000, 'type': 'pdf'},
      ],
      'status': 'Approved',
      'statusColor': Colors.green,
      'rating': 5.0,
      'feedback': 'Excellent design! Users love the new interface. Implementation is pixel-perfect.',
      'reviewedBy': 'UI/UX Director',
      'reviewedDate': DateTime(2024, 3, 13),
    },

    // TASK007
    {
      'id': 'TASK007',
      'title': 'Security Audit',
      'description': 'Perform security vulnerability assessment',
      'assignedBy': 'Vikram Singh',
      'assignedDate': DateTime(2024, 3, 1),
      'completedDate': DateTime(2024, 3, 10),
      'dueDate': DateTime(2024, 3, 12),
      'priority': 'Critical',
      'priorityColor': Colors.purple,
      'workNote': 'Conducted comprehensive security audit. Found and fixed 8 vulnerabilities including SQL injection, XSS, and CSRF. Implemented security headers.',
      'attachments': [
        {'name': 'security_audit_report.pdf', 'size': 5800000, 'type': 'pdf'},
        {'name': 'vulnerability_fixes.zip', 'size': 2100000, 'type': 'zip'},
      ],
      'status': 'Approved',
      'statusColor': Colors.green,
      'rating': 5.0,
      'feedback': 'Excellent work! All critical vulnerabilities fixed. System is now secure and compliant.',
      'reviewedBy': 'Security Head',
      'reviewedDate': DateTime(2024, 3, 11),
    },

    // TASK008
    {
      'id': 'TASK008',
      'title': 'Code Refactoring',
      'description': 'Refactor legacy code module',
      'assignedBy': 'Amit Kumar',
      'assignedDate': DateTime(2024, 3, 7),
      'completedDate': DateTime(2024, 3, 13),
      'dueDate': DateTime(2024, 3, 14),
      'priority': 'Medium',
      'priorityColor': Colors.orange,
      'workNote': 'Refactored 5000 lines of legacy code. Improved code structure, removed dead code, added unit tests, and improved documentation.',
      'attachments': [
        {'name': 'refactoring_summary.pdf', 'size': 850000, 'type': 'pdf'},
        {'name': 'code_coverage_report.html', 'size': 3200000, 'type': 'html'},
      ],
      'status': 'Rejected',
      'statusColor': Colors.red,
      'rating': 2.0,
      'feedback': 'Refactoring introduced new bugs in payment module. Critical functionality broken. Need to revert and redo.',
      'reviewedBy': 'Senior Developer',
      'reviewedDate': DateTime(2024, 3, 14),
    },

    // TASK009
    {
      'id': 'TASK009',
      'title': 'Mobile App Testing',
      'description': 'Test app on multiple devices',
      'assignedBy': 'Priya Sharma',
      'assignedDate': DateTime(2024, 3, 9),
      'completedDate': DateTime(2024, 3, 15),
      'dueDate': DateTime(2024, 3, 16),
      'priority': 'High',
      'priorityColor': Colors.red,
      'workNote': 'Tested app on 20+ Android and iOS devices. Found 12 bugs, created detailed bug reports, and verified fixes.',
      'attachments': [
        {'name': 'test_report.pdf', 'size': 4200000, 'type': 'pdf'},
        {'name': 'bug_screenshots.zip', 'size': 12500000, 'type': 'zip'},
      ],
      'status': 'Rejected',
      'statusColor': Colors.red,
      'rating': 1.0,
      'feedback': 'Missed critical bugs on older iOS versions. App crashes on iOS 14. Test coverage insufficient.',
      'reviewedBy': 'QA Manager',
      'reviewedDate': DateTime(2024, 3, 16),
    },

    // TASK010
    {
      'id': 'TASK010',
      'title': 'Client Training Session',
      'description': 'Conduct training for client team',
      'assignedBy': 'Rahul Mehta',
      'assignedDate': DateTime(2024, 3, 11),
      'completedDate': DateTime(2024, 3, 14),
      'dueDate': DateTime(2024, 3, 14),
      'priority': 'High',
      'priorityColor': Colors.red,
      'workNote': 'Conducted 4-hour training session for 15 client team members. Covered all features, best practices, and troubleshooting.',
      'attachments': [
        {'name': 'training_materials.pdf', 'size': 6800000, 'type': 'pdf'},
        {'name': 'training_video.mp4', 'size': 452000000, 'type': 'mp4'},
      ],
      'status': 'Approved',
      'statusColor': Colors.green,
      'rating': 5.0,
      'feedback': 'Excellent training session! Client team is now confident in using the system. Very positive feedback received.',
      'reviewedBy': 'Project Manager',
      'reviewedDate': DateTime(2024, 3, 15),
    },

    // TASK011
    {
      'id': 'TASK011',
      'title': 'Performance Testing',
      'description': 'Conduct load and stress testing',
      'assignedBy': 'Neha Gupta',
      'assignedDate': DateTime(2024, 3, 4),
      'completedDate': DateTime(2024, 3, 9),
      'dueDate': DateTime(2024, 3, 11),
      'priority': 'Medium',
      'priorityColor': Colors.orange,
      'workNote': 'Performed load testing with 10,000 concurrent users. Identified bottlenecks and provided optimization recommendations.',
      'attachments': [
        {'name': 'load_test_results.pdf', 'size': 3800000, 'type': 'pdf'},
        {'name': 'performance_graphs.png', 'size': 2100000, 'type': 'png'},
      ],
      'status': 'Rejected',
      'statusColor': Colors.red,
      'rating': 2.0,
      'feedback': 'Insufficient test coverage. Did not test database performance under load. Missing critical metrics.',
      'reviewedBy': 'Performance Engineer',
      'reviewedDate': DateTime(2024, 3, 10),
    },

    // TASK012
    {
      'id': 'TASK012',
      'title': 'DevOps Pipeline Setup',
      'description': 'Setup CI/CD pipeline',
      'assignedBy': 'Arjun Nair',
      'assignedDate': DateTime(2024, 2, 28),
      'completedDate': DateTime(2024, 3, 8),
      'dueDate': DateTime(2024, 3, 10),
      'priority': 'High',
      'priorityColor': Colors.red,
      'workNote': 'Implemented complete CI/CD pipeline using Jenkins. Automated build, test, and deployment processes for all environments.',
      'attachments': [
        {'name': 'pipeline_configuration.pdf', 'size': 2900000, 'type': 'pdf'},
        {'name': 'deployment_scripts.zip', 'size': 850000, 'type': 'zip'},
      ],
      'status': 'Approved',
      'statusColor': Colors.green,
      'rating': 4.5,
      'feedback': 'Great work! Pipeline is working smoothly. Reduced deployment time by 70%. Documentation is comprehensive.',
      'reviewedBy': 'DevOps Lead',
      'reviewedDate': DateTime(2024, 3, 9),
    },

    // TASK013
    {
      'id': 'TASK013',
      'title': 'Email Template Design',
      'description': 'Create responsive email templates',
      'assignedBy': 'Priya Sharma',
      'assignedDate': DateTime(2024, 3, 13),
      'completedDate': DateTime(2024, 3, 17),
      'dueDate': DateTime(2024, 3, 19),
      'priority': 'Low',
      'priorityColor': Colors.green,
      'workNote': 'Designed 5 responsive email templates for various purposes: welcome emails, notifications, newsletters, and promotional campaigns.',
      'attachments': [
        {'name': 'email_templates.html', 'size': 350000, 'type': 'html'},
        {'name': 'template_previews.pdf', 'size': 1800000, 'type': 'pdf'},
      ],
      'status': 'Approved',
      'statusColor': Colors.green,
      'rating': 4.0,
      'feedback': 'Clean designs! All templates are mobile-responsive. Good work.',
      'reviewedBy': 'Marketing Head',
      'reviewedDate': DateTime(2024, 3, 18),
    },

    // TASK014
    {
      'id': 'TASK014',
      'title': 'Bug Fixing - Critical Issues',
      'description': 'Fix production critical bugs',
      'assignedBy': 'Vikram Singh',
      'assignedDate': DateTime(2024, 3, 15),
      'completedDate': DateTime(2024, 3, 16),
      'dueDate': DateTime(2024, 3, 16),
      'priority': 'Critical',
      'priorityColor': Colors.purple,
      'workNote': 'Fixed 3 critical production bugs: login failure for specific users, payment timeout issue, and data sync problem.',
      'attachments': [
        {'name': 'bug_fixes_report.pdf', 'size': 1200000, 'type': 'pdf'},
        {'name': 'hotfix_notes.txt', 'size': 45000, 'type': 'txt'},
      ],
      'status': 'Approved',
      'statusColor': Colors.green,
      'rating': 5.0,
      'feedback': 'Quick response and excellent fixes. All issues resolved without downtime.',
      'reviewedBy': 'Tech Lead',
      'reviewedDate': DateTime(2024, 3, 16),
    },
  ];

  // Get unique priorities for filter
  List<String> get priorities {
    Set<String> prios = {'All Priorities'};
    prios.addAll(_completedTasks.map((task) => task['priority'] as String).toSet());
    return prios.toList();
  }

  // Get filtered tasks based on status filter, priority filter, and search
  List<Map<String, dynamic>> get filteredTasks {
    return _completedTasks.where((task) {
      // Apply status filter
      if (_selectedStatusFilter != 'All' && task['status'] != _selectedStatusFilter) {
        return false;
      }

      // Apply priority filter
      if (_selectedPriorityFilter != 'All Priorities' && task['priority'] != _selectedPriorityFilter) {
        return false;
      }

      // Apply search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return task['title'].toLowerCase().contains(query) ||
            task['description'].toLowerCase().contains(query) ||
            task['id'].toLowerCase().contains(query) ||
            task['assignedBy'].toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  // Date formatting
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _timeFormat = DateFormat('hh:mm a');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Get file icon based on type
  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
      case 'excel':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Get file icon color
  Color _getFileIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
      case 'excel':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.purple;
      case 'txt':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // File picker for resubmit dialog
  Future<void> _pickFilesForResubmit() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'txt', 'xlsx', 'pptx', 'zip', 'html', 'fig', 'mp4'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          _isUploading = true;
        });

        // Simulate upload delay
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          for (var file in result.files) {
            String extension = file.extension ?? 'unknown';
            _resubmitAttachments.add({
              'name': file.name,
              'size': file.size,
              'path': file.path,
              'type': extension.toLowerCase(),
            });
          }
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.length} file(s) attached successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
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

  // Remove file from resubmit list
  void _removeResubmitFile(int index) {
    setState(() {
      _resubmitAttachments.removeAt(index);
    });
  }

  // Clear all resubmit files
  void _clearResubmitFiles() {
    setState(() {
      _resubmitAttachments.clear();
    });
  }

  // Format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Show task review dialog
  void _showReviewDialog(Map<String, dynamic> task) {
    double rating = task['rating'] ?? 0.0;
    TextEditingController feedbackController = TextEditingController(text: task['feedback'] ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.rate_review, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  const Text('Review Task'),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Info
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
                              task['title'],
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

                      // Rating Section
                      const Text(
                        'Rating',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 1; i <= 5; i++)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  rating = i.toDouble();
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  i <= rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (rating > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Center(
                            child: Text(
                              '${rating.toStringAsFixed(1)} Stars',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Feedback Section
                      const Text(
                        'Feedback',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: feedbackController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Provide feedback on the completed task...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showUndoDialog(task);
                              },
                              icon: const Icon(Icons.undo, size: 18),
                              label: const Text('Request Changes'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                                side: const BorderSide(color: Colors.orange),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (rating == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please provide a rating'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }
                                _approveTask(task, rating, feedbackController.text);
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Show undo dialog for requesting changes
  void _showUndoDialog(Map<String, dynamic> task) {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Request Changes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Provide reason for requesting changes:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter reason...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a reason'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                _requestChanges(task, reasonController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit Request'),
            ),
          ],
        );
      },
    );
  }

  // Show undo task dialog (for employee to undo submission)
  void _showUndoTaskDialog(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Undo Task Submission'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to undo the submission of "${task['title']}"?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'The task will be moved back to "In Progress" status.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _undoTaskSubmission(task);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Undo'),
            ),
          ],
        );
      },
    );
  }

  // Show resubmit dialog for rejected tasks with file upload
  void _showResubmitDialog(Map<String, dynamic> task) {
    // Clear previous attachments
    _resubmitAttachments.clear();

    TextEditingController workNoteController = TextEditingController(text: task['workNote'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Resubmit Task'),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Previous feedback
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.feedback, color: Colors.red.shade700, size: 16),
                                const SizedBox(width: 8),
                                const Text(
                                  'Previous Feedback',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              task['feedback'] ?? 'No feedback provided',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Updated work note
                      TextField(
                        controller: workNoteController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Updated Work Description',
                          hintText: 'Describe the changes/fixes made...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // File Attachment Section
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // File picker button
                            if (_resubmitAttachments.isEmpty)
                              InkWell(
                                onTap: () async {
                                  await _pickFilesForResubmit();
                                  setState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.cloud_upload_outlined,
                                        size: 32,
                                        color: Colors.blue.shade300,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Tap to upload files",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "PDF, DOC, JPG, PNG, XLSX, PPTX, ZIP",
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Upload progress indicator
                            if (_isUploading)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    LinearProgressIndicator(),
                                    SizedBox(height: 8),
                                    Text("Uploading files..."),
                                  ],
                                ),
                              ),

                            // File list
                            if (_resubmitAttachments.isNotEmpty)
                              Column(
                                children: [
                                  ..._resubmitAttachments.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    Map<String, dynamic> file = entry.value;
                                    return Container(
                                      margin: const EdgeInsets.all(8),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: _getFileIconColor(file['type']).withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _getFileIcon(file['type']),
                                              color: _getFileIconColor(file['type']),
                                              size: 16,
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
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
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
                                              _removeResubmitFile(index);
                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }),

                                  // File actions
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {
                                            _clearResubmitFiles();
                                            setState(() {});
                                          },
                                          icon: const Icon(Icons.clear_all, size: 14),
                                          label: const Text('Clear All'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            await _pickFilesForResubmit();
                                            setState(() {});
                                          },
                                          icon: const Icon(Icons.add, size: 14),
                                          label: const Text('Add More'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(80, 30),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // New due date info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'New due date: ${_dateFormat.format(DateTime.now().add(const Duration(days: 3)))}',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
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
              actions: [
                TextButton(
                  onPressed: () {
                    _resubmitAttachments.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (workNoteController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please provide updated work description'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    // Merge existing attachments with new ones
                    List<Map<String, dynamic>> allAttachments = List.from(task['attachments'] ?? []);
                    allAttachments.addAll(_resubmitAttachments);

                    _resubmitTask(task, workNoteController.text, allAttachments);
                    _resubmitAttachments.clear();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Resubmit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Show reupload dialog
  void _showReuploadDialog(Map<String, dynamic> task) {
    TextEditingController workNoteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Re-upload Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Previous feedback: ${task['feedback']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (task['dueDate'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.orange.shade700, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'New due date: ${_dateFormat.format(task['dueDate'].add(const Duration(days: 2)))}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: workNoteController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Work Description',
                  hintText: 'Describe the changes made...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (workNoteController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide work description'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                _reuploadTask(task, workNoteController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Re-upload'),
            ),
          ],
        );
      },
    );
  }

  // Approve task
  void _approveTask(Map<String, dynamic> task, double rating, String feedback) {
    setState(() {
      task['status'] = 'Approved';
      task['statusColor'] = Colors.green;
      task['rating'] = rating;
      task['feedback'] = feedback;
      task['reviewedBy'] = 'Current User';
      task['reviewedDate'] = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task['title']}" approved successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Request changes
  void _requestChanges(Map<String, dynamic> task, String reason) {
    setState(() {
      task['status'] = 'Changes Requested';
      task['statusColor'] = Colors.orange;
      task['feedback'] = reason;
      task['reviewedBy'] = 'Current User';
      task['reviewedDate'] = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Changes requested for "${task['title']}"'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Undo task submission (employee function)
  void _undoTaskSubmission(Map<String, dynamic> task) {
    setState(() {
      task['status'] = 'In Progress';
      task['statusColor'] = Colors.blue;
      task['completedDate'] = null;
      task['feedback'] = '';
      task['rating'] = 0;
      task['reviewedBy'] = null;
      task['reviewedDate'] = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task['title']}" has been moved back to In Progress'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Resubmit task (for rejected tasks) with attachments
  void _resubmitTask(Map<String, dynamic> task, String updatedWorkNote, List<Map<String, dynamic>> newAttachments) {
    setState(() {
      task['status'] = 'Pending Review';
      task['statusColor'] = Colors.orange;
      task['workNote'] = updatedWorkNote;
      task['completedDate'] = DateTime.now();
      task['dueDate'] = DateTime.now().add(const Duration(days: 3));
      task['feedback'] = ''; // Clear previous feedback
      task['rating'] = 0;
      task['reviewedBy'] = null;
      task['reviewedDate'] = null;
      // Add new attachments to existing ones
      task['attachments'] = [...task['attachments'], ...newAttachments];
      // Add a note about resubmission
      task['resubmissionCount'] = (task['resubmissionCount'] ?? 0) + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task['title']}" has been resubmitted for review with ${newAttachments.length} new file(s)'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Re-upload task
  void _reuploadTask(Map<String, dynamic> task, String workNote) {
    setState(() {
      task['status'] = 'Pending Review';
      task['statusColor'] = Colors.orange;
      task['workNote'] = workNote;
      task['completedDate'] = DateTime.now();
      task['dueDate'] = task['dueDate'].add(const Duration(days: 2));
      task['feedback'] = '';
      task['rating'] = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task['title']}" re-uploaded successfully!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Clear all filters
  void _clearAllFilters() {
    setState(() {
      _selectedStatusFilter = 'All';
      _selectedPriorityFilter = 'All Priorities';
      _searchController.clear();
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        title: const Text("Review Completed Tasks"),
        elevation: 0,
        actions: [],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
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

            // Filters Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Filters Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', _selectedStatusFilter == 'All'),
                        _buildFilterChip('Pending Review', _selectedStatusFilter == 'Pending Review'),
                        _buildFilterChip('Approved', _selectedStatusFilter == 'Approved'),
                        _buildFilterChip('Rejected', _selectedStatusFilter == 'Rejected'),
                        _buildFilterChip('Changes Requested', _selectedStatusFilter == 'Changes Requested'),
                        _buildFilterChip('In Progress', _selectedStatusFilter == 'In Progress'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Priority Filter Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedPriorityFilter,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              items: priorities.map((priority) {
                                Color priorityColor = Colors.grey;
                                if (priority == 'Critical') priorityColor = Colors.purple;
                                else if (priority == 'High') priorityColor = Colors.red;
                                else if (priority == 'Medium') priorityColor = Colors.orange;
                                else if (priority == 'Low') priorityColor = Colors.green;

                                return DropdownMenuItem(
                                  value: priority,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: priorityColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        priority,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPriorityFilter = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Clear Filters Button (shown when any filter is active)
                  if (_selectedStatusFilter != 'All' ||
                      _selectedPriorityFilter != 'All Priorities' ||
                      _searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: _clearAllFilters,
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: const Text('Clear All Filters'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Task List
            Expanded(
              child: filteredTasks.isEmpty ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your filters',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (_selectedStatusFilter != 'All' ||
                        _selectedPriorityFilter != 'All Priorities' ||
                        _searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ElevatedButton.icon(
                          onPressed: _clearAllFilters,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Clear All Filters'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return _buildTaskCard(task);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    Color getColor() {
      if (label == 'Pending Review') return Colors.orange;
      if (label == 'Approved') return Colors.green;
      if (label == 'Rejected') return Colors.red;
      if (label == 'Changes Requested') return Colors.blue;
      if (label == 'In Progress') return Colors.purple;
      return Colors.grey;
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatusFilter = label;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: getColor().withOpacity(0.2),
        checkmarkColor: getColor(),
        labelStyle: TextStyle(
          color: isSelected ? getColor() : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    bool isPending = task['status'] == 'Pending Review';
    bool isApproved = task['status'] == 'Approved';
    bool isRejected = task['status'] == 'Rejected';
    bool isChangesRequested = task['status'] == 'Changes Requested';
    bool isInProgress = task['status'] == 'In Progress';

    // Check if user can undo (employee view - for pending tasks)
    bool canUndo = isPending || isChangesRequested;
    // Check if user can resubmit (for rejected tasks)
    bool canResubmit = isRejected;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task['statusColor'].withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with ID and Priority
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task['id'],
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: task['priorityColor'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: task['priorityColor']),
                  ),
                  child: Text(
                    task['priority'],
                    style: TextStyle(
                      color: task['priorityColor'],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Status Badge, Rating, and Resubmission Count
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: task['statusColor'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task['status'],
                    style: TextStyle(
                      color: task['statusColor'],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (task['resubmissionCount'] != null && task['resubmissionCount'] > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Resubmitted: ${task['resubmissionCount']}',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (task['rating'] > 0)
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 2),
                      Text(
                        task['rating'].toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              task['description'],
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Work Note
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 14, color: Colors.blue.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      task['workNote'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Attachments
            if (task['attachments'].isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attachments (${task['attachments'].length})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: task['attachments'].map<Widget>((file) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getFileIconColor(file['type']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getFileIconColor(file['type']).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getFileIcon(file['type']),
                                  size: 12,
                                  color: _getFileIconColor(file['type']),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  file['name'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getFileIconColor(file['type']),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Dates Row
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  'Due: ${_dateFormat.format(task['dueDate'])}',
                  style: TextStyle(
                    fontSize: 11,
                    color: task['dueDate'].isBefore(DateTime.now()) && task['status'] != 'Approved'
                        ? Colors.red
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.check_circle, size: 12, color: Colors.green.shade400),
                const SizedBox(width: 4),
                Text(
                  task['completedDate'] != null
                      ? 'Completed: ${_dateFormat.format(task['completedDate'])}'
                      : 'Not completed',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            if (task['reviewedBy'] != null) ...[
              const SizedBox(height: 8),
              // Reviewed Info
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: task['statusColor'].withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 14, color: task['statusColor']),
                    const SizedBox(width: 4),
                    Text(
                      'Reviewed by ${task['reviewedBy']} on ${_dateFormat.format(task['reviewedDate'])}',
                      style: TextStyle(
                        fontSize: 11,
                        color: task['statusColor'],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (task['feedback'] != null && task['feedback'].isNotEmpty) ...[
              const SizedBox(height: 8),
              // Feedback
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.feedback, size: 14, color: Colors.amber.shade800),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        task['feedback'],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            if (isChangesRequested)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showUndoTaskDialog(task),
                      icon: const Icon(Icons.undo, size: 16),
                      label: const Text('Undo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showReuploadDialog(task),
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: const Text('Re-upload'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),

            if (isRejected)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showUndoTaskDialog(task),
                          icon: const Icon(Icons.undo, size: 16),
                          label: const Text('Undo'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This task has been rejected. You can undo or resubmit with fixes.',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            if (isInProgress)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Task is in progress. Complete and submit for review.',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showResubmitDialog(task),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Resubmit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}
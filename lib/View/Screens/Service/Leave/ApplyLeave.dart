import 'dart:io';
import 'package:employee_app/Controller/Applyleave_Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../utils/colers.dart';

class Applyleave extends StatefulWidget {
  const Applyleave({super.key});

  @override
  State<Applyleave> createState() => _ApplyleaveState();
}

class _ApplyleaveState extends State<Applyleave> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  ApplyleaveController controller = ApplyleaveController();


  // File picker variables

  // File attachment variables
  String? _fileName;
  int? _fileSize;
  bool _isUploading = false;

  final List<String> _dayTypes = [
    'Full Day',
    'First Half Day',
    'Second Half Day'
  ];

  @override
  void initState() {
    super.initState();
    // Set applied date to today
    controller.fetchRawLeaveTypes();
    getID();

  }

  getID() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    controller.userId = await sp.getString("user_id") ?? "";
    print("user id ===> ${controller.userId}");
  }


  Future<DateTime?> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
    return picked;
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'txt'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        setState(() {
          controller.selectedFile = File(file.path!);
          _fileName = file.name;
          _fileSize = file.size;
          _isUploading = false;
        });

        // Show success message
        _showSnackBar(
          "File '${file.name}' attached successfully",
          Colors.green,
        );
      }
    } catch (e) {
      _showSnackBar(
        "Error picking file: $e",
        Colors.red,
      );
    }
  }

  Future<void> _removeFile() async {
    setState(() {
      controller.selectedFile = null;
      _fileName = null;
      _fileSize = null;
    });

    _showSnackBar(
      "File removed",
      Colors.orange,
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Here you would typically upload the file to your server
      // and submit the form data

      String fileInfo = _fileName != null
          ? " with file: $_fileName"
          : " without file";

      _showSnackBar(
        "Leave application submitted successfully$fileInfo",
        Colors.green,
      );

      // Navigate back after submission
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        title: const Text("Apply Leave"),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Card(
                elevation: 5,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primary_color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.event_note,
                          color: primary_color,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Leave Application",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Fill in the details to apply for leave",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Employee Name
              _buildLabel("Employee Name", Icons.person),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.employeeNameController,
                readOnly: false,
                decoration: InputDecoration(
                  hintText: "Enter employee name",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primary_color),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter employee name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Applied Date
              _buildLabel("Applied Date", Icons.calendar_today),
              const SizedBox(height: 8),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                  prefixIcon: const Icon(Icons.calendar_today),
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
              ),

              const SizedBox(height: 16),

              // Leave Type Dropdown
              _buildLabel("Select Leave Type", Icons.category),
              const SizedBox(height: 8),
              Obx(() {
                return DropdownButtonFormField<String>(
                  value: controller.selectedLeaveType,
                  decoration: InputDecoration(
                    hintText: "Choose leave type",
                    prefixIcon: const Icon(Icons.leave_bags_at_home),
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
                  items: controller.leveTypes.map((e) {
                    return DropdownMenuItem<String>(
                      child: Text(e["Leave_types"],),
                      value: e["Leave_types"],
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      controller.selectedLeaveType = value!;
                      print("=========>category ${controller.selectedLeaveType}");
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select leave type';
                    }
                    return null;
                  },
                );
              }),

              const SizedBox(height: 20),

              // From Date Section
              const Text(
                "From Date",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Obx(() => TextFormField(
                      readOnly: true,
                      controller: TextEditingController(text: controller.fromDateText),
                      onTap: () async {
                        DateTime? pickedDate = await selectDate();
                        if (pickedDate != null) {
                          controller.fromedate.value = pickedDate;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Select date",
                        prefixIcon: const Icon(Icons.date_range),
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
                      validator: (value) {
                        if (controller.fromedate.value == null) {
                          return 'Required';
                        }
                        return null;
                      },
                    )),
                  ),

                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: controller.selectedFromDayType == "" || controller.selectedFromDayType == null ? null : controller.selectedFromDayType,
                      decoration: InputDecoration(
                        hintText: "Day",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8),
                      ),
                      items: _dayTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type == 'Full Day' ? 'Full' :
                            type == 'First Half Day' ? '1st Half' : '2nd Half',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          if(value != null)
                          controller.selectedFromDayType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Req';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // To Date Section
              const Text(
                "To Date",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Obx(() => TextFormField(
                      readOnly: true,
                      controller: TextEditingController(text: controller.toDateText),
                      onTap: () async {
                        DateTime? pickedDate = await selectDate();
                        if (pickedDate != null) {
                          controller.toDate.value = pickedDate;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Select date",
                        prefixIcon: const Icon(Icons.date_range),
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
                      validator: (value) {
                        if (controller.toDate.value == null) {
                          return 'Required';
                        }
                        return null;
                      },
                    )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: controller.selectedToDayType == "" ? null : controller.selectedToDayType,
                      decoration: InputDecoration(
                        hintText: "Day",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8),
                      ),
                      items: _dayTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type == 'Full Day' ? 'Full' :
                            type == 'First Half Day' ? '1st Half' : '2nd Half',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          if(value != null)
                          controller.selectedToDayType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Req';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Remark Field
              _buildLabel("Remark (Optional)", Icons.comment),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.remarkController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter your remarks here...",
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.comment_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primary_color),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 20),

              // Attach Document Section
              _buildLabel("Attach Document", Icons.attach_file),
              const SizedBox(height: 8),

              // File picker button
              if (controller.selectedFile == null)
                InkWell(
                  onTap: _pickDocument,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tap to upload document",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Supported: PDF, DOC, DOCX, JPG, PNG, TXT",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // File info card when file is selected
              if (controller.selectedFile != null)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green.withOpacity(0.05),
                  ),
                  child: Column(
                    children: [
                      // File details
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getFileIcon(_fileName ?? ''),
                            color: Colors.green,
                          ),
                        ),
                        title: Text(
                          _fileName ?? 'Unknown file',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _fileSize != null
                              ? _formatFileSize(_fileSize!)
                              : 'Unknown size',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: _removeFile,
                        ),
                      ),

                      // File actions
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // View file
                                  _showSnackBar(
                                    "Opening file viewer...",
                                    Colors.blue,
                                  );
                                },
                                icon: const Icon(Icons.visibility, size: 16),
                                label: const Text("View"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  side: BorderSide(color: Colors.blue.shade200),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickDocument,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text("Replace"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                  side: BorderSide(
                                      color: Colors.orange.shade200),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Upload progress indicator
              if (_isUploading)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: null, // Indeterminate
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            primary_color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Uploading document...",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  controller.applyleave(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary_color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  "Submit Application",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primary_color),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    String extension = fileName
        .split('.')
        .last
        .toLowerCase();

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
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
}
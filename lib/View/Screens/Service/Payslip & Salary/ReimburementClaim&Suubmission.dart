import 'package:flutter/material.dart';
import '../../../../utils/colers.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ReimbursementClaim_Submision extends StatefulWidget {
  const ReimbursementClaim_Submision({super.key});

  @override
  State<ReimbursementClaim_Submision> createState() => _ReimbursementClaim_SubmisionState();
}

class _ReimbursementClaim_SubmisionState extends State<ReimbursementClaim_Submision> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _claimTitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  // Dropdown values
  String? _selectedClaimType;
  String? _selectedPaymentMode;

  // File attachment variables
  List<Map<String, dynamic>> _attachedFiles = [];
  bool _isUploading = false;

  // Selected claim
  String? _selectedClaimId;

  // Date format
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _displayFormat = DateFormat('dd MMM yyyy');

  // Claim types
  final List<String> _claimTypes = [
    'Medical Expenses',
    'Travel Expenses',
    'Food Expenses',
    'Fuel Expenses',
    'Internet Bills',
    'Mobile Bills',
    'Stationery',
    'Training & Development',
    'Other Expenses',
  ];

  // Payment modes
  final List<String> _paymentModes = [
    'Bank Transfer',
    'Cash',
    'Cheque',
  ];

  // Sample recent claims
  final List<Map<String, dynamic>> _recentClaims = [
    {
      'id': 'CLM001',
      'type': 'Medical Expenses',
      'amount': 2500.00,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Approved',
      'statusColor': Colors.green,
    },
    {
      'id': 'CLM002',
      'type': 'Travel Expenses',
      'amount': 1800.00,
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'status': 'Pending',
      'statusColor': Colors.orange,
    },
    {
      'id': 'CLM003',
      'type': 'Food Expenses',
      'amount': 750.00,
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'status': 'Approved',
      'statusColor': Colors.green,
    },
    {
      'id': 'CLM004',
      'type': 'Internet Bills',
      'amount': 1200.00,
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'status': 'Rejected',
      'statusColor': Colors.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = _dateFormat.format(DateTime.now());
  }

  @override
  void dispose() {
    _claimTitleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
        _dateController.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
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
            _attachedFiles.add({
              'name': file.name,
              'size': file.size,
              'path': file.path,
              'extension': file.extension,
            });
          }
          _isUploading = false;
        });

        _showSnackBar(
          '${result.files.length} file(s) attached successfully',
          Colors.green,
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showSnackBar('Error picking files: $e', Colors.red);
    }
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
    _showSnackBar('File removed', Colors.orange);
  }

  void _clearAllFiles() {
    setState(() {
      _attachedFiles.clear();
    });
    _showSnackBar('All files cleared', Colors.orange);
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

  void _submitClaim() {
    if (_formKey.currentState!.validate()) {
      if (_attachedFiles.isEmpty) {
        _showSnackBar('Please attach at least one bill/document', Colors.orange);
        return;
      }

      _showSnackBar(
        'Reimbursement claim submitted successfully',
        Colors.green,
      );

      // Clear form after successful submission
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _claimTitleController.clear();
          _descriptionController.clear();
          _amountController.clear();
          _selectedClaimType = null;
          _selectedPaymentMode = null;
          _attachedFiles.clear();
          _dateController.text = _dateFormat.format(DateTime.now());
        });
      });
    }
  }

  double get _totalClaimAmount {
    return _recentClaims.fold(0, (sum, claim) => sum + (claim['amount'] as double));
  }

  int get _pendingClaims {
    return _recentClaims.where((c) => c['status'] == 'Pending').length;
  }

  int get _approvedClaims {
    return _recentClaims.where((c) => c['status'] == 'Approved').length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reimbursement Claim Submission"),
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
              // Header Card with Summary
              _buildHeaderCard(),

              // Recent Claims Section
              _buildRecentClaimsSection(),

              // Claim Form
              _buildClaimForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade500,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
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
                  Icons.receipt,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reimbursement Claims",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Submit your expense claims with bills",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStatItem(
                icon: Icons.attach_money,
                label: 'Total Amount',
                value: '₹${_totalClaimAmount.toStringAsFixed(0)}',
                color: Colors.white,
              ),
              _buildHeaderStatItem(
                icon: Icons.pending,
                label: 'Pending',
                value: '$_pendingClaims',
                color: Colors.orange.shade300,
              ),
              _buildHeaderStatItem(
                icon: Icons.check_circle,
                label: 'Approved',
                value: '$_approvedClaims',
                color: Colors.green.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentClaimsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Claims",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all claims
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
                child: const Text("View All"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recentClaims.length,
            itemBuilder: (context, index) {
              final claim = _recentClaims[index];
              return _buildRecentClaimCard(claim);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentClaimCard(Map<String, dynamic> claim) {
    Color statusColor = claim['statusColor'];

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt,
                        size: 12,
                        color: statusColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        claim['status'],
                        style: TextStyle(
                          fontSize: 8,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  claim['type'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹${claim['amount'].toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _displayFormat.format(claim['date']),
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClaimForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.note_add,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "New Claim Submission",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Fill in the details and attach bills",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Claim Title
                  _buildFormLabel("Claim Title", Icons.title),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _claimTitleController,
                    decoration: _buildInputDecoration(
                      hint: "Enter claim title",
                      icon: Icons.title,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter claim title';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Claim Type Dropdown
                  _buildFormLabel("Claim Type", Icons.category),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedClaimType,
                    decoration: _buildInputDecoration(
                      hint: "Select claim type",
                      icon: Icons.category,
                    ),
                    items: _claimTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClaimType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select claim type';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Amount Field
                  _buildFormLabel("Amount (₹)", Icons.attach_money),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration(
                      hint: "Enter amount",
                      icon: Icons.attach_money,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Expense Date
                  _buildFormLabel("Expense Date", Icons.calendar_today),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: _buildInputDecoration(
                      hint: "Select date",
                      icon: Icons.calendar_today,
                      suffixIcon: Icons.arrow_drop_down,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select date';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Payment Mode Dropdown
                  _buildFormLabel("Payment Mode", Icons.payment),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentMode,
                    decoration: _buildInputDecoration(
                      hint: "Select payment mode",
                      icon: Icons.payment,
                    ),
                    items: _paymentModes.map((mode) {
                      return DropdownMenuItem(
                        value: mode,
                        child: Text(mode),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMode = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select payment mode';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Description
                  _buildFormLabel("Description", Icons.description),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: _buildInputDecoration(
                      hint: "Describe the expense",
                      icon: Icons.description,
                    ).copyWith(
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // File Attachment Section
                  _buildFileAttachmentSection(),

                  const SizedBox(height: 24),

                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade600,
                          Colors.orange.shade400,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _submitClaim,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Submit Claim",
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
          ),
        ),
      ),
    );
  }

  Widget _buildFormLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.orange.shade700),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey.shade500),
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: Colors.grey.shade500)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.orange.shade300, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildFileAttachmentSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.attach_file, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "Attach Bills/Documents",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _attachedFiles.isEmpty
                      ? Colors.grey.shade200
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_attachedFiles.length} file(s)',
                  style: TextStyle(
                    fontSize: 11,
                    color: _attachedFiles.isEmpty
                        ? Colors.grey.shade600
                        : Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // File picker button
          if (_attachedFiles.isEmpty)
            InkWell(
              onTap: _pickFiles,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: Colors.orange.shade300,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap to upload bills",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "PDF, JPG, PNG, DOC (Max 5MB each)",
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: null,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Uploading files...",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

          // File list
          if (_attachedFiles.isNotEmpty)
            Column(
              children: [
                ..._attachedFiles.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> file = entry.value;
                  return _buildFileTile(file, index);
                }),

                const SizedBox(height: 12),

                // File actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _clearAllFiles,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear All'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add More'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFileTile(Map<String, dynamic> file, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getFileColor(file['name']).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getFileIcon(file['name']),
              color: _getFileColor(file['name']),
              size: 20,
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
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: () => _removeFile(index),
            ),
          ),
        ],
      ),
    );
  }
}